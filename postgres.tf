data "ns_connection" "postgres" {
  name     = "postgres"
  contract = "datastore/aws/postgres:*"
}

locals {
  db_endpoint          = data.ns_connection.postgres.outputs.db_endpoint
  db_subdomain         = split(":", local.db_endpoint)[0]
  db_port              = split(":", local.db_endpoint)[1]
  db_security_group_id = data.ns_connection.postgres.outputs.db_security_group_id
}

locals {
  db_admin_func_name = data.ns_connection.postgres.outputs.db_admin_function_name
  db_admin_invoker   = try(data.ns_connection.postgres.outputs.db_admin_invoker, null)
  db_admin_func_url  = try(data.ns_connection.postgres.outputs.db_admin_function_url, "")
  db_admin_version   = try(data.ns_connection.postgres.outputs.db_admin_version, "0.6")
}
