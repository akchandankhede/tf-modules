module "eks" {
  /* count = lenght(var.public_subnet) */
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "student-app-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  
  vpc_id                   = module.vpc.this_vpc
  subnet_ids               = module.vpc.public_subnet[*] #[module.vpc.public_subnet[0] , module.vpc.public_subnet[1]]
  control_plane_subnet_ids = module.vpc.public_subnet[*] #[module.vpc.public_subnet[0] , module.vpc.public_subnet[1]]
  
 eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 5
      desired_size = 1

      instance_types = ["t2.micro"]
      capacity_type  = "SPOT"
    }
  }
  tags = {
    Name = "student-app-cluster"
  }
}