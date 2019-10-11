[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3482939.svg)](https://doi.org/10.5281/zenodo.3482939)

# Lokum

This repository includes scripts to deploy a cluster with GlusterFS, Docker, Spark and JupyterHub services on bare-metal. Currently, it only supports Opennebula platform.

Lokum uses [emma](https://github.com/nlesc-sherlock/emma) ansible playbooks to deploy services.

## Technologies & Tools

- [Terraform Client](https://www.terraform.io)
- [Runtastic Terraform Opennebula provider](https://github.com/runtastic/terraform-provider-opennebula)
- [Ansible](https://www.ansible.com/)
- [emma](https://github.com/nlesc-sherlock/emma)

## Usage

### 1-Pull the Docker image from Docker Hub

```bash
docker pull nlesc/lokum:latest
```

### 2-Settings

#### 2.1 VM configuration (template)

Edit **config/opennebula_k8s.tpl** to adjust the following VM settings:

    CPU = "2.0"
    VCPU = "2"
    IMAGE_ID = "YOUR_IMAGE_ID"
    MEMORY = "4096"
    NIC = [
      NETWORK = "INTERNAL_NETWORK_NAME",
      NETWORK_UNAME = "NETWORK_USERNAME" ]

There are two **SIZE** variables. The first one is for the cluster itselft and the second one is for the persistent storage. The default values are about 15G and 30G.

#### 2.2 Credentials

Edit **config/variables.tf** and set user credentials.

### 3-Deploy the cluster

```bash
docker run --rm --net=host -it \
  -v $(pwd)/config:/lokum/config \
  -v $(pwd)/deployment:/lokum/deployment \
  nlesc/lokum:latest
```

Confirm the planned changes by typing **yes**

Configuration and the ssh-keys of each deployed cluster will be stored under **deployment/clusterX** folder.

## Connecting to the nodes

### ssh to nodes

You can connect to the nodes using generated ssh keys. For example:

```bash
ssh -i ./deployment/cluster0/id_rsa_lokum_root.key root@SERVER_IP
or
ssh -i ./deployment/cluster0/id_rsa_lokum_ubuntu.key ubuntu@SERVER_IP
```

## TODO

- Fix repeated common tasks
- TASK [hadoop : Format namenode] FAILS for node1
  check config files in:
  /lokum/emma/roles/hadoop/templates
- fix minio_access_key and minio_secret_key in  /lokum/emma/vars/minio_vars.yml.template
- Update hadoop to 3.X.X  # in 3.2.0 hdfs starting procedure changed!
- Fix Cassandra:
  add GPG key --> A278B781FE4B2BDA
- Implement interactive deployment (ask user questions about the services)
- Make some services, for example GDAL, optional
- Fix emma roles that are installing packages using loop. Example:

```bash
- name: Install basic packages
  package:
    name: ['vim','bash-completion','tmux','tree','htop','wget','unzip','curl','git']
    state: present
```

- Setup a firewall
- Add an example for custom software deployment
- Add links and credits
