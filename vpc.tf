/*====
The VPC for Region 1
======*/

resource "aws_vpc" "r1_vpc" {
  cidr_block           = "${var.r1_vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.r1_environment}-vpc"
    Environment = "${var.r1_environment}"
  }
}

/*====
Subnets
======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "r1_ig" {
  vpc_id = "${aws_vpc.r1_vpc.id}"

  tags = {
    Name        = "${var.r1_environment}-igw"
    Environment = "${var.r1_environment}"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "r1_nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.r1_ig]
}

/* NAT */
resource "aws_nat_gateway" "r1_nat" {
  allocation_id = "${aws_eip.r1_nat_eip.id}"
  subnet_id     = "${element(aws_subnet.r1_public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.r1_ig]

  tags = {
    Name        = "nat"
    Environment = "${var.r1_environment}"
  }
}

/* Public subnet */
resource "aws_subnet" "r1_public_subnet" {
  vpc_id                  = "${aws_vpc.r1_vpc.id}"
  count                   = "${length(var.r1_public_subnets_cidr)}"
  cidr_block              = "${element(var.r1_public_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.r1_availability_zones, count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.r1_environment}-${element(var.r1_availability_zones, count.index)}-public-subnet"
    Environment = "${var.r1_environment}"
  }
}

/* Private subnet */
resource "aws_subnet" "r1_private_subnet" {
  vpc_id                  = "${aws_vpc.r1_vpc.id}"
  count                   = "${length(var.r1_private_subnets_cidr)}"
  cidr_block              = "${element(var.r1_private_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.r1_availability_zones, count.index)}"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.r1_environment}-${element(var.r1_availability_zones, count.index)}-private-subnet"
    Environment = "${var.r1_environment}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "r1_private" {
  vpc_id = "${aws_vpc.r1_vpc.id}"

  tags = {
    Name        = "${var.r1_environment}-private-route-table"
    Environment = "${var.r1_environment}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "r1_public" {
  vpc_id = "${aws_vpc.r1_vpc.id}"

  tags = {
    Name        = "${var.r1_environment}-public-route-table"
    Environment = "${var.r1_environment}"
  }
}

resource "aws_route" "r1_public_internet_gateway" {
  route_table_id         = "${aws_route_table.r1_public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.r1_ig.id}"
}

resource "aws_route" "r1_transit_gateway_route" {
  route_table_id         = "${aws_route_table.r1_public.id}"
  destination_cidr_block = "10.10.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.r1_tgw.id
}

resource "aws_route" "r3_transit_gateway_route" {
  route_table_id         = "${aws_route_table.r1_public.id}"
  destination_cidr_block = "10.20.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.r1_tgw.id
}

resource "aws_route" "r1_private_nat_gateway" {
  route_table_id         = "${aws_route_table.r1_private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.r1_nat.id}"
}

/* Route table associations */
resource "aws_route_table_association" "r1_public" {
  count          = "${length(var.r1_public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.r1_public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.r1_public.id}"
}

resource "aws_route_table_association" "r1_private" {
  count          = "${length(var.r1_private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.r1_private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.r1_private.id}"
}


/*====
VPC's Default Security Group
======*/
resource "aws_security_group" "r1_default" {
  name        = "${var.r1_environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.r1_vpc.id}"
  depends_on  = [aws_vpc.r1_vpc]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags = {
    Environment = "${var.r1_environment}"
  }
}



/*====
The VPC for Region 2
======*/

resource "aws_vpc" "r2_vpc" {
  provider = aws.eu_central_1
  cidr_block           = "${var.r2_vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.r2_environment}-vpc"
    Environment = "${var.r2_environment}"
  }
}

/*====
Subnets
======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "r2_ig" {
  provider = aws.eu_central_1
  vpc_id = "${aws_vpc.r2_vpc.id}"

  tags = {
    Name        = "${var.r2_environment}-igw"
    Environment = "${var.r2_environment}"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "r2_nat_eip" {
  provider = aws.eu_central_1
  vpc        = true
  depends_on = [aws_internet_gateway.r2_ig]
}

/* NAT */
resource "aws_nat_gateway" "r2_nat" {
  provider = aws.eu_central_1
  allocation_id = "${aws_eip.r2_nat_eip.id}"
  subnet_id     = "${element(aws_subnet.r2_public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.r2_ig]

  tags = {
    Name        = "nat"
    Environment = "${var.r2_environment}"
  }
}

/* Public subnet */
resource "aws_subnet" "r2_public_subnet" {
  provider = aws.eu_central_1
  vpc_id                  = "${aws_vpc.r2_vpc.id}"
  count                   = "${length(var.r2_public_subnets_cidr)}"
  cidr_block              = "${element(var.r2_public_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.r2_availability_zones, count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.r2_environment}-${element(var.r2_availability_zones, count.index)}-public-subnet"
    Environment = "${var.r2_environment}"
  }
}

/* Private subnet */
resource "aws_subnet" "r2_private_subnet" {
  provider = aws.eu_central_1
  vpc_id                  = "${aws_vpc.r2_vpc.id}"
  count                   = "${length(var.r2_private_subnets_cidr)}"
  cidr_block              = "${element(var.r2_private_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.r2_availability_zones, count.index)}"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.r2_environment}-${element(var.r2_availability_zones, count.index)}-private-subnet"
    Environment = "${var.r2_environment}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "r2_private" {
  provider = aws.eu_central_1
  vpc_id = "${aws_vpc.r2_vpc.id}"

  tags = {
    Name        = "${var.r2_environment}-private-route-table"
    Environment = "${var.r2_environment}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "r2_public" {
  provider = aws.eu_central_1
  vpc_id = "${aws_vpc.r2_vpc.id}"

  tags = {
    Name        = "${var.r2_environment}-public-route-table"
    Environment = "${var.r2_environment}"
  }
}

resource "aws_route" "r2_public_internet_gateway" {
  provider = aws.eu_central_1
  route_table_id         = "${aws_route_table.r2_public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.r2_ig.id}"
}

resource "aws_route" "r2_private_nat_gateway" {
  provider = aws.eu_central_1
  route_table_id         = "${aws_route_table.r2_private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.r2_nat.id}"
}

resource "aws_route" "r2_private_transit_gateway_route" {
  provider = aws.eu_central_1
  route_table_id         = "${aws_route_table.r2_private.id}"
  destination_cidr_block = "10.0.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.r2_tgw.id
}

resource "aws_route" "r2_public_transit_gateway_route" {
  provider = aws.eu_central_1
  route_table_id         = "${aws_route_table.r2_public.id}"
  destination_cidr_block = "10.0.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.r2_tgw.id
}

/* Route table associations */
resource "aws_route_table_association" "r2_public" {
  provider = aws.eu_central_1
  count          = "${length(var.r2_public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.r2_public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.r2_public.id}"
}

resource "aws_route_table_association" "r2_private" {
  provider = aws.eu_central_1
  count          = "${length(var.r2_private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.r2_private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.r2_private.id}"
}


/*====
VPC's Default Security Group
======*/
resource "aws_security_group" "r2_default" {
  provider = aws.eu_central_1
  name        = "${var.r2_environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.r2_vpc.id}"
  depends_on  = [aws_vpc.r2_vpc]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags = {
    Environment = "${var.r2_environment}"
  }
}


/*====
The VPC for Region 3 in another account
======*/

resource "aws_vpc" "r3_vpc" {
  provider = aws.rmt_eu_west_1
  cidr_block           = "${var.r3_vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.r3_environment}-vpc"
    Environment = "${var.r3_environment}"
  }
}

/*====
Subnets
======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "r3_ig" {
  provider = aws.rmt_eu_west_1
  vpc_id = "${aws_vpc.r3_vpc.id}"

  tags = {
    Name        = "${var.r3_environment}-igw"
    Environment = "${var.r3_environment}"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "r3_nat_eip" {
  provider = aws.rmt_eu_west_1
  vpc        = true
  depends_on = [aws_internet_gateway.r3_ig]
}

/* NAT */
resource "aws_nat_gateway" "r3_nat" {
  provider = aws.rmt_eu_west_1
  allocation_id = "${aws_eip.r3_nat_eip.id}"
  subnet_id     = "${element(aws_subnet.r3_public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.r3_ig]

  tags = {
    Name        = "nat"
    Environment = "${var.r3_environment}"
  }
}

/* Public subnet */
resource "aws_subnet" "r3_public_subnet" {
  provider = aws.rmt_eu_west_1
  vpc_id                  = "${aws_vpc.r3_vpc.id}"
  count                   = "${length(var.r3_public_subnets_cidr)}"
  cidr_block              = "${element(var.r3_public_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.r3_availability_zones, count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.r3_environment}-${element(var.r3_availability_zones, count.index)}-public-subnet"
    Environment = "${var.r3_environment}"
  }
}

/* Private subnet */
resource "aws_subnet" "r3_private_subnet" {
  provider = aws.rmt_eu_west_1
  vpc_id                  = "${aws_vpc.r3_vpc.id}"
  count                   = "${length(var.r3_private_subnets_cidr)}"
  cidr_block              = "${element(var.r3_private_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.r3_availability_zones, count.index)}"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.r3_environment}-${element(var.r3_availability_zones, count.index)}-private-subnet"
    Environment = "${var.r3_environment}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "r3_private" {
  provider = aws.rmt_eu_west_1
  vpc_id = "${aws_vpc.r3_vpc.id}"

  tags = {
    Name        = "${var.r3_environment}-private-route-table"
    Environment = "${var.r3_environment}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "r3_public" {
  provider = aws.rmt_eu_west_1
  vpc_id = "${aws_vpc.r3_vpc.id}"

  tags = {
    Name        = "${var.r3_environment}-public-route-table"
    Environment = "${var.r3_environment}"
  }

}

resource "aws_route" "r3_public_internet_gateway" {
  provider = aws.rmt_eu_west_1
  route_table_id         = "${aws_route_table.r3_public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.r3_ig.id}"
}

resource "aws_route" "r3_public_r1_route" {
  provider = aws.rmt_eu_west_1
  route_table_id         = "${aws_route_table.r3_public.id}"
  destination_cidr_block = "10.10.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.r1_tgw.id
}

resource "aws_route" "r3_public_r2_route" {
  provider = aws.rmt_eu_west_1
  route_table_id         = "${aws_route_table.r3_public.id}"
  destination_cidr_block = "10.0.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.r1_tgw.id
}

resource "aws_route" "r3_private_nat_gateway" {
  provider = aws.rmt_eu_west_1
  route_table_id         = "${aws_route_table.r3_private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.r3_nat.id}"
}

resource "aws_route" "r3_private_r1_route" {
  provider = aws.rmt_eu_west_1
  route_table_id         = "${aws_route_table.r3_private.id}"
  destination_cidr_block = "10.10.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.r1_tgw.id
}

resource "aws_route" "r3_private_r2_route" {
  provider = aws.rmt_eu_west_1
  route_table_id         = "${aws_route_table.r3_private.id}"
  destination_cidr_block = "10.0.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.r1_tgw.id
}

/* Route table associations */
resource "aws_route_table_association" "r3_public" {
  provider = aws.rmt_eu_west_1
  count          = "${length(var.r3_public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.r3_public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.r3_public.id}"
}

resource "aws_route_table_association" "r3_private" {
  provider = aws.rmt_eu_west_1
  count          = "${length(var.r3_private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.r3_private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.r3_private.id}"
}


/*====
VPC's Default Security Group
======*/
resource "aws_security_group" "r3_default" {
  provider = aws.rmt_eu_west_1
  name        = "${var.r3_environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.r3_vpc.id}"
  depends_on  = [aws_vpc.r3_vpc]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags = {
    Environment = "${var.r3_environment}"
  }
}

