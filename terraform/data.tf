data "aws_prefix_list" "s3_pl" {
  name = "com.amazonaws.ap-northeast-1.s3"
}

data "aws_ami" "app" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = ["tastylog-*-ami"]
  }
}
