# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.aws_instance_sizes
  subnet_id              = aws_subnet.public_subnet1.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo yum install unzip
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/dj-heavener.github.io.zip /home/ec2-user/dj-heavener.github.io.zip
sudo rm -r /usr/share/nginx/html/
unzip /home/ec2-user/dj-heavener.github.io.zip
sudo mv /home/ec2-user/dj-heavener.github.io /usr/share/nginx/html/
EOF

  tags = local.common_tags

}

resource "aws_instance" "nginx2" {
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.aws_instance_sizes
  subnet_id              = aws_subnet.public_subnet2.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo yum install unzip
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/dj-heavener.github.io.zip /home/ec2-user/dj-heavener.github.io.zip
sudo rm -r /usr/share/nginx/html/
unzip /home/ec2-user/dj-heavener.github.io.zip
sudo mv /home/ec2-user/dj-heavener.github.io /usr/share/nginx/html/
EOF

  tags = local.common_tags
}