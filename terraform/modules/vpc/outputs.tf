output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_igw" {
  value = "${aws_internet_gateway.igw.id}"
}

output "public_subnet_ids" {
  value = [ "${aws_subnet.public.*.id}" ]
}

output "private_subnet_ids" {
  value = [ "${aws_subnet.private.*.id}" ]
}

output "private_egress_subnet_ids" {
  value = [ "${aws_subnet.private_egress.*.id}" ]
}

