#!/bin/bash

timestamp() {
  date +"%T"
}


docker ps --format '{{.ID}}' | while read i; do

  envvars=$(docker inspect $i | jq '.[0].Config.Env[]')
  bcmd=$(echo "$envvars" | grep "^\"BACKUP_CMD=")
  [[ -z "$bcmd" ]] && continue

  bimg=$(echo "$envvars" | grep "^\"BACKUP_IMAGE=")
 
  bcmd=`echo "$bcmd" | sed 's/^"BACKUP_CMD=\(.*\)"/\1/'`
  bimg=`echo "$bimg" | sed 's/^"BACKUP_IMAGE=\(.*\)"/\1/'`

  if [[ -z "$bimg" ]]; then
    echo "TODO: run a backup from within the running image"
    exit -1
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
