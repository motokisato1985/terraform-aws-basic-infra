#-----------------------------
# launch template
#-----------------------------
resource "aws_launch_template" "app_lt" {
  update_default_version = true
  name_prefix            = "${var.project}-${var.environment}-app-lt"
  image_id               = data.aws_ami.app.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.keypair.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.app_sg.id
    ]
    delete_on_termination = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.app_ec2_profile.name
  }

  user_data = filebase64("./source/initialize.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project}-${var.environment}-app-ec2"
      Project = var.project
      Env     = var.environment
      Type    = "app"
    }
  }
}

#-----------------------------
# Auto Scaling Group
#-----------------------------
resource "aws_autoscaling_group" "app_asg" {
  name_prefix      = "${var.project}-${var.environment}-app-asg"
  max_size         = 1
  min_size         = 1
  desired_capacity = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1c.id
  ]

  target_group_arns = [aws_lb_target_group.alb_target_group.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}

#------------------------------------------------
# EC2 Instance (ASGを使用するため、コメントアウト)
#------------------------------------------------
/*resource "aws_instance" "app_server" {
  ami           = data.aws_ami.app.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1a.id
  vpc_security_group_ids = [
    aws_security_group.app_sg.id,
  aws_security_group.opmng_sg.id]
  key_name                    = aws_key_pair.keypair.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.app_ec2_profile.name

  tags = {
    Name    = "${var.project}-${var.environment}-app-ec2"
    Project = var.project
    Env     = var.environment
    Type    = "app"
  }
}
*/
