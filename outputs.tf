output "mumbai_bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "mumbai_ec2_a_private_ip" {
  value = aws_instance.ec2_a_private.private_ip
}

output "virginia_ec2_b_private_ip" {
  value = aws_instance.ec2_b_private.private_ip
}

output "peering_connection_id" {
  value = aws_vpc_peering_connection.pcx.id
}
