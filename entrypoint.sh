#!/bin/bash
set -e

if [ -n "$GIT_REPO" ] && [ ! -d /app/.git ]; then
    echo "Cloning $GIT_REPO ..."
    git clone "$GIT_REPO" /app
    echo "Clone complete."
fi

exec "$@"
