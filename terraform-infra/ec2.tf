# -----------------------------------------------------------------------
# Always fetch the latest Ubuntu 22.04 LTS AMI rather than hardcoding
# an AMI ID (AMI IDs are region-specific and change over time)
# -----------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------------------------------------------------
# Master node - runs the control plane (API server, etcd, scheduler,
# controller-manager) after we kubeadm init it in Phase 3
# -----------------------------------------------------------------------
resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.k8s_lab_public_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_cluster_sg.id]
  key_name               = aws_key_pair.k8s_lab_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.k8s_lab_instance_profile.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-master"
    Project = var.project_name
    Role    = "master"
  }
}

# -----------------------------------------------------------------------
# Worker node - runs application pods, joins the cluster via
# `kubeadm join` in Phase 3
# -----------------------------------------------------------------------
resource "aws_instance" "worker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.k8s_lab_public_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_cluster_sg.id]
  key_name               = aws_key_pair.k8s_lab_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.k8s_lab_instance_profile.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-worker"
    Project = var.project_name
    Role    = "worker"
  }
}
