# resource "random_id" "random" {
#   byte_length = 4
# }

resource "aws_eks_cluster" "eks" {
  name     = var.eks_name
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    subnet_ids = [
      data.aws_subnet.subnet_a.id,
      data.aws_subnet.subnet_b.id,
      data.aws_subnet.subnet_c.id
    ]
    security_group_ids = [aws_security_group.sg_id.id]
  }

  access_config {
    authentication_mode = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
}

resource "aws_iam_openid_connect_provider" "eks-oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_certificate.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks_certificate.url
}


resource "aws_eks_node_group" "eks_managed_node" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${random_id.random.hex}-managed-node"
  node_role_arn   = aws_iam_role.EKS-nodegroup-role.arn

  subnet_ids = [
    data.aws_subnet.subnet_a.id,
    data.aws_subnet.subnet_b.id,
    data.aws_subnet.subnet_c.id
  ]

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  remote_access {
    ec2_ssh_key = "decc-dev"
  }

  instance_types = var.instance_types
  capacity_type  = "ON_DEMAND"

  update_config {
    max_unavailable = 1
  }

  tags = {
    "Name" = "${var.eks_name}-ondemand-nodes"
  }

  depends_on = [
    aws_eks_cluster.eks,
    aws_security_group.sg_id,
    aws_iam_role_policy_attachment.AmazonEKSpolicy
  ]
}
