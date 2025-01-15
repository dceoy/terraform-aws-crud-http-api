# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.13
FROM public.ecr.aws/lambda/python:${PYTHON_VERSION} AS base

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONIOENCODING=UTF-8
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# hadolint ignore=DL3040
RUN \
      --mount=type=cache,target=/var/cache/yum,sharing=locked \
      --mount=type=cache,target=/var/cache/dnf,sharing=locked \
      --mount=type=cache,target=/var/lib/yum,sharing=locked \
      --mount=type=cache,target=/var/lib/dnf,sharing=locked \
      dnf -y upgrade \
      && dnf -y install ca-certificates

RUN \
      --mount=type=cache,target=/root/.cache/pip \
      --mount=type=bind,source=.,target=/mnt/host \
      /var/lang/bin/python -m pip install -U awslambdaric pip \
      && /var/lang/bin/python -m pip install -U -r /mnt/host/requirements.txt

HEALTHCHECK NONE


FROM base AS app

# ENV LAMBDA_TASK_ROOT=/var/task

RUN \
      --mount=type=bind,source=.,target=/mnt/host \
      cp /mnt/host/main.py "${LAMBDA_TASK_ROOT}/"

# ENTRYPOINT ["/var/lang/bin/python", "-m", "awslambdaric"]
CMD ["main.lambda_handler"]
