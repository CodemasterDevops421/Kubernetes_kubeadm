output "master_public_ip" {
  description = "Public IP of the master node"
  value       = aws_instance.control-plane.public_ip
}

output "worker_public_ip" {
  description = "Public IP of the worker node"
  value       = aws_instance.worker-node.public_ip
}
