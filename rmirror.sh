#!/bin/bash
# ------------------------------------------------------------------
# Copyright:  Patrick Byrne
# License:    Apache 2.0
# Author:     Patrick Byrne
# Title:      rmirror
# Description:
#         A simple bash script to leverage cron, rsync, and email
# ------------------------------------------------------------------
#    Todo:
# ------------------------------------------------------------------

# --- Variables ----------------------------------------------------

version=0.1.1

email_addr="root@localhost"
rsync_flags="-av --delete"

# Find the path to the script and set the log file
# NOTE: This does NOT follow symlinks
log_file="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/log/rmirror.log"

# --- Functions ----------------------------------------------------

version()	
{
  printf "Version: %s\n" $version
}

usage() 
{
    cat <<"STOP"
    Usage: rmirror.sh [OPTIONS] -s <source> -d <destination>

    OPTIONS

      -h --help       Print this message
      -V --version    Print Version 
      -v --verbose    Output to stdout and stderr instead of log file
      -e --email      E-mail Address [default: root@localhost]
      -s --source     Source
      -d --dest       Destination
      -r --rflags     Rsync flags [default: -av --delete]
      -l --logfile    Log file [default: <scriptdir>/log/rmirror.log]

STOP
}

log()
{
  if [[ "$debug_flag" = "True" ]]; then
    printf "%s\n" "$*"
  else
    log_date="$(date "+%m-%d-%Y %H:%M:%S -")"
    printf "%s %s\n" "$log_date" "$*" >> "$log_file"
  fi
}

# --- Options processing -------------------------------------------

while [[ $# -gt 0 ]]; do
  param=$1
  value=$2
  case $param in
    -h | --help)
      usage
      exit
      ;;
    -V | --version)
      version
      exit
      ;;
    -v | --verbose)
      debug_flag="True"
      ;;
    -e | --email)
      email_addr="$value"
      shift
      ;;
    -s | --source)
      src_dir="$value"
      shift
      ;;
    -d | --dest)
      dest_dir="$value"
      shift
      ;;
    -r | --rflags)
      rsync_flags="$value"
      shift
      ;;
    -l | --logfile)
      log_file="$value"
      shift
      ;;
    *)
      echo "Error: unknown parameter \"$param\""
      usage
      exit 1
      ;;
  esac
  shift
done

# --- Body ---------------------------------------------------------

# Check the log dir exists and create it if required
if [[ ! -d "$(dirname "$log_file")" ]]; then
  mkdir -p "$(dirname "$log_file")"
fi

# Initialize the log file if we're not debugging
[[ ! "$debug_flag" = "True" ]] && date > "$log_file"
log "Starting backup"

# Check for required arguments
if [[ -z "$src_dir" ]]; then
  log "Error: No Source"
  exit 1
elif [[ -z "$dest_dir" ]]; then
  log "Error: No Destination"
  exit 1
fi

# Check for required applications
for app in rsync mail ; do
  # Use command to check if the program exists
  command -v "$app" > /dev/null 2>&1 || { log "Error: $app not found"; exit 1; }
  log "Found $(command -v $app)"
  # Create a new variable in all caps that contains the program's path
  eval ${app^^}="$(command -v $app)"
done

# Create our rsync string
rsync_command="$RSYNC $rsync_flags $src_dir $dest_dir"
log "Running: $rsync_command"

# Sync the mirror
log "$($rsync_command)"

# Email the log catching its output (stderr redirect required)
log "sending email"
log "$($MAIL -s "Backup Log - $(date)" "$email_addr" < "$log_file" 2>&1)"

