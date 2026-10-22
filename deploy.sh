#!/usr/bin/env bash
set -euo pipefail

STACK_NAME="${1:-vue-s3-cloudfront}"
REGION="${2:-}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$#" -gt 2 ]]; then
  echo "Usage: $0 [stack-name] [aws-region]" >&2
  exit 2
fi

for command in npm aws; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Required command not found: $command" >&2
    exit 1
  fi
done

cd "$SCRIPT_DIR"

aws_region_args=()
if [[ -n "$REGION" ]]; then
  aws_region_args=(--region "$REGION")
fi

npm install
npm run build
aws cloudformation deploy \
  --template-file infra/template.yaml \
  --stack-name "$STACK_NAME" \
  "${aws_region_args[@]}"

bucket_name="$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue | [0]" \
  --output text \
  "${aws_region_args[@]}")"
distribution_id="$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='DistributionId'].OutputValue | [0]" \
  --output text \
  "${aws_region_args[@]}")"
distribution_domain_name="$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='DistributionDomainName'].OutputValue | [0]" \
  --output text \
  "${aws_region_args[@]}")"

if [[ -z "$bucket_name" || "$bucket_name" == "None" ||
      -z "$distribution_id" || "$distribution_id" == "None" ||
      -z "$distribution_domain_name" || "$distribution_domain_name" == "None" ]]; then
  echo "The deployed stack did not return all expected outputs." >&2
  exit 1
fi

aws s3 sync dist "s3://$bucket_name" --delete "${aws_region_args[@]}"
aws cloudfront create-invalidation \
  --distribution-id "$distribution_id" \
  --paths "/*"

echo "Deployment complete: https://$distribution_domain_name"
