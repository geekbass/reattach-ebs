/* Attributes for the Instance(s) */ 
resource "aws_instance" "node" {
  count = "${var.instance_counts["node"]}"
  ami = "${var.instance_ami["node"]}"
  key_name = "${var.keyname}"
  instance_type = "${var.instance_types["node"]}"
  availability_zone = "${var.region}${var.availability_zone}"
  tags {
    Name = "${lookup(var.node_private_dns, count.index+0)}"
  }
  vpc_security_group_ids = ["${var.security_groups["def"]}"]
  subnet_id = "${var.subnet}"
  user_data = "${element(data.template_file.node_cloudinit.*.rendered, count.index+0)}"
  connection {
    type = "ssh"
    user = "${var.user}"
    agent = "false"
    private_key = "${file("${var.keyfile}")}"
    timeout = "15m"
  }
}

/* Cloud Config for the Node instances above. This will likely need to be moved
to a multi step cloud config in order to meet custom needs .  Documentation URL: 
https://www.terraform.io/docs/providers/template/d/file.html 
*/
data "template_file" "node_cloudinit" {
  template = "${file("${path.module}/user-data/cloud-init.cloud.tpl")}"
  count = "${var.instance_counts["node"]}"
  vars {
    set_hostname = "${lookup(var.node_private_dns, count.index+0)}"
    user = "${var.user}"
    device = "${var.device}"
    directory = "${var.directory}"
  }
}

/* Create the ebs volume that holds the persistent data. 
Note the Name tag: Private_DNS_NAME-data-/dev/xvdb1
*/
resource "aws_ebs_volume" "data" {
  count = "${var.instance_counts["node"]}"
  availability_zone = "${var.region}${var.availability_zone}"
  type = "${var.data_disk_type}"
  size = "${var.data_disk_size["node"]}"
  encrypted = "true"
  tags {
    Name = "${lookup(var.node_private_dns, count.index+0)}-${var.directory}-${var.device}1"
    Backup = "${var.tagging["backup"]}"
  }
}

/* Attach data disk to each Instance. 
Terraform state keeps track of which volume is attached to the appropriate ec2 instance
*/
resource "aws_volume_attachment" "data_attach" {
  count = "${var.instance_counts["node"]}"
  device_name = "${var.device}1"
  volume_id = "${element(aws_ebs_volume.data.*.id, count.index+0)}"
  instance_id = "${element(aws_instance.node.*.id, count.index+0)}"
}