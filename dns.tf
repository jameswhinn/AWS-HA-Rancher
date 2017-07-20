resource "aws_route53_zone" "root_domain" {
  name = "${var.domain}"
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.root_domain.zone_id}"
  name    = "${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_elb.rancher_ha.dns_name}"
    zone_id                = "${aws_elb.rancher_ha.zone_id}"
    evaluate_target_health = true
  }
}
