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
if [[ "$#" -le 2 ]]; then
  log_error "Missing arguments"
  log_error "Usage: $0 <current version> <next version>"
  exit 1
fi

curVer=$1
nextVer=$2
relType=$3
curMinorVer=${curVer%\.[0-9]*}
curMajorVer=${curVer%\.[0-9]*\.[0-9]*}
nextMinorVer=${nextVer%\.[0-9]*}
nextMajorVer=${nextVer%\.[0-9]*\.[0-9]*}

if [[ "$curVer" ]]; then
  log_info "Bump version from \\e[33;1m${curVer}\\e[0m to \\e[33;1m${nextVer}\\e[0m (release type: $relType)..."

  # replace major, minor, and patch versions in README
  for tmpl in README.md; do
    sed -E "s/([^0-9.]|^)(${curVer//./\\.})([^0-9.]|$)/\1${nextVer}\3/g" "$tmpl" > "$tmpl.next"
    mv -f "$tmpl.next" "$tmpl"
    sed -E "s/([^0-9.]|^)(${curMinorVer//./\\.})([^0-9.]|$)/\1${nextMinorVer}\3/g" "$tmpl" > "$tmpl.next"
    mv -f "$tmpl.next" "$tmpl"
    sed -E "s/([^0-9.]|^)(${curMajorVer//./\\.})([^0-9.]|$)/\1${nextMajorVer}\3/g" "$tmpl" > "$tmpl.next"
    mv -f "$tmpl.next" "$tmpl"
  done
else
  log_info "Bump version to \\e[33;1m${nextVer}\\e[0m (release type: $relType): this is the first release (skip)..."
fi
