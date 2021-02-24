output "hostname_1" {
  value = module.jenkins-vm2.instance_name
}

output "public_ip_1" {
  value = module.jenkins-vm2.instance_ip_addr
}

output "hostname_2" {
  value = module.web-deploy-vm2.instance_name
}

output "public_ip_2" {
  value = module.web-deploy-vm2.instance_ip_addr
}