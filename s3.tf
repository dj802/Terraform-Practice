##aws_s3_bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket        = local.s3_bucket_name
  acl           = "private"
  force_destroy = true

  tags = local.common_tags

}

resource "aws_s3_bucket_policy" "web_bucket" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.root.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}"
    }
  ]
}
    POLICY
}

##aws_s3_bucket_object
resource "aws_s3_object" "graphic" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/website/Globo_logo_Vert.png"
  source = "./website/Globo_logo_Vert.png"

  tags = local.common_tags

}


resource "aws_s3_object" "website" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/website/index.html"
  source = "./website/index.html"

  tags = local.common_tags

}

resource "aws_s3_object" "dj_website" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/website/dj-heavener.github.io.zip"
  source = "./dj-heavener.github.io.zip"

  tags = local.common_tags

}

##aws_iam_role
resource "aws_iam_role" "allow_nginx_s3" {
  name = "allow_nginx_s3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

tags = local.common_tags
}


##aws_iam_role_policy

resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement" : [
        {
            "Action" : [
                "s3:*"
            ],
            "Effect" : "Allow",
            "Resource": [
                      "arn:aws:s3:::${local.s3_bucket_name}",
                      "arn:aws:s3:::${local.s3_bucket_name}/*"
                ]
        }
    ]
}
EOF
}

##aws_iam_instance_profile
resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name

  tags = local.common_tags
}

