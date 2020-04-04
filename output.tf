output "hostname_1" {
    value = "${module.jenkins-vm.instance_name}"
}

output "public_ip_1" {
    value ="${module.jenkins-vm.instance_ip_addr}"
}

output "hostname_2" {
    value = "${module.web-deploy-vm.instance_name}"
}

output "public_ip_2" {
    value ="${module.web-deploy-vm.instance_ip_addr}"
}