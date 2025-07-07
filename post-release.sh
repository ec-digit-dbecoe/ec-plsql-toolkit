#!/usr/bin/env bash

function log_info() {
  >&2 echo -e "[\\e[1;94mINFO\\e[0m] $*"
}

function log_warn() {
  >&2 echo -e "[\\e[1;93mWARN\\e[0m] $*"
}

function log_error() {
  >&2 echo -e "[\\e[1;91mERROR\\e[0m] $*"
}

# check number of arguments
if [[ "$#" -lt 1 ]]; then
  log_error "Missing arguments"
  log_error "Usage: $0 <next version>"
  exit 1
fi

nextVer=$1
minorVer=${nextVer%\.[0-9]*}
majorVer=${nextVer%\.[0-9]*\.[0-9]*}

log_info "Creating minor version tag alias \\e[33;1m${minorVer}\\e[0m from $nextVer..."
git tag --force -a "$minorVer" "$nextVer" -m "Minor version alias (targets $nextVer)"

log_info "Creating major version tag alias \\e[33;1m${majorVer}\\e[0m from $nextVer..."
git tag --force -a "$majorVer" "$nextVer" -m "Major version alias (targets $nextVer)"

log_info "Pushing tags..."
git_base_url=$(echo "$CI_REPOSITORY_URL" | cut -d\@ -f2)
git_auth_url="https://token:${GITLAB_TOKEN}@${git_base_url}"
git push --tags --force "$git_auth_url"
