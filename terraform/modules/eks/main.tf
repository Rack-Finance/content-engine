variable "aws_region" {
  description = "AWS region"
}

variable "cluster_name" {
  description = "EKS cluster name"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "eks_version" {
  description = "EKS cluster version"
  default     = "1.21"
}

variable "node_instance_type" {
  description = "Instance type for worker nodes"
  default     = "t3.micro"
}

variable "node_group_desired_size" {
  description = "Number of desired worker nodes"
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of worker nodes"
  default     = 2
}

variable "enable_public_access" {
  description = "Enable public access to the EKS cluster"
  default     = true
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  node_role_arn = aws_iam_role.eks_nodes.arn

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_desired_size
  }

  launch_template {
    version = "$Latest"
    id      = aws_launch_template.eks_nodes.id
  }

  subnet_ids = var.subnet_ids
}

resource "aws_launch_template" "eks_nodes" {
  name = "eks-nodes"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  instance_market_options {
    market_type = "spot"
  }

  instance_type = var.node_instance_type
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "eks_nodes" {
  name = "eks-nodes"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
