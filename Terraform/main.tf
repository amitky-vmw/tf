provider "aws" {
region="ap-southeast-1"
}
variable "instance_type" {
description = "AWS instance type"
default = "t2.micro"
}

variable "myTag" {
description = "My Input Tag"
default = "terraform-test"
}

resource "aws_instance" "machine1" {
ami = "ami-49487a35"
instance_type = "t2.micro"
availability_zone = "ap-southeast-1a"
tags = {
"Name" = var.myTag
}
}

resource "aws_instance" "machine2" {
ami = "ami-49487a35"
instance_type = "t2.micro"
availability_zone = "ap-southeast-1a"
tags = {
"Name" = var.myTag
}
}
