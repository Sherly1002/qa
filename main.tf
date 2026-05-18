# 1. Create the base Resource Group for all deployment assets
resource "azurerm_resource_group" "network_rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Create the Virtual Network (VNet) boundary
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.prefix}-001"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
}

# 3. Partition a Subnet within the Virtual Network
resource "azurerm_subnet" "subnet" {
  name                 = "snet-${var.prefix}-001"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Uses the first available /24 block inside your 10.0.0.0/16 address space
  address_prefixes     = [cidrsubnet(var.vnet_address_space[0], 8, 1)] 
}

# 4. Allocate a Dynamic Public IP Address to connect to your VM
resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.prefix}-vm-01"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# 5. Build the Network Interface Card (NIC) mapped to your VM configuration
resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.prefix}-vm-01"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  ip_configuration {
    name                          = "internal-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
# 6. Generate an SSH Key Pair for Secure VM Authentication
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 7. Create the Confidential Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${var.prefix}-linux-01"
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location
  
  # CRITICAL: Your exact requested VM hardware configuration size
  size                = "Standard_DC1ds_v3"
  
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  # CRITICAL: Mandatory security configuration profile required for the DC-series hardware
  secure_boot_enabled = true
  vtpm_enabled        = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    # CRITICAL: Gen2 image layout is required for this specific hardware tier
    sku       = "22_04-lts-gen2" 
    version   = "latest"
  }
}

# Optional: Output your generated private SSH key to the console logs so you can connect to it
output "tls_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
