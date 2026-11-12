// Add as a deploy key wherever the platform Runner clones from over SSH.
output "platform_runner_ssh_public_key_openssh" {
  value = trimspace(azrandom_cryptographic_key.ssh.public_key_openssh)
}

output "platform_runner_ssh_key_secret_name" {
  value = azrandom_cryptographic_key.ssh.name
}
