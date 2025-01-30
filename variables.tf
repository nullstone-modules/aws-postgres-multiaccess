variable "app_metadata" {
  description = <<EOF
Nullstone automatically injects metadata from the app module into this module through this variable.
This variable is a reserved variable for capabilities.
EOF

  type    = map(string)
  default = {}
}

locals {
  security_group_id = var.app_metadata["security_group_id"]
}

variable "database_name" {
  type        = string
  description = <<EOF
Name of database to create in Postgres cluster. If left blank, uses app name.
The following identifiers are supported for interpolation:
  {{ NULLSTONE_STACK }}
  {{ NULLSTONE_BLOCK }}
  {{ NULLSTONE_ENV }}
EOF
  default     = ""
}

// We are using ns_env_variables to interpolate database_name
data "ns_env_variables" "db_name" {
  input_env_variables = tomap({
    NULLSTONE_STACK = local.stack_name
    NULLSTONE_APP   = local.block_name
    NULLSTONE_ENV   = local.env_name
    DATABASE_NAME   = coalesce(var.database_name, local.block_name)
  })
  input_secrets = tomap({})
}

variable "additional_database_names" {
  type        = set(string)
  description = <<EOF
Additional databases to grant access to in the postgres cluster.
For each database, the user will be granted owner permissions to the database schema.
EOF
  default     = []
}

locals {
  username       = local.resource_name
  database_name  = data.ns_env_variables.db_name.env_variables["DATABASE_NAME"]
  database_owner = local.database_name
}
