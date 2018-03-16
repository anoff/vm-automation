# manage deep learning VM with GPU on Azure ☁️

## create a new resource

- install terraform
- install azure cli

```sh
# create a new data scientist VM on a GPU machine
terraform apply

# kill the entire VM
terraform destroy -force
```

When running the terraform command, two new files will be created. `.vm-id` will hold the unique Azure Resource ID of the VM that is used to start/stop it as well as `.vm-ip` that is the public IP address of the VM. The IP is static which means it will not change if you start/stop the machine. 

> Note: When stopping the VM either use `make stop` or `az vm deallocate`. `az vm stop` wil **NOT** deallocate the machine, that means you still have to pay for the compute resources.

## Install cuDNN

> 🚨 Note: I think the download is unnecessary as the cuDNN directory already exists under `usr/local/cuda-8-cuddn-5` but is not correctly linked.

The Data Science VM might lack the Cuda Deep Neural Net framework. To install it download it from the [nVidia website](https://developer.nvidia.com/rdp/cudnn-download) (needs a free dev account) for your Cuda version (`nvcc --version`) and follow [this blogpost](https://aboustati.github.io/How-to-Setup-a-VM-in-Azure-for-Deep-Learning/) for the installation. You might need cUDNN 5.0.

## Work with the machine

```sh
# link the Makefile to your main directory and then run the following commands

make start # to start the VM

make stop # to deallocate it (no more costs for the compute resource)

make ssh # SSH into the machine and port forward 8888 so you can just run 'jupyter notebook' on the VM and open it on your local machine
```