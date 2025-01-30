# aws-postgres-access

Nullstone capability to grant access for a postgres database to a service.
- Grant network access to the postgres cluster.
- Create database and user (with full access to database) in postgres.
- Inject credentials into application as environment variable (from secrets manager).
- For all `additional_databases`, ensure the database exists and the user has full access to the database.

## How it works

This module performs database administration against the cluster using an AWS Lambda function in 3 steps:
1. Create long-lived database owner (role name will be same as database name)
2. Create database (owner will be the role with the same name)
3. Create app role (usually named `<app-name>-<random-5-digits>`)
4. Grant membership to app role in database owner role
5. Set default schema privileges on app role (grants full access to database)
6. Set default grants on app role (when objects are created, the owner is set to long-lived database owner)

## Unable to run database migrations

Do not run database migrations as the admin user of your postgres cluster.
If you do, your database will be in a state where you will be unable to run database migrations on app startup.
If you want to recover from this situation, keep reading.

### What should my configuration look like?

After connecting to your cluster with `psql`, use the following commands to introspect your database.
The example shows what your database *should* look like with a database `webapp`.
The web application has access credentials for user `webapp-zshgw`.

```shell
webapp=> \dp
                                               Access privileges
 Schema |             Name              |   Type   |      Access privileges      | Column privileges | Policies
--------+-------------------------------+----------+-----------------------------+-------------------+----------
 public | ar_internal_metadata          | table    | postgres0=arwdDxt/postgres0+|                   |
        |                               |          | webapp=arwdDxt/postgres0    |                   |
(1 rows)
```

```shell
webapp=> \ddp
                        Default access privileges
    Owner     | Schema |   Type   |           Access privileges           
--------------+--------+----------+---------------------------------------
 webapp-zshgw |        | function | =X/"webapp-zshgw"                    +
              |        |          | webapp=X/"webapp-zshgw"              +
              |        |          | "webapp-zshgw"=X/"webapp-zshgw"
 webapp-zshgw |        | schema   | webapp=UC/"webapp-zshgw"             +
              |        |          | "webapp-zshgw"=UC/"webapp-zshgw"
 webapp-zshgw |        | sequence | webapp=rwU/"webapp-zshgw"            +
              |        |          | "webapp-zshgw"=rwU/"webapp-zshgw"
 webapp-zshgw |        | table    | webapp=arwdDxt/"webapp-zshgw"        +
              |        |          | "webapp-zshgw"=arwdDxt/"webapp-zshgw"
 webapp-zshgw |        | type     | =U/"webapp-zshgw"                    +
              |        |          | webapp=U/"webapp-zshgw"              +
              |        |          | "webapp-zshgw"=U/"webapp-zshgw"
(5 rows)
```

```shell
webapp=> select * from pg_tables where schemaname='public';
schemaname |       tablename        | tableowner | tablespace | hasindexes | hasrules | hastriggers | rowsecurity 
------------+------------------------+------------+------------+------------+----------+-------------+-------------
 public     | ar_internal_metadata   | webapp     |            | t          | f        | f           | f
(1 rows)
```
