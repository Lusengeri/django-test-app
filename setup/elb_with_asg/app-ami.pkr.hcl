packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "django-react-test-app-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "django-react-app-ami-build"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /usr/src/django-test-app",
      "sudo chown ubuntu /usr/src/django-test-app",
    ]
  }

  provisioner "file" {
    source      = "../../../django-test-app/backend"
    destination = "/usr/src/django-test-app"
  }

  provisioner "file" {
    source      = "../../../django-test-app/config"
    destination = "/usr/src/django-test-app"
  }

  provisioner "shell" {
    script = "../../scripts/ami_setup.sh"
  }
}
