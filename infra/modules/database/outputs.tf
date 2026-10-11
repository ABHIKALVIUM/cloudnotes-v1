output "db_instance_name" {
  description = "Name of the managed database instance"
  value       = google_sql_database_instance.db_instance.name
}

output "db_name" {
  description = "Name of the database"
  value       = google_sql_database.db.name
}

output "db_connection_name" {
  description = "Connection name for the database instance"
  value       = google_sql_database_instance.db_instance.connection_name
}

output "db_private_ip" {
  description = "Private IP address of the database instance"
  value       = google_sql_database_instance.db_instance.private_ip_address
}
