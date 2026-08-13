#!/bin/bash

## Copyright (C) 2026 - 2026 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## AI-Assisted

## style-ok: no-has -- runs in bare distro CI containers, before helper-scripts
## (the source of 'has') is installed; 'command -v' is the correct idiom here.

## CI setup: install the packages the installer test run needs, across the
## apt- and dnf-based images in the build matrix.

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace
shopt -s inherit_errexit
shopt -s shift_verbose

if command -v apt-get; then
   apt-get update --error-on=any
   ## Installer aborts if package upgrades are pending.
   apt-get dist-upgrade --yes
   apt-get install --yes shellcheck sudo adduser tor locales
elif command -v dnf; then
   dnf upgrade --assumeyes
   dnf install --assumeyes ShellCheck sudo tor systemd gawk
   ## Debugging.
   dnf provides needs-restarting
else
   exit 1
fi

## TODO: test
sed -i "s/^# \(ru_RU.UTF-8 UTF-8\)$/\1/" /etc/locale.gen || true
## TODO: Probably missing package on Fedora.
locale-gen || true
