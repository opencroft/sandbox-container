#!/bin/bash
set -e

# Starts as root: Docker creates volume mount points inside /app root-owned, so
# the clone and the hand-over of /app to node happen here. The POST_CLONE hook
# and the command then run as node. Started with --user, there is no hand-over.
if [ "$(id -u)" = 0 ]; then
    export HOME=/home/node USER=node LOGNAME=node
    AS_NODE="setpriv --reuid=node --regid=node --init-groups"
else
    AS_NODE=""
fi

if [ -n "$GIT_REPO" ] && [ ! -d /app/.git ]; then
    echo "Cloning $GIT_REPO ..."
    # /app may already hold mounted volumes: clone beside it, check the files
    # out into /app, and move .git in last so a failed clone is retried.
    rm -rf /tmp/clone
    git clone --no-checkout "$GIT_REPO" /tmp/clone
    git --git-dir=/tmp/clone/.git --work-tree=/app reset -q --hard
    mv /tmp/clone/.git /app/.git
    rm -rf /tmp/clone
    if [ "$(id -u)" = 0 ]; then
        chown -R node:node /app
    fi
    echo "Clone complete."
fi

# Runs once after the clone (dependencies, a build). The marker is written only
# on success, so a failed hook runs again on the next start.
POST_CLONE_DONE=/app/.git/post-clone-done
if [ -n "$POST_CLONE" ] && [ -d /app/.git ] && [ ! -e "$POST_CLONE_DONE" ]; then
    echo "Running POST_CLONE ..."
    (cd /app && $AS_NODE bash -c "$POST_CLONE")
    touch "$POST_CLONE_DONE"
    echo "POST_CLONE complete."
fi

exec $AS_NODE "$@"
