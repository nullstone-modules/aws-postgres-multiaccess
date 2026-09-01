# 0.2.0 (Sep 01, 2026)
* The role's password is now re-verified on every plan and repaired when a login attempt with it fails.
  This heals a role created passwordless (e.g. by postgres-restore-access) or reset outside this workspace.
  Requires the datastore to advertise `db_admin_ensure_password` (aws-rds-postgres 0.16+); older datastores are unaffected.

# 0.1.0 (Apr 17, 2025)
* Initial release
