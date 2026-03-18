locals {
  # Terraform/dataforest/files/user-data/init-ubuntu.sh
  base64_userdata = (
    var.init_userdata
    ? filebase64("${path.module}/files/user-data/init-ubuntu.sh")
    : base64encode("")
  )
}

module "fe" {

  for_each = var.fe_instance_configs

  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "${var.project}-${var.env}-fe-${each.key}"
  instance_type               = each.value.instance_type
  key_name                    = var.instance_key_pair
  subnet_id                   = data.aws_subnets.pri_fe_subnets.ids[0]
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = false
  enable_primary_ipv6         = false
  create_security_group       = false
  vpc_security_group_ids      = [data.aws_security_group.pri_fe_sg.id]
  user_data_base64            = local.base64_userdata
  user_data_replace_on_change = false
  create_iam_instance_profile = false
  iam_instance_profile        = aws_iam_instance_profile.fe.name
  root_block_device           = each.value.root_block_device
  ebs_volumes                 = each.value.ebs_volumes

  monitoring = false
  timeouts   = var.timeouts

  tags = {
    Name = "${var.project}-${var.env}-fe-${each.key}"
  }
}
