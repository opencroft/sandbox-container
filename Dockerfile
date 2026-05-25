ARG BASE_IMAGE=node:25-slim
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY git-cred.sh /tmp/git-cred
RUN chmod +x /tmp/git-cred && git config --system credential.helper /tmp/git-cred

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /app
USER node

ENTRYPOINT ["/entrypoint.sh"]
CMD ["sleep", "infinity"]
