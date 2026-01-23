data "terraform_remote_state" "level1"{
    backend = "s3"

    config = {
        bucket = "mkj-cloudshell-s3bucket-31123"
        key    = "level1.tfstate"
        region = "us-east-1"
    }
}
