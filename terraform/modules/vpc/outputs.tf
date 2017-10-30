output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_igw" {
  value = "${aws_internet_gateway.igw.id}"
}
