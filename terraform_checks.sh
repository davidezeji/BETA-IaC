#!/bin/bash
# Install Curl
apk add -q curl
# Install Terraform #Versions: https://pkgs.alpinelinux.org/packages?name=terraform&branch=v3.16&repo=&arch=x86_64&maintainer=
apk add terraform --repository=http://dl-cdn.alpinelinux.org/alpine/v3.16/main
# Install tflint
curl --location https://github.com/terraform-linters/tflint/releases/download/v0.42.2/tflint_linux_amd64.zip --output tflint_linux_amd64.zip
unzip -o tflint_linux_amd64.zip
chmod +x tflint
