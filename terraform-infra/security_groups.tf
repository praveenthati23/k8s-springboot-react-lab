resource "aws_security_group" "k8s_cluster_sg" {
  name        = "${var.project_name}-cluster-sg"
  description = "Security group for the kubeadm master and worker nodes"
  vpc_id      = aws_vpc.k8s_lab_vpc.id

  # SSH - locked to your IP only, not the whole internet
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  # Kubernetes API server - locked to your IP so you can run kubectl
  # from your laptop against the cluster
  ingress {
    description = "Kubernetes API server from my IP"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  # NodePort range - open to everyone, since this is how you'll actually
  # browse the deployed frontend/backend in a browser (no load balancer
  # in this lab, to keep cost at zero)
  ingress {
    description = "Kubernetes NodePort services - public app access"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All traffic between the master and worker themselves - covers etcd
  # (2379-2380), kubelet API (10250), controller-manager/scheduler
  # (10257/10259), and the Flannel VXLAN overlay (UDP 8472), without
  # enumerating each one individually. Safe because this only applies
  # to traffic between members of this same security group, not the
  # open internet.
  ingress {
    description = "All traffic between cluster nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Standard unrestricted egress - nodes need to reach apt repos,
  # container registries, etc.
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-cluster-sg"
    Project = var.project_name
  }
}
