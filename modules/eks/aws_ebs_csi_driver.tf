# Data sources
data "aws_caller_identity" "current" {}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# OIDC Provider для EKS
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# IAM Policy для EBS CSI Driver
resource "aws_iam_policy" "ebs_csi_policy" {
  name        = "${var.environment}-AmazonEKS_EBS_CSI_Driver_Policy"
  description = "EBS CSI policy for EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:ModifyVolume",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:DeleteSnapshot"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["ec2:CreateTags"]
        Resource = [
          "arn:aws:ec2:*:*:volume/*",
          "arn:aws:ec2:*:*:snapshot/*"
        ]
        Condition = {
          StringEquals = {
            "ec2:CreateAction" = [
              "CreateVolume",
              "CreateSnapshot"
            ]
          }
        }
      }
    ]
  })
}

# IAM Role для EBS CSI Driver
resource "aws_iam_role" "ebs_csi_role" {
  name = "${var.environment}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Прикріплення Policy до Role
resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attachment" {
  policy_arn = aws_iam_policy.ebs_csi_policy.arn
  role       = aws_iam_role.ebs_csi_role.name
}

# EBS CSI Driver як аддон EKS
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version              = "v1.20.0-eksbuild.1"
  service_account_role_arn    = aws_iam_role.ebs_csi_role.arn
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_policy_attachment
  ]
}

# Storage Class для EBS
resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }

  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  reclaim_policy     = "Delete"

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [aws_eks_node_group.main]
}

# Коментуємо EBS CSI addon тимчасово, оскільки він вже існує
# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name = aws_eks_cluster.main.name
#   addon_name   = "aws-ebs-csi-driver"

#   service_account_role_arn = aws_iam_role.ebs_csi_role.arn

#   depends_on = [
#     aws_iam_role_policy_attachment.ebs_csi_policy_attachment
#   ]
# }

# Встановлюємо цей StorageClass як default
resource "kubernetes_annotations" "gp2" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = true

  metadata {
    name = "gp2"
  }

  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  depends_on = [kubernetes_storage_class.ebs_sc]
}

resource "kubernetes_annotations" "ebs_sc" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = true

  metadata {
    name = kubernetes_storage_class.ebs_sc.metadata[0].name
  }

  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "true"
  }

  depends_on = [kubernetes_annotations.gp2]
}