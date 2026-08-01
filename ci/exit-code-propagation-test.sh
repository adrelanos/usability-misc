#!/bin/bash

## Copyright (C) 2026 - 2026 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## AI-Assisted

## Regression test: the "back to default repository" step must report the
## INSTALLER's exit code, not the status of the `if` condition that just
## failed. A wrong code turns a real installer failure into a meaningless 1,
## so the log no longer says WHICH failure occurred.

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s inherit_errexit
shopt -s shift_verbose

workflow="${1:-.github/workflows/builds.yml}"
step_name='Run VirtualBox Installer - back to default repository'
stub_exit=42
work_dir=''

## Reached only through the EXIT trap below, which shellcheck cannot follow.
# shellcheck disable=SC2317
cleanup() {
   test -n "${work_dir}" || return 0
   safe-rm --recursive --force -- "${work_dir}"
}

trap cleanup EXIT

work_dir="$(mktemp --directory)"

## Exercise the shipped step text, not a copy of it that can drift.
printf '%s\n' '#!/bin/bash' > "${work_dir}/step.sh"
./ci/workflow-step-extract.py "${workflow}" "${step_name}" >> "${work_dir}/step.sh"
chmod +x -- "${work_dir}/step.sh"

## Stub the installer so it fails with a distinctive code. `sudo` is the only
## external the step reaches before the branch under test.
mkdir --parents -- "${work_dir}/bin"
printf '%s\n' '#!/bin/bash' "exit ${stub_exit}" > "${work_dir}/bin/sudo"
chmod +x -- "${work_dir}/bin/sudo"

PATH="${work_dir}/bin:${PATH}"
export PATH

exit_code=0
"${work_dir}/step.sh" || exit_code="$?"

if [ "${exit_code}" = "${stub_exit}" ]; then
   printf '%s\n' "PASS: step propagated the installer exit code (${exit_code})"
   exit 0
fi

printf '%s\n' \
   "FAIL: step exited ${exit_code}, expected the installer's ${stub_exit}" \
   "      a wrong code hides which installer failure occurred"
exit 1
