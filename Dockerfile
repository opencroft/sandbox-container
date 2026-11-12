ARG BASE_IMAGE=node:25-slim
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY git-cred.sh /tmp/git-cred
RUN chmod 755 /tmp/git-cred && git config --system credential.helper /tmp/git-cred

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/entrypoint.sh"]
CMD ["sleep", "infinity"]
