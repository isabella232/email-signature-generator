// Create S3 bucket for static webapp hosting with cloudfront distro in front of it
// docs: https://registry.terraform.io/modules/fillup/hugo-s3-cloudfront/aws/3.0.0
module "app" {
  source  = "fillup/hugo-s3-cloudfront/aws"
  version = "3.0.0"

  aliases             = ["${var.app_aliases}"]
  bucket_name         = "${var.app_bucket_name}"
  cert_domain         = "${var.app_cert_domain}"
  cf_default_ttl      = "0"
  cf_min_ttl          = "0"
  cf_max_ttl          = "0"
  origin_path         = "/public"
  s3_origin_id        = "s3-origin"
  deployment_user_arn = "${data.terraform_remote_state.common.codeship_arn}"
}

// Create DNS CNAME record on Cloudflare for app
resource "cloudflare_record" "static" {
  domain     = "${var.cloudflare_domain}"
  name       = "${var.subdomain}"
  type       = "CNAME"
  value      = "${module.app.cloudfront_hostname}"
  proxied    = true
  depends_on = ["module.app"]
}