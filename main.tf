resource "aws_instance" "app_server" {
    ami = "ami-068c0051b15cdb816"
    instance_type ="t3.micro"

    tags ={
        Name = "ExampleAppServerInstance"
        Owner = "Mkj"
    }
}
