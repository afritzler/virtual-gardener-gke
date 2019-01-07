provider "google" {
  credentials = "${var.SERVICEACCOUNT}"
  project = "${var.PROJECT}"
}

//=====================================================================
//= CloudDNS Record
//=====================================================================

resource "google_dns_record_set" "gardener-ingress" {
  managed_zone = "${var.HOSTED_ZONE_ID}"
  name         = "${var.DNS_NAME}."
  type         = "${var.RECORD_TYPE}"
  ttl          = 120
  rrdatas      = ["${var.RECORD_VALUE}"]
}
