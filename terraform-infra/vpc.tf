# -----------------------------------------------------------------------
# Pick an availability zone automatically - keeps this portable across
# regions without hardcoding an AZ name.
# -----------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------------------------------------
# VPC - the isolated network both K8s nodes live in
# -----------------------------------------------------------------------
resource "aws_vpc" "k8s_lab_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------
# Single public subnet - both master and worker sit here. A real
# production cluster would split public/private subnets with a NAT
# gateway, but NAT gateways cost money by the hour even when idle,
# which defeats the "minimum bill" goal of this lab.
# -----------------------------------------------------------------------
resource "aws_subnet" "k8s_lab_public_subnet" {
  vpc_id                  = aws_vpc.k8s_lab_vpc.id
  cidr_block               = var.public_subnet_cidr
  availability_zone        = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch  = true

  tags = {
    Name    = "${var.project_name}-public-subnet"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------
# Internet gateway - lets the public subnet reach/be reached by the
# internet (needed for kubeadm to pull images, apt to install packages,
# and for you to SSH in / hit NodePort from outside)
# -----------------------------------------------------------------------
resource "aws_internet_gateway" "k8s_lab_igw" {
  vpc_id = aws_vpc.k8s_lab_vpc.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------
# Route table sending all outbound traffic (0.0.0.0/0) through the IGW
# -----------------------------------------------------------------------
resource "aws_route_table" "k8s_lab_public_rt" {
  vpc_id = aws_vpc.k8s_lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_lab_igw.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "k8s_lab_public_rta" {
  subnet_id      = aws_subnet.k8s_lab_public_subnet.id
  route_table_id = aws_route_table.k8s_lab_public_rt.id
}
