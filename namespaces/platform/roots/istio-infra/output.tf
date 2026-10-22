output public_gateway_ip {
    value = azurerm_public_ip.public_gateway.ip_address
}
output private_gateway_reserved_ip {
    value = var.private_gateway_reserved_ip
}
output public_gateway_fqdn {
    value = azurerm_public_ip.public_gateway.fqdn
}
