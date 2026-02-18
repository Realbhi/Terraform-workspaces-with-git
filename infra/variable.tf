variable ec2-instance-type-micro {
   default = "t3.micro"
   type = string
}
variable ec2-instance-type-small {
   default = "t3.small"
   type = string
}
variable ami {
   default = "ami-019715e0d74f695be"
   type = string
}

variable "env" {
   default = "dev"
}

