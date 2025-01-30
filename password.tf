resource "random_password" "this" {
  // Master password length constraints differ for each database engine. For more information, see the available settings when creating each DB instance.
  length  = 16
  special = true

  // The password for the master database user can include any printable ASCII character except /, ", @, or a space.
  // '%' is an acceptable character but causes confusion with url encoding, let's drop it
  override_special = "!#$&*()-_=+[]{}<>:?"
}
