module "consumer_vpc" {
  source         = "./modules/vpc"
  vpc_cidr       = "10.1.0.0/16"
  subnet_1a_CIRD = "10.1.0.0/21"
  subnet_1b_CIRD = "10.1.8.0/21"
  subnet_1c_CIRD = "10.1.16.0/21"
  name           = "consumer"
}

resource "aws_security_group" "consumer_sg" {
  name        = "consumer-sg"
  description = "Allow SSH"
  vpc_id      = module.consumer_vpc.vpc.id

  ingress {
    description = "SSH fom Public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Web fom Public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Internet Access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

module "consumer_machine_1" {
  source          = "./modules/web-instance"
  vpc_id          = module.consumer_vpc.vpc.id
  subnet_id       = module.consumer_vpc.subnet_1a.id
  env             = "consumer1"
  key             = file("id_rsa.pub")
  security_groups = [aws_security_group.consumer_sg.id]
}

resource "aws_vpc_endpoint" "consumer_ep" {
  vpc_id             = module.consumer_vpc.vpc.id
  service_name       = aws_vpc_endpoint_service.eps.service_name
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.consumer_sg.id]
  subnet_ids         = [module.consumer_vpc.subnet_1a.id, module.consumer_vpc.subnet_1b.id, module.consumer_vpc.subnet_1c.id, ]
  dns_options {
    dns_record_ip_type = "ipv4"
  }
}

output "consumer_ep_dns" {
  value = aws_vpc_endpoint.consumer_ep.dns_entry
}