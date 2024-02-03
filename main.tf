


terraform {
  required_version = ">= 1.2.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.10.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "491e1121-c626-46e3-98ba-98f9f0434964"
  tenant_id       = "2047b1bd-994d-4366-9d87-647dac583343"
  client_id       = "a78d2362-7c1d-475b-b06c-683634019705"
  client_secret   = "aSR8Q~UzW_2fWfpMnAHLnY~04qdEl~tjRbS0XbUB"
}



data "azurerm_resource_group" "example" {
  name = "8pmbatch-RG"

}


resource "azurerm_virtual_network" "example" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "Southeast Asia"
  resource_group_name = data.azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "mySubnet"
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "example" {
  name                = "myNSG"
  location            = "Southeast Asia"
  resource_group_name = data.azurerm_resource_group.example.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  count                       = length(var.security_group_rule)
  name                        = var.security_group_rule[count.index].name
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
  priority                    = var.security_group_rule[count.index].priority
  destination_port_range      = var.security_group_rule[count.index].destination_port_range

}





resource "azurerm_public_ip" "pip" {
  count               = 2
  name                = "${count.index}-pip"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = "Southeast Asia"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "example" {
  count               = 2
  name                = "myNIC1-${count.index}"
  location            = "Southeast Asia"
  resource_group_name = data.azurerm_resource_group.example.name


  ip_configuration {
    name                          = "myNIC-${count.index}-config"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  count                     = 2
  network_interface_id      = azurerm_network_interface.example[count.index].id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_linux_virtual_machine" "example" {
  count               = 2
  name                = "myVM-${count.index}"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = "Southeast Asia"
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  # admin_password       = "Password1234!"
  # disable_password_authentication = false
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.example[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name = "myVM-${count.index}"
  custom_data   = base64encode(data.template_file.linux-vm-cloud-init.rendered)

  provisioner "local-exec" {
    command = "echo ${self.public_ip_address} >> inventory"
  }


  # provisioner "local-exec" {
  #   command = "sleep 150"
  # }

  # provisioner "local-exec" {
  #   command = "ansible all -m shell -a 'apt -y install apache2; systemctl restart httpd'"
  # }

  #  provisioner "file" {
  #     source = "AbbottCampaign.sql"
  #     destination = "/tmp/AbbottCampaign.sql"
  #     connection {
  #     host = self.public_ip_address
  #     user = "adminuser"
  #     type = "ssh"
  #     private_key = file("~/.ssh/id_rsa")
  #     timeout = "2m"
  #     agent = false
  # }
  # }

  #  connection {
  #     host = self.public_ip_address
  #     user = "adminuser"
  #     type = "ssh"
  #     private_key = file("~/.ssh/id_rsa")
  #     timeout = "2m"
  #     agent = false
  # }


  # provisioner "remote-exec" {
  #     inline = [
  #       "sudo apt-get update",
  #       "sudo apt-get install docker.io -y",
  #       "git clone https://github.com/regspweek41/docker-reactjs.git",
  #       "cd docker-reactjs",
  #       "sudo docker build -t mywebapp .",
  #       "sudo docker run -d -p 80:80 mywebapp"
  #     ]
  # }

depends_on           = [azurerm_public_ip.pip]

}

  resource "null_resource" "remoteExecProvisioner" {

    triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
     command = "ansible all -m shell -a 'apt -y install apache2' -u adminuser"
   #command = "ansible-playbook './ansible-playbook-with-items.yaml' -u adminuser"
  }
     depends_on           = [azurerm_linux_virtual_machine.example]

  }

#   connection {
#     host     = "${azurerm_virtual_machine.vm.ip_address}"
#     type     = "ssh"
#     user     = "${var.admin_username}"
#     password = "${var.admin_password}"
#     agent    = "false"
#   }
# }

data "template_file" "linux-vm-cloud-init" {
  template = file("install.sh")
}
