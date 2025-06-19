resource "random_id" "random" {
  byte_length = 4
  
}

resource "aws_eks_cluster" "eks" {
  name = "eks-${random_id.random.hex}"
  role_arn = aws_iam_role.eks-cluster-role.arn
  

  vpc_config {
    subnet_ids =[aws_subnet.EKS_Pub_Sub.id, aws_subnet.EKS_Pub_Sub-1.id]
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
    cluster_name = aws_eks_cluster.eks.id
    node_group_name = "${random_id.random.hex}-managed_node"
    node_role_arn = aws_iam_role.EKS-nodegroup-role.arn
    subnet_ids = [aws_subnet.EKS_Pub_Sub.id, aws_subnet.EKS_Pub_Sub-1.id]
    scaling_config {
      desired_size = 3
      min_size = 2
      max_size = 5
      

    }

    instance_types = ["t3.xlarge"]
    capacity_type = "ON_DEMAND"

    update_config {
      max_unavailable = 1

    }


    tags = {
      "Name" = "${random_id.random.hex}-ondemand-nodes"

    
  }

    depends_on = [ 
    aws_eks_cluster.eks, 
    aws_subnet.EKS_Pub_Sub,
    aws_subnet.EKS_Pub_Sub-1,
    aws_security_group.sg_id,
    aws_iam_role_policy_attachment.AmazonEKSpolicy
    ]
  
}