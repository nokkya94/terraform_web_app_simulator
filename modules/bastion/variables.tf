variable "ami_id" {}
variable "instance_type" {
  default = "t3.micro"
}
variable "bastion_key_name" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "bastion_security_group_ids" {
  type = list(string)
  description = "List of security group IDs for the bastion host"
}
variable "ec2_iam_instance_profile_name" {
  description = "IAM instance profile name for the bastion host"
  type        = string
}