# 0.2.1 (Sep 01, 2026)
* Removed the `ensure_role_password` data source added in 0.2.0: it altered the role's password during plan/refresh, changing infrastructure when terraform reported "No changes".
  To repair a clobbered password, replace the role invocation (`terraform apply -replace=aws_lambda_invocation.role`); pg-db-admin 0.10+ only alters the password when a login attempt with it fails.

# 0.2.0 (Sep 01, 2026)
* The role's password is now re-verified on every plan and repaired when a login attempt with it fails.
  This heals a role created passwordless (e.g. by postgres-restore-access) or reset outside this workspace.
  Requires the datastore to advertise `db_admin_ensure_password` (aws-rds-postgres 0.16+); older datastores are unaffected.

# 0.1.0 (Apr 17, 2025)
* Initial release
