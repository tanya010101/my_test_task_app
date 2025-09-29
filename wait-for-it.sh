#!/bin/sh
#
# Wait-for-it script that waits until a given host:port becomes available.
# Useful for waiting for dependent services like databases during Docker Compose setup.

set -e

host="$1"
port="${2:-22}"
shift 2
cmd="$@"

echoerr() {
  echo "$@" 1>&2
}

check() {
  nc -z "$host" "$port"
}

while :
do
  if check; then
    break
  fi
  sleep 1
done

# After successfully connecting to the database, perform migrations and start the server
echo "Database is available, starting migrations and server..."
rails db:migrate
rails server -b 0.0.0.0