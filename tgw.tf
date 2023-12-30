# -----------------------------------------------------
# Create transit gateway in the first region
# -----------------------------------------------------

resource "aws_ec2_transit_gateway" "r1_tgw" {
  description = "TGW in EU West 1"
  amazon_side_asn = 64512
  auto_accept_shared_attachments = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "enable"
  tags = {
    Purpose = "tgw-complete-example"
    Name = "${var.r1_environment}-tgw-eu-west-1"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "r1_tgw-dev-vpc-attachment" {
  subnet_ids         = aws_subnet.r1_public_subnet[*].id
  transit_gateway_id = aws_ec2_transit_gateway.r1_tgw.id
  vpc_id             = aws_vpc.r1_vpc.id
}

resource "aws_ec2_transit_gateway_route_table" "r1_tgw-dev-vpc-route-table" {
  transit_gateway_id = aws_ec2_transit_gateway.r1_tgw.id
}

resource "aws_ec2_transit_gateway_route_table_association" "r1_tgw-dev-vpc-route-table-association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r1_tgw-dev-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.r1_tgw-dev-vpc-route-table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "r1_tgw-dev-vpc-route-table-propogation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r1_tgw-dev-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.r1_tgw-dev-vpc-route-table.id
}


# -----------------------------------------------------
# Create transit gateway in the Second region
# -----------------------------------------------------

resource "aws_ec2_transit_gateway" "r2_tgw" {
    provider = aws.eu_central_1
  description = "TGW in EU Central 1"
  amazon_side_asn = 64512
  auto_accept_shared_attachments = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "enable"
  tags = {
    Purpose = "tgw-complete-example"
    Name = "${var.r2_environment}-tgw-eu-west-1"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "r2_tgw-dev-vpc-attachment" {
    provider = aws.eu_central_1
  subnet_ids         = aws_subnet.r2_public_subnet[*].id
  transit_gateway_id = aws_ec2_transit_gateway.r2_tgw.id
  vpc_id             = aws_vpc.r2_vpc.id
}

resource "aws_ec2_transit_gateway_route_table" "r2_tgw-dev-vpc-route-table" {
    provider = aws.eu_central_1
  transit_gateway_id = aws_ec2_transit_gateway.r2_tgw.id
}

resource "aws_ec2_transit_gateway_route_table_association" "r2_tgw-dev-vpc-route-table-association" {
    provider = aws.eu_central_1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r2_tgw-dev-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.r2_tgw-dev-vpc-route-table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "r2_tgw-dev-vpc-route-table-propogation" {
    provider = aws.eu_central_1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r2_tgw-dev-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.r2_tgw-dev-vpc-route-table.id
}


# -----------------------------------------------------
# Create TGW peering between the two regions
# -----------------------------------------------------


resource "aws_ec2_transit_gateway_peering_attachment" "r1_tgw-peering-attachment-request" {
   
  peer_region             = "eu-central-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.r2_tgw.id
  transit_gateway_id      = aws_ec2_transit_gateway.r1_tgw.id

  tags = {
    Name = "TGW Peering Requestor"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "r2_tgw-peering-connection-accepter" {
  provider = aws.eu_central_1

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.r1_tgw-peering-attachment-request.id
  tags = {
    Name = "Example cross-account attachment"
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment.r1_tgw-peering-attachment-request]
}



# -----------------------------------------------------
# Add route to attachment in region 1, and add route to handle the traffic going to region 2
# -----------------------------------------------------


resource "aws_ec2_transit_gateway_route_table_association" "r1_tgw-dev-vpc-peering-table-association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.r1_tgw-peering-attachment-request.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.r1_tgw-dev-vpc-route-table.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.r2_tgw-peering-connection-accepter]
}

resource "aws_ec2_transit_gateway_route" "r1_tgw-dev-vpc-peering-route" {
  destination_cidr_block         = "10.10.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.r1_tgw-peering-attachment-request.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.r1_tgw-dev-vpc-route-table.id

depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.r2_tgw-peering-connection-accepter]
}

# -----------------------------------------------------
# Add route to attachment in region 2, and add route to handle the traffic going to region 1
# -----------------------------------------------------

resource "aws_ec2_transit_gateway_route_table_association" "r2_tgw-dev-vpc-peering-table-association" {
    provider = aws.eu_central_1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.r2_tgw-peering-connection-accepter.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.r2_tgw-dev-vpc-route-table.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.r2_tgw-peering-connection-accepter]
}

resource "aws_ec2_transit_gateway_route" "r2_tgw-dev-vpc-peering-route" {
    provider = aws.eu_central_1
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.r2_tgw-peering-connection-accepter.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.r2_tgw-dev-vpc-route-table.id

depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.r2_tgw-peering-connection-accepter]
}

# -----------------------------------------------------
# In Region 3, attach the VPC to the shared transit gateway
# -----------------------------------------------------

resource "aws_ec2_transit_gateway_vpc_attachment" "r3_tgw-dev-vpc-attachment" {
    provider = aws.rmt_eu_west_1
  subnet_ids         = aws_subnet.r3_public_subnet[*].id
  transit_gateway_id = aws_ec2_transit_gateway.r1_tgw.id
  vpc_id             = aws_vpc.r3_vpc.id

  depends_on = [aws_ram_resource_share_accepter.r3_accept_transit_gateway]
}

resource "aws_ec2_transit_gateway_route_table_association" "r3_tgw-dev-vpc-route-table-association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r3_tgw-dev-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.r1_tgw-dev-vpc-route-table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "r3_tgw-dev-vpc-route-table-propogation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r3_tgw-dev-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.r1_tgw-dev-vpc-route-table.id
}

resource "aws_ec2_transit_gateway_route" "r3_tgw-dev-vpc-sharing-route" {
  destination_cidr_block         = "10.20.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r3_tgw-dev-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.r1_tgw-dev-vpc-route-table.id

depends_on = [aws_ram_resource_share_accepter.r3_accept_transit_gateway]
}