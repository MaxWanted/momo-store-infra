#export YC_TOKEN=`yc iam create-token`
#terraform apply  -var "yc_token=${YC_TOKEN}"
 
 variable "yc_token" {
    sensitive   = true 
 } 