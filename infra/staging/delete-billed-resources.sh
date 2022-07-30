#!/bin/bash
aws ecs update-service --cluster aws-monorepo-poc-ecs-cluster-staging --service aws-monorepo-poc-api-1-staging --desired-count 0
aws ecs update-service --cluster aws-monorepo-poc-ecs-cluster-staging --service aws-monorepo-poc-api-2-staging --desired-count 0
aws ec2 delete-nat-gateway --nat-gateway-id `aws ec2 describe-nat-gateways | python3 -c "import sys, json; print(json.load(sys.stdin)['NatGateways'][0]['NatGatewayId'])"`