#!/bin/sh

export POSTGRES_DATABASE_BACKUP_NAME=${POSTGRES_DATABASE}.gz
export POSTGRES_CONNECTION_DETAILS="--host ${POSTGRES_HOST} --port ${POSTGRES_PORT} --username ${POSTGRES_USER}"

./init-gsutil.sh

if [ -z "$@" ]; then
  if ! gsutil -q stat gs://${GCP_BUCKET}/${POSTGRES_DATABASE_BACKUP_NAME} ; then
    echo "✘ No backup available"
    abort=1
  fi
  
  if ./postgres-database-exists.sh ; then
    echo "✘ The database already exists"
    abort=1
  fi

  if [ $abort ] ; then
    echo "Aborting due to failed checks"
    exit 1
  fi

  ./postgres-gs-restore.sh
else
  exec "$@"
fi
