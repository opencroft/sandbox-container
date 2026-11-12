#!/bin/bash
set -e

if [ -n "$GIT_REPO" ] && [ ! -d /app/.git ]; then
    echo "Cloning $GIT_REPO ..."
    # /app may already hold mounted volumes: clone beside it, move .git in
    git clone --no-checkout "$GIT_REPO" /tmp/clone
    mv /tmp/clone/.git /app/.git
    rm -rf /tmp/clone
    git -C /app reset -q --hard
    chown -R node:node /app
    echo "Clone complete."
fi

exec setpriv --reuid=node --regid=node --init-groups "$@"
