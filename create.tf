
resource "aws_lambda_invocation" "role" {
  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "roles"
    data = {
      name        = local.username
      password    = random_password.this.result
      useExisting = true
    }
  })
}

resource "aws_lambda_invocation" "database_owner" {
  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "roles"
    data = {
      name        = local.database_name
      useExisting = true
    }
  })
}

resource "aws_lambda_invocation" "database" {
  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "databases"
    data = {
      name        = local.database_name
      owner       = local.database_owner
      useExisting = true
    }
  })

  depends_on = [aws_lambda_invocation.database_owner]
}

resource "aws_lambda_invocation" "role_member" {
  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "role_members"
    data = {
      target      = local.database_owner
      member      = local.username
      useExisting = true
    }
  })

  depends_on = [
    aws_lambda_invocation.database_owner,
    aws_lambda_invocation.role
  ]
}

resource "aws_lambda_invocation" "schema_privileges" {
  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "schema_privileges"
    data = {
      database = local.database_name
      role     = local.username
    }
  })

  depends_on = [
    aws_lambda_invocation.database,
    aws_lambda_invocation.role
  ]
}

resource "aws_lambda_invocation" "default_grants" {
  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "default_grants"
    data = {
      role     = local.username
      target   = local.database_owner
      database = local.database_name
    }
  })

  depends_on = [
    aws_lambda_invocation.role,
    aws_lambda_invocation.database,
    aws_lambda_invocation.database_owner
  ]
}

# everything below is used to create and add permissions for additional databases

resource "aws_lambda_invocation" "additional_database_owner" {
  for_each = coalesce(var.additional_database_names, [])

  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "roles"
    data = {
      name        = each.key
      useExisting = true
    }
  })
}

resource "aws_lambda_invocation" "additional_database" {
  for_each = coalesce(var.additional_database_names, [])

  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "databases"
    data = {
      name        = each.key
      owner       = each.key
      useExisting = true
    }
  })

  depends_on = [aws_lambda_invocation.additional_database_owner]
}

resource "aws_lambda_invocation" "additional_role_member" {
  for_each = coalesce(var.additional_database_names, [])

  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "role_members"
    data = {
      target      = each.key
      member      = local.username
      useExisting = true
    }
  })

  depends_on = [
    aws_lambda_invocation.additional_database_owner,
    aws_lambda_invocation.role
  ]
}

resource "aws_lambda_invocation" "additional_schema_privileges" {
  for_each = coalesce(var.additional_database_names, [])

  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "schema_privileges"
    data = {
      database = each.key
      role     = local.username
    }
  })

  depends_on = [
    aws_lambda_invocation.additional_database,
    aws_lambda_invocation.role
  ]
}

resource "aws_lambda_invocation" "additional_default_grants" {
  for_each = coalesce(var.additional_database_names, [])

  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "default_grants"
    data = {
      role     = local.username
      target   = each.key
      database = each.key
    }
  })

  depends_on = [
    aws_lambda_invocation.role,
    aws_lambda_invocation.additional_database,
    aws_lambda_invocation.additional_database_owner
  ]
}
