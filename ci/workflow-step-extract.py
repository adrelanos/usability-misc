#!/usr/bin/python3

## Copyright (C) 2026 - 2026 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## AI-Assisted

## Print the `run:` body of a named workflow step, so a test can exercise the
## shipped text instead of a copy that can drift from it.

## FIXME: Delete this, it will be obsolete once the script fragment being
## tested is split into a new file.

import sys

import yaml


def main():
    if len(sys.argv) != 3:
        sys.exit('usage: workflow-step-extract.py <workflow.yml> <step name>')

    workflow_path = sys.argv[1]
    wanted = sys.argv[2]

    with open(workflow_path, encoding='utf-8') as handle:
        document = yaml.safe_load(handle)

    for job in document['jobs'].values():
        for step in job.get('steps', []):
            if step.get('name') == wanted:
                sys.stdout.write(step['run'])
                return

    sys.exit('step not found: ' + wanted)


main()
