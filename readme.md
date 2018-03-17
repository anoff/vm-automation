# manage deep learning VM with GPU on Azure ☁️

<!-- TOC depthFrom:2 -->

- [Installation 📦](#installation-)
    - [Prerequisites 🛠](#prerequisites-🛠)
    - [Sign the terms of service ⚖️](#sign-the-terms-of-service-)
    - [Initialize Terraform 🌏](#initialize-terraform-)
- [Configuration ⚙️](#configuration-)
- [Usage 📖](#usage-)
    - [Create or **permanently** delete the Virtual Machine 🆙 🚫](#create-or-permanently-delete-the-virtual-machine--)
    - [Work with the machine 👩‍💻](#work-with-the-machine-‍)
- [Install cuDNN](#install-cudnn)

<!-- /TOC -->

## Installation 📦

First copy the content of this repository into the folder from where you want to manage the VM.

### Prerequisites 🛠

First make sure you have some prerequisites installed:

- [ ] [Terraform](https://www.terraform.io/downloads.html) for infrastructure provisioning
- [ ] [azure cli 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) as provider for terraform and to interact with the VM
- [ ] [make](http://gnuwin32.sourceforge.net/packages/make.htm) as simple cross-platform scripting solution

### Sign the terms of service ⚖️

The Data Science VM on Azure is offered via the Marketplace and therefore has specific terms of service. Before this offering can be automatically deployed via Terraform you need to accept the license agreement for your subscription. This can be done via **PowerShell**. Easiest way to use powershell is open the Cloudshell on the [Azure Portal](http://portal.azure.com)

<img src="./assets/azure_cloudshell.png" width="80%"><br>
_Open the Cloudshell by clicking the `>_` icon in the top right_

<img src="./assets/azure_powershell.png" width="50%"><br>
_Once open select `PowerShell` as environment_

```powershell
# Use this command to view the current license agreement
Get-AzureRmMarketplaceTerms -Publisher "microsoft-ads" -Product "windows-data-science-vm" -Name "linuxdsvmubuntu"

# If you feel confident to agree to the agreement use the following command to enable the offering for your subscription
Get-AzureRmMarketplaceTerms -Publisher "microsoft-ads" -Product "windows-data-science-vm" -Name "linuxdsvmubuntu" | Set-AzureRmMarketplaceTerms -Accept
```
<img src="./assets/azure_sign_terms.png" width="80%"><br>
_Final output should look like this_

### Initialize Terraform 🌏

Before you can use the Terraform recipe you need to initialize it by running

```sh
terraform init
```

## Configuration ⚙️

To customize the VM deployment you should edit the `config.auto.tfvars` file in this directory. The only mandatory variable you need to provide is `admin_key` which should be a publich SSH key that will be used to connect to the Virtual Machine. See [this explanation](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) on how to create a SSH Key pair if you do not have one.

Just uncomment the variables you want to overwrite. If you want to customize other things feel free to [submit an issue](https://github.com/anoff/vm-automation/issues/new) or look into the way [variables work in terraform](https://www.terraform.io/docs/configuration/variables.html).

## Usage 📖

### Create or **permanently** delete the Virtual Machine 🆙 🚫

```sh
# create a new data scientist VM on a GPU machine
terraform apply

# kill the entire VM
terraform destroy -force
```

When running the terraform command, two new files will be created. `.vm-id` will hold the unique Azure Resource ID of the VM that is used to start/stop it as well as `.vm-ip` that is the public IP address of the VM. The IP is static which means it will not change if you start/stop the machine. 

> Note: When stopping the VM either use `make stop` or `az vm deallocate`. `az vm stop` wil **NOT** deallocate the machine, that means you still have to pay for the compute resources.

### Work with the machine 👩‍💻

```sh
# link the Makefile to your main directory and then run the following commands

make start # to start the VM

make stop # to deallocate it (no more costs for the compute resource)

make ssh # SSH into the machine and port forward 8888 so you can just run 'jupyter notebook' on the VM and open it on your local machine

make syncup # copy your local directory to the VM

make syncdown # copy any changes you made on the remote system over to your local directory 🚨 WARNING: OVERWRITES LOCAL CHANGES
```

## Install cuDNN

> 🚨 Note: I think the download is unnecessary as the cuDNN directory already exists under `usr/local/cuda-8-cuddn-5` but is not correctly linked.

The Data Science VM might lack the Cuda Deep Neural Net framework. To install it download it from the [nVidia website](https://developer.nvidia.com/rdp/cudnn-download) (needs a free dev account) for your Cuda version (`nvcc --version`) and follow [this blogpost](https://aboustati.github.io/How-to-Setup-a-VM-in-Azure-for-Deep-Learning/) for the installation. You might need cUDNN 5.0.

