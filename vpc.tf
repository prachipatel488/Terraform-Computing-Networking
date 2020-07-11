# ---  Create a VPC ------


resource "aws_vpc" "terravpc1" {
  cidr_block       = "10.10.0.0/16"
  tags = {
    Name = "terravpc1"
  }
}
#--- Create Internet Gateway


resource "aws_internet_gateway" "terravpc1_igw" {
 vpc_id = "${aws_vpc.terravpc1.id}"
 tags = {
    Name = "terravpc1-igw"
 }
}
# - Create Elastic IP


resource "aws_eip" "eip" {
  vpc=true
}
# -- Create Subnet


data "aws_availability_zones" "azs" {
  state = "available"
}
#  create public subnet


resource "aws_subnet" "Public-subnet-1" {
  availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  cidr_block        = "10.10.20.0/24"
  vpc_id            = "${aws_vpc.terravpc1.id}"
  map_public_ip_on_launch = "true"
  tags = {
   Name = "Public-subnet-1"
   }
}

resource "aws_subnet" "Public-subnet-2" {
  availability_zone = "${data.aws_availability_zones.azs.names[1]}"
  cidr_block        = "10.10.21.0/24"
  vpc_id            = "${aws_vpc.terravpc1.id}"
  map_public_ip_on_launch = "true"
  tags = {
   Name = "Public-subnet-2"
   }
}
#  Create private subnet


resource "aws_subnet" "Private-subnet-1" {
  availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  cidr_block        = "10.10.30.0/24"
  vpc_id            = "${aws_vpc.terravpc1.id}"
  tags = {
   Name = "Private-subnet-1"
   }
}


resource "aws_subnet" "Private-subnet-2" {
  availability_zone = "${data.aws_availability_zones.azs.names[1]}"
  cidr_block        = "10.10.31.0/24"
  vpc_id            = "${aws_vpc.terravpc1.id}"
  tags = {
   Name = "Private-subnet-2"
   }
}
# --------------  NAT Gateway

resource "aws_nat_gateway" "terravpc1-ngw" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id = "${aws_subnet.Public-subnet-1.id}"
  tags = {
      Name = "TerraVPC1 Nat Gateway"
  }
}
# ------------------- Routing ----------


resource "aws_route_table" "terravpc1-public-route" {
  vpc_id =  "${aws_vpc.terravpc1.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.terravpc1_igw.id}"
  }

   tags = {
       Name = "terravpc1-public-route"
   }
}
resource "aws_default_route_table" "terrvpc1-default-route" {
  default_route_table_id = "${aws_vpc.terravpc1.default_route_table_id}"
  tags = {
      Name = "terrvpc1-default-route"
  }
}
#--- Subnet Association -----

resource "aws_route_table_association" "arts1" {
  subnet_id = "${aws_subnet.Public-subnet-1.id}"
  route_table_id = "${aws_route_table.terravpc1-public-route.id}"
}


resource "aws_route_table_association" "arts2" {
  subnet_id = "${aws_subnet.Public-subnet-2.id}"
  route_table_id = "${aws_route_table.terravpc1-public-route.id}"
}


resource "aws_route_table_association" "arts-p-1" {
  subnet_id = "${aws_subnet.Private-subnet-1.id}"
  route_table_id = "${aws_vpc.terravpc1.default_route_table_id}"
}

resource "aws_route_table_association" "arts-p-2" {
  subnet_id = "${aws_subnet.Private-subnet-2.id}"
  route_table_id = "${aws_vpc.terravpc1.default_route_table_id}"
}
