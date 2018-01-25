#!/bin/bash

timestamp() {
  date +"%T"
}

s3_bucket=${1%/}

docker ps --format '{{.ID}}' | while read i; do

  envvars=$(docker inspect $i | jq '.[0].Config.Env[]')
  bcmd=$(echo "$envvars" | grep "^\"BACKUP_CMD=")
  [[ -z "$bcmd" ]] && continue

  bimg=$(echo "$envvars" | grep "^\"BACKUP_IMAGE=")

  bcmd=`echo "$bcmd" | sed 's/^"BACKUP_CMD=\(.*\)"/\1/'`
  bimg=`echo "$bimg" | sed 's/^"BACKUP_IMAGE=\(.*\)"/\1/'`

  if [[ -z "$bimg" ]]; then
    # no image to run wich does backups for us, going to run a command
    # inside the running image then copy out the data
    nm=$(docker inspect $i | jq '.[0].Name' | sed 's/^"\(.*\)"$/\1/')

    bkdir=$(readlink -m "/tmp/backup/$nm/")
    [[ -d "$bkdir" ]] || mkdir -p $bkdir


    [[ -z "$s3_bucket" ]] && echo "cannot backup $i: no s3 bucket specified" && continue;

    bloc=$(echo "$envvars" | grep "^\"BACKUP_LOCATION=")
    if [[ -z "$bloc" ]]; then
      bloc=/tmp/backup/
    else
      bloc=`echo "$bloc" | sed 's/^"BACKUP_LOCATION=\(.*\)"/\1/'`
    fi


    dcmd="docker exec $i $bcmd"
    echo "$(timestamp): $dcmd"
    $dcmd || continue;  # run the backup command

    dcmd="docker cp $i:$bloc $bkdir/"
    echo "$(timestamp): $dcmd"
    $dcmd || continue;  # run the copy command

    nm=$(echo "/$nm" | sed s#//*#/#g)

    # upload the copy to s3
    aws s3 sync --delete $bkdir/ $s3_bucket$nm/

  else
    dcmd="docker run --volumes-from $i"

    backup_envvars=$(echo "$envvars" | grep "^\"BACKUP_ENV_")
    while read e; do
      e=$(echo "$e" | sed 's/BACKUP_ENV_//')
      dcmd="$dcmd -e $e"
    done < <(echo "$backup_envvars")

    dcmd="$dcmd $bimg $bcmd"
    echo "$(timestamp): $dcmd"
    $dcmd
  fi

done
