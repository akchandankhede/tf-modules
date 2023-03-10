variable "vpc_cidr_block" {
  type = string #required 
}
variable "public_cidr_block" {
  type = list(any) #required
}
variable "private_cidr_block" {
  type = list(any) #required
}
variable "availability_zones" {
  type = list(string) #required
}
variable "env" {
  type = string #required

}
variable "appname" {
  type = string #required
}
variable "tags" {
  type    = map(string)
  default = {}
}
