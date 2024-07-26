#!/bin/bash

# Copied from : https://ash-hq.org/docs/guides/ash_postgres/latest/development/migrations-and-tasks#regenerating-migrations

# Often, you will run into a situation where you want to make a slight change to
# a resource after you've already generated and run migrations. If you are using
# git and would like to undo those changes, then regenerate the migrations, this
# script may prove useful.
# If you would like the migrations to automatically run after regeneration, add the -m flag: ./regen.sh name_of_operation -m

# Get count of untracked migrations
N_MIGRATIONS=$(git ls-files --others priv/repo/migrations | wc -l)

# Rollback untracked migrations
mix ash_postgres.rollback -n "$N_MIGRATIONS"

# Delete untracked migrations and snapshots
git ls-files --others priv/repo/migrations | xargs rm
git ls-files --others priv/resource_snapshots | xargs rm

# Regenerate migrations
mix ash.codegen --name "$1"

# Run migrations if flag
if echo "$*" | grep -e "-m" -q; then
  mix ash.migrate
fi
