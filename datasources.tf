data "aws_ami" "server_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # Update with a valid AMI name pattern
  }

  owners = ["amazon"] # Specify the owner (e.g., "amazon" for official Amazon AMIs)
}
