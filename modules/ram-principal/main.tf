resource "aws_ram_principal_association" "principal" {
  principal          = var.account_number
  resource_share_arn = var.resource_share_arn
}