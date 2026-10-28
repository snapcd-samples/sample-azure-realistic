
resource "azurerm_public_ip" "public_gateway" {
  name                = "istio-public-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.public_gateway_domain_name_label
}

