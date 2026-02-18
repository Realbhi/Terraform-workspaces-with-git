#output "instance-public-ip" {
#   value = aws_instance.ec2-instance[*].public_ip
#}

#output "instance-public-dns" {
#   value = aws_instance.ec2-instance[*].public_dns
#}

output "instance-public-ip" {
     value = [
         for random in aws_instance.ec2-instance : random.public_ip
     ]
}

output "instance-public-dns" {
     value = [
         for random in aws_instance.ec2-instance : random.public_dns
     ]
}
