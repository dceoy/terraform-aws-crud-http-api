#!/usr/bin/env bash
#
# Usage:
#   ./docker_buildx_bake.sh

set -euo pipefail

if [[ ${#} -gt 0 ]] && [[ "${1}" = "--debug" ]]; then
  set -x && shift 1
fi

cd "$(dirname "${0}")"

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
AWS_REGION="$(aws configure get region)"
GIT_SHA="$(git rev-parse --short HEAD)"
REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
TAG="sha-${GIT_SHA}"

export REGISTRY TAG
docker buildx bake --pull --load --provenance=false
image_refs="$(docker buildx bake --print | jq -r '.target[].tags[]')"

echo
echo '# Push images to ECR'
echo "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REGISTRY}"
echo "${image_refs}" | xargs -I{} echo 'docker image push {}'
