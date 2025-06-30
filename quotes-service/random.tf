#######################################
# Random suffix for Auto Scaling Group name
#######################################
resource "random_string" "asg_suffix" {
  length  = 6     # Length of the random string
  upper   = false # Lowercase only
  special = false # No special chars
}
# ----------------------------------------------------
