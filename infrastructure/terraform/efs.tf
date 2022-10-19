resource "aws_efs_file_system" "jenkins_shared" {
  creation_token = "$jenkins_shared-${var.env}"
  tags = local.tags
}

resource "aws_efs_mount_target" "jenkins_shared" {
  count = length(module.vpc.private_subnets)
  file_system_id = aws_efs_file_system.jenkins_shared.id
  subnet_id      = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.default_instances.id]
}

resource "aws_security_group_rule" "efs" {
  type              = "ingress"
  from_port         = 0
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.default_instances.id
}
