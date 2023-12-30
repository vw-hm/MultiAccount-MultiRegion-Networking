#----------------------------------------
# Share the transit gateway from Region 1 to Region 3 (another account)
#----------------------------------------

resource "aws_ram_resource_share" "r1_r3_transit_gateway_resource_share" {
  name                      = "r1-r3-transit-gateway-resource-share"
  allow_external_principals = true

  tags = {
    Environment = var.r1_environment
  }
}

resource "aws_ram_resource_association" "r1_share_transit_gateway" {
  resource_arn       = aws_ec2_transit_gateway.r1_tgw.arn
  resource_share_arn = aws_ram_resource_share.r1_r3_transit_gateway_resource_share.arn
}

resource "aws_ram_principal_association" "r3_share_transit_gateway" {
  principal          = "657100425642"
  resource_share_arn = aws_ram_resource_share.r1_r3_transit_gateway_resource_share.arn
}

#----------------------------------------
# Acccept the resource share in Region 2 (another account)
#----------------------------------------

resource "aws_ram_resource_share_accepter" "r3_accept_transit_gateway" {
provider = aws.rmt_eu_west_1
share_arn = aws_ram_principal_association.r3_share_transit_gateway.resource_share_arn
}