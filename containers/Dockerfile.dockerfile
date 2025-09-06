# 构建时
FROM docker.io/library/node:lts AS builder
ARG REPO
# eg. amd64 | arm64
ARG ARCH
# eg. x86_64 | aarch64
ARG CPU_ARCH
ARG TAG
# eg. latest
ARG IMAGE_VERSION
ENV REPO=$REPO \
     ARCH=$ARCH \
     CPU_ARCH=$CPU_ARCH \
     TAG=$TAG \
     IMAGE_VERSION=$IMAGE_VERSION

WORKDIR /source/
COPY source-src/ .
RUN export VAULT_FOLDER=bw_clients
RUN export VAULT_VERSION=$(git rev-parse HEAD)
RUN npm ci
WORKDIR /source/apps/web
RUN npm run dist:oss:selfhost
RUN printf '{"version":"%s"}'  $(echo $TAG | grep -Eo '[^\/v]*$') > build/vw-version.json

# 运行时
FROM scratch AS runtime
COPY --from=builder /source/apps/web/build/ /frontend/
