variable "location" {
  description = "Datacenter location to deploy the VM into"
  default     = "westeurope"
}

variable "vm_name" {
  description = "Name of the virtual machine (acts as prefix for all generated resources)"
  default     = "dsvm"
}

variable "admin_user" {
  description = "Admin username"
  default     = "root"
}

variable "admin_key" {
  description = "Public SSH key of the admin user"
}

variable "vm_type" {
  description = "The type of VM to deploy"
  default     = "Standard_NC6"
}

resource "azurerm_resource_group" "ds" {
  name     = "${var.vm_name}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "ds" {
  name                = "${var.vm_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.ds.location}"
  resource_group_name = "${azurerm_resource_group.ds.name}"
}

resource "azurerm_subnet" "ds" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = "${azurerm_resource_group.ds.name}"
  virtual_network_name = "${azurerm_virtual_network.ds.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "ds" {
  name                = "${var.vm_name}-ni"
  location            = "${azurerm_resource_group.ds.location}"
  resource_group_name = "${azurerm_resource_group.ds.name}"

  ip_configuration {
    name                          = "${var.vm_name}-cfg"
    subnet_id                     = "${azurerm_subnet.ds.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.ds.id}"
  }
}

resource "azurerm_virtual_machine" "ds" {
  name                             = "${var.vm_name}-vm"
  location                         = "${azurerm_resource_group.ds.location}"
  resource_group_name              = "${azurerm_resource_group.ds.name}"
  network_interface_ids            = ["${azurerm_network_interface.ds.id}"]
  vm_size                          = "${var.vm_type}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  plan {
    name      = "linuxdsvmubuntu"
    publisher = "microsoft-ads"
    product   = "linux-data-science-vm-ubuntu"
  }

  storage_image_reference {
    publisher = "microsoft-ads"
    offer     = "linux-data-science-vm-ubuntu"
    sku       = "linuxdsvmubuntu"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "${var.vm_name}-data"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
    lun               = 0
    disk_size_gb      = "120"
  }

  os_profile {
    computer_name  = "${var.vm_name}"
    admin_username = "${var.admin_user}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys = [{
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = "${var.admin_key}"
    }]
  }

  tags {
    environment = "datascience-vm, ${var.vm_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo HELLO > test.txt",
    ]
  }
}

# create a public IP to bind against the VM
resource "azurerm_public_ip" "ds" {
  name                         = "${var.vm_name}-ip"
  location                     = "${azurerm_resource_group.ds.location}"
  resource_group_name          = "${azurerm_resource_group.ds.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "datascience-vm, ${var.vm_name}"
  }
}

# dump reference to public IP and VM ID to local files; if anything changes just re-run terraform apply to re-generate the files locally
resource "null_resource" "ds" {
  triggers = {
    vm_id      = "${azurerm_virtual_machine.ds.id}"
    ip_address = "${azurerm_public_ip.ds.ip_address}"
  }

  provisioner "local-exec" {
    command = "echo ${azurerm_virtual_machine.ds.id} > .vm-id"
  }

  provisioner "local-exec" {
    command = "echo ${var.admin_user}@${azurerm_public_ip.ds.ip_address} > .vm-ip"
  }
}
