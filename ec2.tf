# -----------------------------------------------------
# Create EC2 for testig in Region 1
# -----------------------------------------------------

data "aws_ami" "r1_amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name = "name"
    values = ["al2023-ami-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_iam_role" "r1_role_for_ec2" {
  name = "projectx-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "r1_ec2-additional-policy" {
  name = "projectx-ec2-additional-policy"
policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "*"
        ],
        "Resource": "*"
      } 
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "r1_ec2-additional-policy-attachment" {
  role       = aws_iam_role.r1_role_for_ec2.name
  policy_arn = aws_iam_policy.r1_ec2-additional-policy.arn
}

resource "aws_iam_instance_profile" "r1_ec2_profile" {
  name = "projectx-ec2-instance-profle"
  role = aws_iam_role.r1_role_for_ec2.name
}


resource "aws_instance" "r1_bastion_host" {
  ami                    = data.aws_ami.r1_amazon_linux_2023.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.r1_private_key.key_name
  subnet_id              = aws_subnet.r1_public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.r1_bastion_host.id]
  iam_instance_profile = aws_iam_instance_profile.r1_ec2_profile.name
}


resource "aws_security_group" "r1_kafka" {
  name   = "projectx-${var.r1_global_prefix}-kafka"
  vpc_id = aws_vpc.r1_vpc.id
  ingress {
    from_port   = 0
    to_port     = 9092
    protocol    = "TCP"
    cidr_blocks = var.r1_private_subnets_cidr
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "r1_bastion_host" {
  name   = "projectx-${var.r1_global_prefix}-bastion-host"
  vpc_id = aws_vpc.r1_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "r1_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "r1_private_key" {
  key_name   = var.r1_global_prefix
  public_key = tls_private_key.r1_private_key.public_key_openssh
}

resource "local_file" "r1_private_key" {
  content  = tls_private_key.r1_private_key.private_key_pem
  filename = "r1_cert.pem"
}

resource "null_resource" "r1_private_key_permissions" {
  depends_on = [local_file.r1_private_key]
  provisioner "local-exec" {
    command     = "chmod 600 r1_cert.pem"
    interpreter = ["bash", "-c"]
    on_failure  = continue
  }
}


# -----------------------------------------------------
# Create EC2 for testig in Region 2
# -----------------------------------------------------

data "aws_ami" "r2_amazon_linux_2023" {
  provider = aws.eu_central_1
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name = "name"
    values = ["al2023-ami-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_iam_role" "r2_role_for_ec2" {
  provider = aws.eu_central_1
  name = "projectx1-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "r2_ec2-additional-policy" {
  provider = aws.eu_central_1
  name = "projectx1-ec2-additional-policy"
policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "*"
        ],
        "Resource": "*"
      } 
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "r2_ec2-additional-policy-attachment" {
  provider = aws.eu_central_1
  role       = aws_iam_role.r2_role_for_ec2.name
  policy_arn = aws_iam_policy.r2_ec2-additional-policy.arn
}

resource "aws_iam_instance_profile" "r2_ec2_profile" {
  provider = aws.eu_central_1
  name = "projectx1-ec2-instance-profle"
  role = aws_iam_role.r2_role_for_ec2.name
}


resource "aws_instance" "r2_bastion_host" {
  provider = aws.eu_central_1
  ami                    = data.aws_ami.r2_amazon_linux_2023.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.r2_private_key.key_name
  subnet_id              = aws_subnet.r2_private_subnet[0].id
  vpc_security_group_ids = [aws_security_group.r2_bastion_host.id]
  iam_instance_profile = aws_iam_instance_profile.r2_ec2_profile.name
}


resource "aws_security_group" "r2_kafka" {
  provider = aws.eu_central_1
  name   = "projectx1-${var.r2_global_prefix}-kafka"
  vpc_id = aws_vpc.r2_vpc.id
  ingress {
    from_port   = 0
    to_port     = 9092
    protocol    = "TCP"
    cidr_blocks = var.r2_private_subnets_cidr
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "r2_bastion_host" {
  provider = aws.eu_central_1
  name   = "projectx1-${var.r2_global_prefix}-bastion-host"
  vpc_id = aws_vpc.r2_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "r2_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "r2_private_key" {
  provider = aws.eu_central_1
  key_name   = var.r2_global_prefix
  public_key = tls_private_key.r2_private_key.public_key_openssh
}

resource "local_file" "r2_private_key" {
  content  = tls_private_key.r2_private_key.private_key_pem
  filename = "r2_cert.pem"
}

resource "null_resource" "r2_private_key_permissions" {
  depends_on = [local_file.r2_private_key]
  provisioner "local-exec" {
    command     = "chmod 600 r2_cert.pem"
    interpreter = ["bash", "-c"]
    on_failure  = continue
  }
}




# -----------------------------------------------------
# Create EC2 for testig in Region 3
# -----------------------------------------------------

data "aws_ami" "r3_amazon_linux_2023" {
  provider = aws.rmt_eu_west_1
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name = "name"
    values = ["al2023-ami-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_iam_role" "r3_role_for_ec2" {
  provider = aws.rmt_eu_west_1
  name = "projectx3-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "r3_ec2-additional-policy" {
  provider = aws.rmt_eu_west_1
  name = "projectx3-ec2-additional-policy"
policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "*"
        ],
        "Resource": "*"
      } 
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "r3_ec2-additional-policy-attachment" {
  provider = aws.rmt_eu_west_1
  role       = aws_iam_role.r3_role_for_ec2.name
  policy_arn = aws_iam_policy.r3_ec2-additional-policy.arn
}

resource "aws_iam_instance_profile" "r3_ec2_profile" {
  provider = aws.rmt_eu_west_1
  name = "projectx3-ec2-instance-profle"
  role = aws_iam_role.r3_role_for_ec2.name
}


resource "aws_instance" "r3_bastion_host" {
  provider = aws.rmt_eu_west_1
  ami                    = data.aws_ami.r3_amazon_linux_2023.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.r3_private_key.key_name
  subnet_id              = aws_subnet.r3_public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.r3_bastion_host.id]
  iam_instance_profile = aws_iam_instance_profile.r3_ec2_profile.name
}


resource "aws_security_group" "r3_kafka" {
  provider = aws.rmt_eu_west_1
  name   = "projectx1-${var.r3_global_prefix}-kafka"
  vpc_id = aws_vpc.r3_vpc.id
  ingress {
    from_port   = 0
    to_port     = 9092
    protocol    = "TCP"
    cidr_blocks = var.r3_private_subnets_cidr
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "r3_bastion_host" {
  provider = aws.rmt_eu_west_1
  name   = "projectx1-${var.r3_global_prefix}-bastion-host"
  vpc_id = aws_vpc.r3_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "r3_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "r3_private_key" {
  provider = aws.rmt_eu_west_1
  key_name   = var.r3_global_prefix
  public_key = tls_private_key.r3_private_key.public_key_openssh
}

resource "local_file" "r3_private_key" {
  content  = tls_private_key.r3_private_key.private_key_pem
  filename = "r3_cert.pem"
}

resource "null_resource" "r3_private_key_permissions" {
  depends_on = [local_file.r3_private_key]
  provisioner "local-exec" {
    command     = "chmod 600 r3_cert.pem"
    interpreter = ["bash", "-c"]
    on_failure  = continue
  }
}