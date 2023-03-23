output "public_subnet" {
  value = aws_subnet.public[*].id
}
output "private_subnet" {
  value = aws_subnet.private[*].id
}

output "this_vpc" {
  value = aws_vpc.this.id
}