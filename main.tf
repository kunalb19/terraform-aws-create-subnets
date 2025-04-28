data "aws_vpc" "aws_vpc" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

############################################################
resource "aws_subnet" "aws_subnet" {
  count                   = var.subnet_count
  cidr_block              = cidrsubnet(data.aws_vpc.aws_vpc.cidr_block, 8, count.index + var.subnet_series) # 10.10.0.0/24
  vpc_id                  = var.vpc_id
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = var.type == "public" ? true : false
  tags = merge(var.tags,
    {
      type = var.type
    }
  )
}
resource "aws_internet_gateway" "aws_internet_gateway" {
  count  = var.internet_gateway_required == true ? 1 : 0
  vpc_id = var.vpc_id
  tags   = var.tags
}
resource "aws_route" "igw_route" {
  count                  = var.internet_gateway_required == true ? 1 : 0
  route_table_id         = var.route_table_id == "" ? data.aws_vpc.aws_vpc.main_route_table_id : var.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws_internet_gateway[0].id
}
resource "aws_route_table_association" "aws_route_table_association_public_subnet" {
  count          = var.type == "public" ? var.subnet_count : 0
  subnet_id      = aws_subnet.aws_subnet[count.index].id
  route_table_id = var.route_table_id == "" ? data.aws_vpc.aws_vpc.main_route_table_id : var.route_table_id
}
resource "aws_eip" "eip_nat_gateway" {
  count = var.nat_gateway_required == true ? length(var.nat_subnet_id) : 0
  tags  = var.tags
}
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.nat_gateway_required == true ? length(var.nat_subnet_id) : 0
  allocation_id = aws_eip.eip_nat_gateway[count.index].id
  subnet_id     = var.nat_subnet_id[count.index]
  tags          = var.tags
}
resource "aws_route_table" "aws_route_table" {
  count  = var.type == "private" ? var.subnet_count : 0
  vpc_id = var.vpc_id
  tags   = var.tags
}
resource "aws_route_table_association" "aws_route_table_association" {
  count          = var.type == "private" ? var.subnet_count : 0
  subnet_id      = aws_subnet.aws_subnet[count.index].id
  route_table_id = aws_route_table.aws_route_table[count.index].id
}
resource "aws_route" "nat_route" {
  count                  = var.nat_gateway_required == true ? length(var.nat_subnet_id) : 0
  route_table_id         = aws_route_table.aws_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}