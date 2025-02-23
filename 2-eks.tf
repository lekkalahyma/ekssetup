module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name    = "dev-demo"
  cluster_version = "1.27"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    custom-nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      launch_template = {
        id      = aws_launch_template.custom_eks_nodes.id
        version = "$Latest"
      }
    }
  }
}

resource "aws_launch_template" "custom_eks_nodes" {
  name_prefix   = "custom-eks-node"
  image_id      = "ami-0f833bfd6b4d04446"  # Replace with your custom AMI ID
  instance_type = "t3.medium"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-node"
    }
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    /etc/eks/bootstrap.sh dev-demo
  EOT
  )
}