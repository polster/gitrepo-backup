#!/bin/bash

###########
# Variables
###########

# The local backup dir
GIT_BACKUP_DIR="${GITBACKUP_DIR_BACKUP:-/backup/bc-github/backups}"
# The local git mirror dir
GIT_MIRROR_DIR="${GITBACKUP_DIR_MIRROR:-/backup/bc-github/mirror}"
# The git organization or project id
GIT_ORG="${GITBACKUP_ORG:-hp}"
# The git host
GIT_HOST="${GITBACKUP_HOST:-stash}"
# The git credentials
GIT_CREDENTIALS="${GITBACKUP_CREDENTIALS:-git}"
# The repo config file containing a list of repo identifiers to be backed-up
GIT_REPO_CONFIG="${GITBACKUP_REPO_CONFIG:-repo.conf}"

TIMESTAMP=`date "+%Y%m%d-%H%M"`

###########
# Functions
###########

# The function `check` will exit the script if the given command fails.
function check {
  "$@"
  status=$?
  if [ $status -ne 0 ]; then
    echo "ERROR: Encountered error (${status}) while running the following:" >&2
    echo "           $@"  >&2
    echo "       (at line ${BASH_LINENO[0]} of file $0.)"  >&2
    echo "       Aborting." >&2
    exit $status
  fi
}

# The function `tgz` will create a gzipped tar archive of the specified repo ($1)
function tgz {
  local archive=${GIT_BACKUP_DIR}/$1_${TIMESTAMP}.tar.gz
  echo "Create backup archive [${archive}]"
  check tar -czvf $archive ${GIT_MIRROR_DIR}/$1
}

# The function `clone` will clone the source repo ($1) to the given local location ($2) using the mirror flag
function clone {
  echo "Mirror repo [${2}]"
  check git clone --mirror $1 $2
}

# The function `update` will pull new updates for the given repo ($1) being mirrored locally
function update {
  echo "Update existing git repo [${1}]"
  check git -C $1 remote update
}

# The function `update_or_clone` updates or clones the given repo ($1)
function update_or_clone {
  # Clone git repo if not already mirrored locally, or just update if present
  if [ -d "${GIT_MIRROR_DIR}/$1" ]; then
    update ${GIT_MIRROR_DIR}/$1
  else
    clone ssh://${GIT_CREDENTIALS}@${GIT_HOST}/${GIT_ORG}/$1.git ${GIT_MIRROR_DIR}/$1
  fi
}

########
# Script
########

echo "START Git Backup"

# Loop through the given repo list ($GIT_REPO_CONFIG)
while read repo; do

  update_or_clone ${repo}

  # Create backup archive
  tgz ${repo}

done <${GIT_REPO_CONFIG}

echo "END Git Backup"
