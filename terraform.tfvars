#aws access key
access_key         = ""
secret_key         = ""

#ssh key
key_name           = ""
key_path           = ""
region             = "eu-west-1"

vpc_cidr           = "192.168.99.0/24"
availability_zones = "eu-west-1a,eu-west-1b,eu-west-1c"

#db creds
db_username        = ""
db_password        = ""
db_name            = ""

#Location of SSL certs
cert_body          = ""
cert_private_key   = ""
cert_chain         = ""


ami                = "ami-6d48500b" # Here I've used Ubuntu 16.04 LTS
instance_type      = "t2.small"
tag_name           = "rancher-ha" # servername prefix

# This has been set to ensure 3 instances in the asg to allow for a single host aoutage inline with
# Ranchers documentation. Set higher to allow for more redundancy.
asg_min            = "3"
asg_max            = "3"
asg_desired        = "3"
