#!/bin/bash

## Copyright (C) 2026 - 2026 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## AI-Assisted

## CI setup: create an unprivileged 'user' with passwordless sudo, so the
## installer runs as a normal user the way it does on a real system.

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace
shopt -s inherit_errexit
shopt -s shift_verbose

if test -f /etc/debian_version; then
   ## Debian trixie needs "--comment"; older Debian needs "--gecos".
   adduser --comment "" --disabled-password user || adduser --gecos "" --disabled-password user
   usermod -aG sudo user
   printf '%s\n' "%sudo ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/user
elif test -f /etc/fedora-release; then
   adduser user
   usermod -aG wheel user
   printf '%s\n' "%wheel ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/user
else
   exit 1
fi
