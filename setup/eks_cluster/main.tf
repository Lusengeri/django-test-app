terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.14.0"
    }
  }
}

resource "aws_vpc" "vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "10.0.0.0/16"

  tags = {
    env      = "development"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    env = "development"
  }
}

resource "aws_subnet" "public_subnet_1" {
  availability_zone       = "us-west-2a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc.id

  tags = {
    env      = "development"
    #"kubernetes.io/cluster/${aws_eks_cluster.my_cluster.name}" = "shared"
  }
}

resource "aws_subnet" "public_subnet_2" {
  availability_zone       = "us-west-2b"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc.id

  

  tags = {
    env      = "development"
    #"kubernetes.io/cluster/${aws_eks_cluster.my_cluster.name}" = "shared"
  }
}

resource "aws_subnet" "private_subnet_1" {
  availability_zone       = "us-west-2a"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false 
  vpc_id                  = aws_vpc.vpc.id

  tags = {
    env      = "development"
  }
}

resource "aws_subnet" "private_subnet_2" {
  availability_zone       = "us-west-2a"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.vpc.id

  tags = {
    env      = "development"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  depends_on = [ aws_internet_gateway.internet_gateway ]

  route {
    cidr_block         = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    env = "development"
  }
}

resource "aws_route_table_association" "public_rt_association_1" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_1.id
}

resource "aws_route_table_association" "public_rt_association_2" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_2.id
}

resource "aws_security_group" "cluster_sg" {
  name = "cluster-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "allow HTTP connections from the internet"
    protocol = "tcp"
    from_port = 80 
    to_port = 80 
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow HTTPS connections from the internet"
    protocol = "tcp"
    from_port = 443 
    to_port = 443 
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cluster-security-group"
    env = "development"
  }
}

resource "aws_security_group" "control_plane_sg" {
  name = "cp-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "control-plane-security-group"
    env = "development"
  }
}

resource "aws_security_group" "db_sg" {
  name = "db_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "allow cluster security group to connect to database"
    protocol = "tcp"
    from_port = 5432 
    to_port = 5432 
    security_groups = [ aws_security_group.cluster_sg.id ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "database-security-group"
  }
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type = "Service"
      identifiers = [ "eks.amazonaws.com"]
    }
  }  
}

resource "aws_iam_role" "eks_role" {
  name               = "eks-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json

  inline_policy {
    name = "eks_autoscaling_balancing_policy"

    policy = <<EOP
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:UpdateAutoScalingGroup",
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateRoute",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteRoute",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteVolume",
                "ec2:DescribeInstances",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVpcs",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DetachVolume",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyVolume",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeInternetGateways",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
                "elasticloadbalancing:AttachLoadBalancerToSubnets",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:CreateLoadBalancerPolicy",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancerListeners",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeLoadBalancerPolicies",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DetachLoadBalancerFromSubnets",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
                "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        }
    ]
}
EOP
  }
}

resource "aws_iam_role" "node_role" {
  name = "node_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

resource "aws_eks_cluster" "my_cluster" {
  name       = "my_cluster"
  #role_arn   = aws_iam_role.eks_role.arn
  role_arn = "arn:aws:iam::940482447799:role/eks-Cluster-Role"

  vpc_config {
    security_group_ids = [ aws_security_group.control_plane_sg.id ] 
    subnet_ids = [ aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id ]
  }

  tags = {
    env      = "development"
  }
}

resource "aws_eks_node_group" "worker_node_group" {
  cluster_name = aws_eks_cluster.my_cluster.name
  node_group_name = "worker-node-group"
  node_role_arn = aws_iam_role.node_role.arn 
  subnet_ids = [ aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id ]

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]

  remote_access {
    ec2_ssh_key = "ore-key"
  }

  scaling_config {
    desired_size = 1
    max_size = 1
    min_size = 1
  }

  tags = {
    env      = "development"
  }
}

output "cluster_endpoint" {
  value = aws_eks_cluster.my_cluster.endpoint 
}