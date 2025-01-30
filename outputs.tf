output "env" {
  value = [
    {
      name  = "POSTGRES_HOST"
      value = local.db_subdomain
    },
    {
      name  = "POSTGRES_USER"
      value = local.username
    },
    {
      name  = "POSTGRES_DB"
      value = local.database_name
    }
  ]
}

output "secrets" {
  value = [
    {
      name  = "POSTGRES_PASSWORD"
      value = random_password.this.result
    },
    {
      name  = "POSTGRES_URL"
      value = "postgres://${urlencode(local.username)}:${urlencode(random_password.this.result)}@${local.db_endpoint}/${urlencode(local.database_name)}"
    }
  ]
}
