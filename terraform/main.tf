module "custom_eks" {
  source = "./modules/eks"

  aws_region   = "us-east-1"
  cluster_name = "eks_cluster"
  vpc_id       = "vpc-1234556abcdef"
  subnet_ids   = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
}