GIT Backup Script
=================

## Purpose

* Minimalistic script used to backup/archive remote git repositories locally
* Clones the specified repositories the first time (mirroring) and then just updates incrementally to reduce traffic

## Requirements

* Access to the remote git repo over git SSH
* Local SSH key to be authorized on the remote repo (read)
* [direnv](https://direnv.net/)

## User Manual

### Basic setup

The following setup is just one variant how to setup the backup script.

#### Credentials

* Generate a new SSH key and authorize its pub key on the remote repository
* Add the SSH private key to the local agent (ssh-add)

#### Preparation

* Install [direnv](https://direnv.net/)
* Git clone this project locally
* cd into the cloned project

#### Environment config

* Create a new direnv config file:
```
vi .envrc
```
* Add the following variables (adjust values as needed and do not forget to create the folders):
```
export GITBACKUP_DIR_BACKUP="/backup/gitrepo/backups"
export GITBACKUP_DIR_MIRROR="/backup/gitrepo/mirror"
export GITBACKUP_ORG="hp"
export GITBACKUP_HOST="gitrepo.example.com"
export GITBACKUP_CREDENTIALS="git"
export GITBACKUP_REPO_CONFIG="repo.conf"
```
* Allow the newly created Environment vars:
```
direnv allow .
```
* Create another config file for the source repositories to be backed-up:
```
vi repo.conf
```
* Add one or more repository identifiers (sample):
```
project_x
project_456
```

#### Run

* Execute the script:
```
./backup.sh
```

#### Automate with cron

* Ensure that the needed env vars are being loaded under the cron user
* Create a new cron job (e.g. run daily at midnight):
```
@daily ~/backup.sh > /var/logs/git-backup.log 2>&1
```
