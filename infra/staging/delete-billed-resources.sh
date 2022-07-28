aws ecs update-service --cluster aws-monorepo-poc-ecs-cluster-staging --service aws-monorepo-poc-api-1-staging --desired-count 0
aws ecs update-service --cluster aws-monorepo-poc-ecs-cluster-staging --service aws-monorepo-poc-api-2-staging --desired-count 0
aws ec2 delete-nat-gateway --nat-gateway-id nat-02d2908f16a8608d6