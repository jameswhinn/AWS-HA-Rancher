resource "aws_key_pair" "rancher" {
    key_name = "${var.key_name}"
    public_key = "${file("${var.key_path}.pub")}"
}

data "template_file" "rancher_user_data" {
  template = "${file("templates/rancher_user_data.tpl")}"
  vars {
    dbHost = "${aws_rds_cluster.rancher_ha.endpoint}"
    dbUser = "${var.db_username}"
    dbPass = "${var.db_password}"
    dbName = "${var.db_name}"
  }
}

resource "aws_security_group" "rancher_ha" {
  name        = "${var.tag_name}-secgroup"
  description = "Rancher HA Ports"
  vpc_id      = "${aws_vpc.rancher_ha.id}"

  ingress {
      from_port = 0
      to_port   = 65535
      protocol  = "tcp"
      self      = true
  }

  ingress {
      from_port = 0
      to_port   = 65535
      protocol  = "udp"
      self      = true
  }

  ingress {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["192.168.99.0/24"]
  }

  ingress {
      from_port   = 0
      to_port     = 65535
      protocol    = "udp"
      cidr_blocks = ["192.168.99.0/24"]
  }

  ingress {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "lc" {
  name_prefix                 = "rancher-server"
  security_groups             = ["${aws_security_group.rancher_ha.id}"]
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.rancher.key_name}"
  user_data                   = "${data.template_file.rancher_user_data.rendered}"
  associate_public_ip_address = "true"

  lifecycle {
  create_before_destroy = true
  }

  ephemeral_block_device {
    device_name  = "/dev/sdb"
    virtual_name = "ephemeral0"
  }

  root_block_device {
    volume_type = "standard"
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "rancher-asg"
  availability_zones        = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier       = ["${aws_subnet.rancher_ha_a.id}","${aws_subnet.rancher_ha_b.id}","${aws_subnet.rancher_ha_c.id}"]
  launch_configuration      = "${aws_launch_configuration.lc.name}"
  min_size                  = "${var.asg_min}"
  max_size                  = "${var.asg_max}"
  desired_capacity          = "${var.asg_desired}"
  health_check_grace_period = "300"
  health_check_type         = "EC2"
  load_balancers            = ["${aws_elb.rancher_ha.name}"]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_capacity"]
  }
}
