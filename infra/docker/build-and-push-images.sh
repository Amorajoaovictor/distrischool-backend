#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DOCKER_REGISTRY:-}" ]]; then
  echo "Set DOCKER_REGISTRY (e.g., ghcr.io/<owner>) before running this script"
  exit 1
fi

sha=${GITHUB_SHA:-$(git rev-parse --short=8 HEAD)}
services=(gateway-service auth-service user-service student-service teacher-service admin-staff-service course-service)
for service in "${services[@]}"; do
  if [ -f "$service/Dockerfile" ]; then
    image=${DOCKER_REGISTRY}/${service}:$sha
    echo "Building $service as $image"
    docker build -f $service/Dockerfile -t $image $service
    echo "Pushing $image"
    docker push $image
  else
    echo "Skipping $service (no Dockerfile)"
  fi

done

echo "Done"
