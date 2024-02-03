
variable "security_group_rule"{
  type = list(object({
    name = string
  priority                    = number
  destination_port_range      = string
    }))
  
  default = [
    {
        name = "port-22"
     priority                    = 1001
  destination_port_range      = "22"
  },
  {
    name = "port-80"
     priority                    = 1002
  destination_port_range      = "80"
  }]
 
}