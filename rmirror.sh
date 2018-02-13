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

version=1.1.0

email_addr="root@localhost"
rsync_flags="-av --delete --no-perms --no-owner --no-group"
max_deletes="10"
exclude_file=""

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

      -h --help         Print this message
      -V --version      Print Version 
      -v --verbose      Output to stdout and stderr instead of log file
      -e --email        E-mail Address [default: root@localhost]
      -s --source       Source
      -d --dest         Destination
      -r --rflags       Rsync flags [default: -av --delete]
      -l --logfile      Log file [default: <scriptdir>/log/rmirror.log]
      -m --max-deletes  The maximum number of deletes [default: 10]
      -x --exclude      Specify the exclude file. One file/dir per line

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

send_email()
{
  # Don't do anything if we're debugging
  [[ "$debug_flag" = "True" ]] && return
  # Email the log catching its output (stderr redirect required)
  log "sending email"
  mail_out="$($MAIL -s "Backup Log - $(date)" "$email_addr" < "$log_file" 2>&1)"
  if [[ -z "$mail_out" ]]; then
    log "Mail sent successfully"
  else
    log "$mail_out"
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
    -m | --max-deletes)
      max_deletes="$value"
      shift
      ;;
    -x | --exclude)
      exclude_file="$value"
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
  usage
  exit 1
elif [[ -z "$dest_dir" ]]; then
  log "Error: No Destination"
  usage
  exit 1
fi

# Check for required applications
for app in rsync mail ; do
  # Use command to check if the program exists
  command -v "$app" > /dev/null 2>&1 || { log "Error: $app not found"; exit 1; }
  log "Locating $app - Found $(command -v $app)"
  # Create a new variable in all caps that contains the program's path
  eval ${app^^}="$(command -v $app)"
done

# Check if required arguments are sane
if [[ ! -e "$src_dir" ]]; then
  log "Error: Source does not exist or is a relative path"
  send_email
  exit 1
elif [[ ! -e "$dest_dir" ]]; then
  log "Error: Destination does not exist or is a relative path"
  send_email
  exit 1
elif [[ ! -w "$dest_dir" ]]; then
  log "Error: Destination not writable"
  send_email
  exit 1
fi

# Create the exclude string, if required
if [[ -n "$exclude_file" ]]; then
  # Verify that the file exists
  if [[ ! -f "$exclude_file" ]]; then
    log "Error: The exclude file is set but doesn't exist"
    send_email
    exit 1
  fi
  rsync_exclude="--exclude-from $exclude_file"
fi

# Create the rsync strings
rsync_dry_command="$RSYNC --dry-run $rsync_flags $rsync_exclude \
  $src_dir $dest_dir"
rsync_command="$RSYNC $rsync_flags $rsync_exclude $src_dir $dest_dir"

# Check the number of deletes and stop if its greater than some value
log "Running: $rsync_dry_command"
rsync_output="$($rsync_dry_command)"
deleted_count="$(grep -ic "Deleting" <<< "$rsync_output")"
if [[ "$deleted_count" -gt "$max_deletes" ]]; then
  log "Error: Too many deletes to automatically process"
  log "Increase the --max-deletes value or run"
  log "${rsync_command}"
  log "to proceed"
  send_email
  exit 1
fi

# Sync the mirror
log "Running: $rsync_command"
log "$($rsync_command)"

# Send our final email
send_email

