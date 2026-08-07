# -----------------------------------------------------------------------
# IAM role the EC2 nodes assume, so kubelet/containerd can pull images
# from ECR using the instance's identity instead of static credentials
# baked into the box (this is the standard, secure pattern - no AK/SK
# ever touch the EC2 instances themselves)
# -----------------------------------------------------------------------
resource "aws_iam_role" "k8s_lab_ec2_role" {
  name = "k8s-lab-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "k8s-lab-ec2-role"
    Project = var.project_name
  }
}

# AWS-managed policy that grants read-only ECR access - exactly what
# the nodes need to pull images, nothing more (they never push)
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.k8s_lab_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "k8s_lab_instance_profile" {
  name = "k8s-lab-instance-profile"
  role = aws_iam_role.k8s_lab_ec2_role.name
}
