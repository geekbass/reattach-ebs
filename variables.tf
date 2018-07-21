variable "region" {
  description = "The Desired Region for the Infra"
  default = ""
}

variable "availability_zone" {
  description = "The AZ's to use in your Region."
  default = ""
}

variable "vpc" {
  description = "VPC for the Region"
  default = ""
}

variable "subnet" {
  description = "The subnet in your VPC"
  default = ""
}

variable "instance_types" {
  description = "The Instance Types"
  default = ""
}

variable "instance_counts" {
  description = "The number of each Node to deploy"
  default = ""
}

variable "instance_ami" {
  description = "Instance ami to use for each instance type"
  default = ""
}

variable "security_groups" {
  description = "The security groups to use for the ec2 instances. Add more if needed."
  default = ""
}

#### Define the Key and Role that is used to get to the instances ####
variable "keyfile" {
  description = "The keyfile for SSH, place in the key/ directory."
  default = ""
}

variable "keyname" {
  description = "The name of the key that gets added"
  default = ""
}

#### Disk Info for the Extra/Persistent Volumes being attached to each instance ####
variable "data_disk_size" {
  description = "Size of the disk in GB"
  default = ""
}       

variable "data_disk_type" {
  description = "Type for the ebs Data Disks node(s)"
  # gp2 for testing to keep under 500G. st1 for go live
  default = "gp2"
}

variable "user" {
  description = "The user that connects to ec2 instance"
  default = ""
}

variable "device" {
  description = "The device on the ec2 instance"
  default = "/dev/xvdb1"
}

variable "directory" {
  description = "The directory of the the data"
  default = "/data/"
}