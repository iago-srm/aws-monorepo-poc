output "bastion_dns" {
  value = module.bastion.dns
}

output "database_url" {
  value = nonsensitive("postgres://${module.db.rds_username}:${module.db.rds_password}@${module.db.rds_hostname}:${module.db.rds_port}")
}