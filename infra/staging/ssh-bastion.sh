#!/bin/bash
# ssh -i "language-app.pem" ec2-user@ec2-100-27-24-210.compute-1.amazonaws.com
# bastion_host = terraform output bastion_dns
ssh -i "language-app.pem" ec2-user@$(terraform output --raw bastion_dns)
