resource "aws_security_group" "provider_web" {
  name        = "provider-sg"
  description = "Allow Web Access"
  vpc_id      = module.provider_vpc.vpc.id

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

module "provider_vpc" {
  source         = "./modules/vpc"
  vpc_cidr       = "10.0.0.0/16"
  subnet_1a_CIRD = "10.0.0.0/21"
  subnet_1b_CIRD = "10.0.8.0/21"
  subnet_1c_CIRD = "10.0.16.0/21"
  name           = "provider"
}

module "web1" {
  source          = "./modules/web-instance"
  vpc_id          = module.provider_vpc.vpc.id
  subnet_id       = module.provider_vpc.subnet_1a.id
  env             = "provider-1"
  key             = file("id_rsa.pub")
  security_groups = [aws_security_group.provider_web.id]
}

module "web2" {
  source          = "./modules/web-instance"
  vpc_id          = module.provider_vpc.vpc.id
  subnet_id       = module.provider_vpc.subnet_1a.id
  env             = "provider-2"
  key             = file("id_rsa.pub")
  security_groups = [aws_security_group.provider_web.id]
}


module "nlb" {
  source          = "./modules/nlb"
  vpc_id          = module.provider_vpc.vpc.id
  security_groups = [aws_security_group.provider_web.id]
  subnet_ids      = [module.provider_vpc.subnet_1a.id, module.provider_vpc.subnet_1b.id, module.provider_vpc.subnet_1c.id]
  instance_ids    = [module.web1.instance_id, module.web2.instance_id]
  name            = "provider"
}

# Endpoint Service that exposes the LB
resource "aws_vpc_endpoint_service" "eps" {
  acceptance_required        = false
  network_load_balancer_arns = [module.nlb.arn]
}

output "provider_nlb_dns" {
  value = module.nlb.nlb_dns
}

output "vpc_endpoint_service_name" {
  value = aws_vpc_endpoint_service.eps.service_name
}