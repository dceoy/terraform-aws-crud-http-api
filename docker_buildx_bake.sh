#!/usr/bin/env bash
#
# Usage:
#   ./docker_buildx_bake.sh

set -euox pipefail

cd "$(dirname "${0}")"

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
AWS_REGION="$(aws configure get region)"
GIT_SHA="$(git rev-parse --short HEAD)"

REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com" TAG="sha-${GIT_SHA}" \
  docker buildx bake --pull --load --provenance=false
