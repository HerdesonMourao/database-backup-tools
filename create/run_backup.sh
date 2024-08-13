#!/bin/bash

SCRIPT_DIR=$(dirname "$0")

source "$SCRIPT_DIR/create_config.env"

print_message() {
  echo
  echo "#=== $1 ===#"
  echo
}

create_directory() {
  mkdir -p "$1"
}

create_dump() {
  local database="$1"
  local backup_file="$2"

  mysqldump --defaults-extra-file="$MY_CNF" --single-transaction --set-gtid-purged=OFF "$database" > "$backup_file"

  if [ $? -eq 0 ]; then
    print_message "Backup of database $database performed successfully in $backup_file"
  else
    print_message "Failed to perform a backup of the database $database"
  fi
}

create_zip() {
  local zip_file="$1"
  local backup_file="$2"

  zip -j "$zip_file" "$backup_file" && rm "$backup_file"

  if [ $? -eq 0 ]; then
    print_message "Successfully compressed backup to $zip_file"
  else
    print_message "Failed to compress backup file"
  fi
}

backup_databases() {
  for db in "${DATABASES[@]}"; do
    print_message "-== Starting $db backup ==-"

    local directory="$BACKUP_DIR/$db"
    create_directory "$directory"

    local date=$(date +%Y-%m-%d_%H-%M-%S)

    local backup_file="$directory/backup_${db}_$date.sql"
    local zip_file="$directory/backup_${db}_$date.zip"

    create_dump "$db" "$backup_file"
    create_zip "$zip_file" "$backup_file"
  done
}

# start backup method
backup_databases
