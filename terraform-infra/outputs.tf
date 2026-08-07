output "master_public_ip" {
  description = "Public IP of the master node"
  value       = aws_instance.master.public_ip
}

output "master_private_ip" {
  description = "Private IP of the master node (used by the worker to join the cluster)"
  value       = aws_instance.master.private_ip
}

output "worker_public_ip" {
  description = "Public IP of the worker node"
  value       = aws_instance.worker.public_ip
}

output "worker_private_ip" {
  description = "Private IP of the worker node"
  value       = aws_instance.worker.private_ip
}

output "ssh_master_command" {
  description = "Ready-to-use SSH command for the master node"
  value       = "ssh -i ~/.ssh/k8s-lab-key ubuntu@${aws_instance.master.public_ip}"
}

output "ssh_worker_command" {
  description = "Ready-to-use SSH command for the worker node"
  value       = "ssh -i ~/.ssh/k8s-lab-key ubuntu@${aws_instance.worker.public_ip}"
}
