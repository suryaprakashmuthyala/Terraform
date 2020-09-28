variable "RG1" {
  default     = "eastusrg"
}
variable "location1" {
  default     = "East us"
}
variable "location2" {
  default     = "uk south"
}
variable "RG2" {
  default     = "ukrg"
}
variable "vnetus" {
  default     = "vnetus"
}
variable "subnetus" {
  default     = "subnetus"
}
variable "vnetuk" {
  default     = "vnetuk"
}
variable "subnetuk" {
  default     = "subnetuk"
}
variable "numbercount" {
    type 	  = number
    default       = 2
}
variable "USNSG" {
  default     = "USNSG"
}
variable "UKNSG" {
  default     = "UKNSG"
}
variable "usavset" {
  default     = "usavset"
}
variable "ukavset" {
  default     = "ukavset"
}
variable "USALB" {
  default     = "USALB"
}
variable "LBFrontEndIP" {
  default     = "PrivateIPAddress"
}
variable "USABackendPool" {
  default     = "USABackendPool"
}
variable "USLBNATpool" {
  default     = "USLBNATpool"
}
variable "USLBprobe" {
  default     = "USLBprobe"
}
variable "UkLB" {
  default     = "UkLB"
}
variable "UKLBFrontEndIP" {
  default     = "UKLBFrontEndIP"
}
variable "UKBackendPool" {
  default     = "UKBackendPool"
}
variable "UKLBNATpool" {
  default     = "UKLBNATpool"
}
variable "UKLBprobe" {
  default     = "UKLBprobe"
}
variable "adminusername" {
  default     = "azureuser"
}
variable "adminpassword" {
  default     = "C0mpl3xP@ssw0rd"
}
