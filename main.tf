provider "aws" {
  region = "eu-central-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.kubeconfig_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.kubeconfig_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    exec_timeout          = "600s"
  }
}

resource "time_sleep" "wait_for_cluster" {
  depends_on = [module.eks]
  create_duration = "120s"
}


resource "null_resource" "wait_for_cluster" {
  depends_on = [module.eks]
}

module "jenkins" {
  source = "./modules/jenkins"

  environment     = "dev"
  cluster_name    = module.eks.cluster_name
  ecr_repository  = module.ecr.repository_url
  storage_class   = module.eks.storage_class_name

  depends_on = [
    time_sleep.wait_for_cluster,
    module.eks
  ]
}

# Додаємо дата-блок для отримання токену автентифікації
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

module "s3_backend" {
  source             = "./modules/s3_backend"
  bucket_name        = "terraform-state-ivan-yanchyk-lesson5-dev"
  dynamodb_table_name = "terraform-locks"
  environment        = "dev"
}

# Модуль VPC
module "vpc" {
  source = "./modules/vpc"

  environment          = "dev"
  vpc_cidr            = "10.0.0.0/16"
  cluster_name        = "lesson-6-cluster"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones   = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

# Модуль ECR
module "ecr" {
  source          = "./modules/ecr"
  environment     = "dev"
  repository_name = "lesson-5-app"
  scan_on_push    = true
}

# Модуль EKS
module "eks" {
  source = "./modules/eks"

  environment         = "dev"
  cluster_name       = "lesson-6-cluster"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

