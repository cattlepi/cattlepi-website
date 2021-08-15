#!/bin/bash
set -x
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR=$(dirname $SELFDIR)
WEBDIR=$TOPDIR"/web"

wget -O ${WEBDIR}/assets/prebuild.md https://api.cattlepi.com/images/global/autobuild/index.md?apiKey=deadbeef