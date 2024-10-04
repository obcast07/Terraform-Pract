locals {
  inbound_rules = [
    {port = 80, protocol = "tcp"}, #1
    {port = 20, protocol = "tcp"} #2
  ]
  outbout_rules = [
    {port = 0, protocol = "-1"}
  ]
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "nginx-server" {
  ami = "ami-0fff1b9a61dec8a5f"
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF
  key_name = aws_key_pair.nginx-server-ssh.key_name

  vpc_security_group_ids = [aws_security_group.nginx-server-sg.id]
}

resource "aws_key_pair" "nginx-server-ssh" {
    key_name = "nginx-server-ssh"
    public_key = file("nginx-server.key.pub")
  
}

resource "aws_security_group" "nginx-server-sg" {
  name = "nginx-server-sg"
  description = "Security group allowing SSH and HTTP access"


  dynamic ingress {
    for_each = local.inbound_rules
    content{
        from_port = ingress.value.port
        to_port = ingress.value.port
        protocol = ingress.value.protocol
        cidr_blocks = ["0.0.0.0/0"]
    }
  }
#  ingress = {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]}
#   ingress = {
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   } 

 dynamic egress {
   for_each = local.outbout_rules
   content {
     from_port = egress.value.port
     to_port = egress.value.port
     protocol = egress.value.protocol
     cidr_blocks = ["0.0.0.0/0"]
   }
 }
#   egress = {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


}