
   
##################################################################################
# OUTPUT
##################################################################################

output "elb_web_dns" {
  description = "External Load Balancer"
  value       = "${aws_lb.web_app_lb.dns_name}"
}

output "elb_app_dns" {
  description = "Internal Load Balancer"
  value       = "${aws_lb.appl_app_lb.dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = "${aws_db_instance.db_postgres.endpoint}"
}
