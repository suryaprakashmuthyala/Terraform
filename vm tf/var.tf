variable "ResourceGroup" {
  description = "Resource Group"
  default     = "Terraform_MultipleVM"
}
variable "Location" {
  description = "Location"
  default     = "East US"
}

variable "VirtualNetwork" {
  default     = "terraformmultivnet"
}
variable "Subnet" {
  default     = "Subnet1"
}
variable "StorageAccount" {
  default     = "satf23092020multivm"
}
variable "PublicIP" {
  default     = "PIP"
}
variable "NSG" {
  default     = "NSG"
}
variable "NIC" {
  default     = "NIC"
}
variable "VM1" {
  default     = "vm1"
}
variable "admin_username" {
  default     = "azureuser"
}
variable "admin_password" {
  default     = "C0mpl3xP@ssw0rd"
}

variable "numbercount" {
    type 	  = number
    default       = 2
}
variable "AvailabilitySet" {
  default     = "avset"
}
