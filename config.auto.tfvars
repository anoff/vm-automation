# Path to Public SSH key of the admin user (required)
admin_public_key = "~/.ssh/id_rsa.pub"

# Path to Private SSH key of the admin user (required)
admin_private_key = "~/.ssh/id_rsa"

# Datacenter location to deploy the VM into (default: westeurope)
location    = "westus2"

# Name of the virtual machine (acts as prefix for all generated resources, default: dsvm)"
vm_name     = "<your-name>-<project-name>"

# Admin username (default: root)
admin_user = "<your-first-name>"

# Type of VM to deploy (default: Standard_NC6 - GPU instance)
# other gpu instance types 
## https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-gpu
# other non-gpu instance types (use general purpose instances if you don't need gpu) 
## https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general
vm_type = "Standard_NC6"

