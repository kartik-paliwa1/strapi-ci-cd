output "public_ip" {
  value       = aws_instance.strapi_server.public_ip
  description = "The public IP address of the Strapi server."
}
