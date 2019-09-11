variable "DEPLOY_FOLDER" {}

provider "opennebula" {
        endpoint = "${var.endpoint_url}"
        username = "${var.one_username}"
        password = "${var.one_password}"
}

data "template_file" "lokum-template" {
        template = "${file("opennebula_k8s.tpl")}"
}

resource "opennebula_template" "lokum-template" {
        name = "lokum-template"
        description = "${data.template_file.lokum-template.rendered}"
        permissions = "600"
}

resource "opennebula_vm" "lokum-node" {
        name = "lokum${count.index+1}"
        template_id = "${opennebula_template.lokum-template.id}"
        permissions = "600"
        count = "${var.number_of_nodes}"
}

resource "null_resource" "lokumcluster" {

        provisioner "local-exec" {
                command = "/bin/bash -c \"declare -a IPS=(${join(" ", opennebula_vm.lokum-node.*.ip)})\""
        }

        provisioner "local-exec" {
                command = "CONFIG_FILE=${var.DEPLOY_FOLDER}/hosts.yaml python3 /lokum/inventory_builder/inventory.py ${join(" ", opennebula_vm.lokum-node.*.ip)}"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -b --become-user=root -i ${var.DEPLOY_FOLDER}/hosts.yaml /lokum/config/ansible_playbooks/update_hosts_file.yml --private-key=${var.DEPLOY_FOLDER}/id_rsa_lokum_root.key -v"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -b --become-user=root -i ${var.DEPLOY_FOLDER}/hosts.yaml /lokum/config/ansible_playbooks/set_ssh_keys.yml --private-key=${var.DEPLOY_FOLDER}/id_rsa_lokum_root.key -v"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.DEPLOY_FOLDER}/hosts.yaml /lokum/config/ansible_playbooks/emma_fixes.yml --private-key=${var.DEPLOY_FOLDER}/id_rsa_lokum_root.key -v"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.DEPLOY_FOLDER}/hosts.yaml /lokum/config/ansible_playbooks/firewall.yml --private-key=${var.DEPLOY_FOLDER}/id_rsa_lokum_root.key -v"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False; cd /lokum; ansible all -b --become-user=root -i ${var.DEPLOY_FOLDER}/hosts.yaml -m ping --private-key=${var.DEPLOY_FOLDER}/id_rsa_lokum_root.key -v"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False; cd /lokum; ansible all -b --become-user=ubuntu -i ${var.DEPLOY_FOLDER}/hosts.yaml -m ping --private-key=${var.DEPLOY_FOLDER}/id_rsa_lokum_root.key -v"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False; cd /lokum/emma; ansible-playbook -i ${var.DEPLOY_FOLDER}/hosts.yaml -e datadisk=/dev/vdb -e host_name=${var.DEPLOY_FOLDER}/id_rsa_lokum_ubuntu prepcloud-playbook.yml --private-key=${var.DEPLOY_FOLDER}/id_rsa_lokum_ubuntu.key -v"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False; export CLUSTER_NAME=lokum; cd /lokum/emma/vars; sh ./create_vars_files.sh; cd /lokum/emma; ansible-playbook -i ${var.DEPLOY_FOLDER}/hosts.yaml --extra-vars 'CLUSTER_NAME=lokum' install_platform_light.yml --tags 'common,minio,hadoop,spark,dask' --skip-tags 'jupyterhub,pdal,geotrellis,cassandra,geomesa' --private-key=${var.DEPLOY_FOLDER}/id_rsa_lokum_ubuntu.key -v"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False; export CLUSTER_NAME=lokum; cd /lokum/emma/vars; sh ./create_vars_files.sh; cd /lokum/emma; ansible-playbook -i ${var.DEPLOY_FOLDER}/hosts.yaml --extra-vars 'CLUSTER_NAME=lokum' start_platform.yml --skip-tags 'jupyterhub,cassandra' --private-key=${var.DEPLOY_FOLDER}/id_rsa_lokum_ubuntu.key -v"
        }
}

output "lokum-node-vm_id" {
        value = "${opennebula_vm.lokum-node.*.id}"
}

output "lokum-node-vm_ip" {
        value = "${opennebula_vm.lokum-node.*.ip}"
}

