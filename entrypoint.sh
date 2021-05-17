#!/bin/bash
# docker entrypoint script.

bin="/app/bin/bibcheck"

# Setup the database.
# start the elixir application
exec "$bin" "start" 