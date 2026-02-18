#1. key-pair 
#2. VPC - Security Group
#3. Ec2 instance

resource aws_key_pair deployer {
     key_name = "Deployer-key"
     public_key = file("prvtpubkey.pub")
}

resource aws_default_vpc default-vpc{
     
}

resource aws_security_group SgforTF {
   name = "sgfortraffic"
   vpc_id = aws_default_vpc.default-vpc.id
   description = "This security group is to control ingress and egress traffic"  

   ingress{
     from_port = 22
     to_port = 22
     cidr_blocks = ["0.0.0.0/0"]
     protocol = "tcp"
   }
   
   ingress{
     from_port = 80
     to_port = 80
     cidr_blocks = ["0.0.0.0/0"]
     protocol = "tcp"
   }
 
   ingress{
     from_port = 80
     to_port = 80
     cidr_blocks = ["0.0.0.0/0"]
     protocol = "tcp"
   }
   
   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
}
}

resource aws_instance "ec2-instance" {
   ami = var.ami
   for_each = tomap({
     
         "instance-1-for-tf" = "t3.micro"
         "instance-2-for-tf" = "t3.small"
         "instance-3-for-tf" = "t3.small"  
 
   })

   instance_type = each.value
   key_name = aws_key_pair.deployer.key_name
   security_groups = [aws_security_group.SgforTF.name]
  
  root_block_device {
     volume_size = 10
     volume_type = "gp3"
  }

  tags = {
     Name = each.key
  } 

}


resource aws_instance "ec2-instance-imported" {
   
    ami = "ami-019715e0d74f695be" 
    instance_type = "t3.micro"
    key_name = "templete-key" 

}

resource aws_instance "ec2-instance-imported2" {

    ami = "ami-019715e0d74f695be" 
    instance_type = "t3.micro"
    key_name = "templete-key"

    tags = {
       Name = "see-import-instance"
    }
   
}





