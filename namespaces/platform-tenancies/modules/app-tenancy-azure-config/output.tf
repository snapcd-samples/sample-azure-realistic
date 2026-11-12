// Add as a deploy key wherever the app Runner clones from over SSH.
output "app_runner_ssh_public_key_openssh" {
  value = trimspace(azrandom_cryptographic_key.ssh.public_key_openssh)
}

output "app_runner_ssh_key_secret_name" {
  value = azrandom_cryptographic_key.ssh.name
}
