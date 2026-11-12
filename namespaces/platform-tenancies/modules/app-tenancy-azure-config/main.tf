// Generated straight into the app Key Vault, so the private key is never in state.
resource "azrandom_cryptographic_key" "ssh" {
  name      = "${var.name}-runner-ssh-private-key"
  algorithm = "RSA"
  rsa_bits  = 4096
  keepers   = var.keepers
}
