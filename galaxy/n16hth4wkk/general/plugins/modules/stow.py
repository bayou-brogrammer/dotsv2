#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) 2015, Kevin Brebanov <https://github.com/kbrebanov>
# Based on pacman (Afterburn <https://github.com/afterburn>, Aaron Bull Schaefer <aaron@elasticdog.com>)
# and apt (Matthew Williams <matthew@flowroute.com>) modules.
#
# GNU General Public License v3.0+ (see LICENSES/GPL-3.0-or-later.txt or https://www.gnu.org/licenses/gpl-3.0.txt)
# SPDX-License-Identifier: GPL-3.0-or-later

from __future__ import absolute_import, division, print_function

__metaclass__ = type


DOCUMENTATION = """
---
module: stow
short_description: Manages apk packages

description:
  - Manages C(apk) packages for Alpine Linux.
author: "Kevin Brebanov (@kbrebanov)"

extends_documentation_fragment:
  - community.general.attributes

attributes:
  check_mode:
    support: full
  diff_mode:
    support: none

options:
  available:
    description:
      - During upgrade, reset versioned world dependencies and change logic to prefer replacing or downgrading packages (instead of holding them)
        if the currently installed package is no longer available from any repository.
    type: bool
    default: false
  name:
    description:
      - A package name, like V(foo), or multiple packages, like V(foo, bar).
    type: list
    elements: str
  no_cache:
    description:
      - Do not use any local cache path.
    type: bool
    default: false
    version_added: 1.0.0
  repository:
    description:
      - A package repository or multiple repositories.
        Unlike with the underlying apk command, this list will override the system repositories rather than supplement them.
    type: list
    elements: str
  state:
    description:
      - Indicates the desired package(s) state.
      - V(present) ensures the package(s) is/are present. V(installed) can be used as an alias.
      - V(absent) ensures the package(s) is/are absent. V(removed) can be used as an alias.
      - V(latest) ensures the package(s) is/are present and the latest version(s).
    default: present
    choices: [ "present", "absent", "latest", "installed", "removed" ]
    type: str
  update_cache:
    description:
      - Update repository indexes. Can be run with other steps or on it's own.
    type: bool
    default: false
  upgrade:
    description:
      - Upgrade all installed packages to their latest version.
    type: bool
    default: false
  world:
    description:
      - Use a custom world file when checking for explicitly installed packages.
    type: str
    default: /etc/apk/world
    version_added: 5.4.0
notes:
  - 'O(name) and O(upgrade) are mutually exclusive.'
  - When used with a C(loop:) each package will be processed individually, it is much more efficient to pass the list directly to the O(name) option.
"""

EXAMPLES = """
# stow package "zsh" of directory "/media/user/dots" to the home directory
- stow:
    state: present
    package: zsh
    dir: /media/user/dots
    target: '$HOME'

# remove package "tmux"
- stow:
    state: absent
    package: tmux
    dir: /media/user/dots

# in case of conflict, overwrite the file with a symlink
- stow:
    state: supress
    package: vim
    dir: /media/user/dots

# loop through list of packages
- stow:
    state: latest
    package: '{{ item }}'
    dir: /media/user/dots
  with_items:
    - zsh
    - tmux
    - i3
"""

RETURN = """
packages:
    description: a list of packages that have been changed
    returned: when packages have changed
    type: list
    sample: ['package', 'other-package']
"""

import re
import os

# Import module snippets.
from ansible.module_utils.basic import AnsibleModule


def purge_conflicts(conflicted_files):
    """Delete a file or unlink a symlink conflicting with a package.

    Args:
        conflicted_files (list): Path of files or symlinks on the
            filesystem that conflicts with package files.

    Returns:
        dict or null: If the file is purged successfully, a None object is
            returned. If something goes wrong, a dictionary is returned
            containing the error message.
    """

    try:
        for file in conflicted_files:
            if os.path.islink(file):
                os.unlink(file)
            else:
                os.remove(file)

    except Exception as err:  # pylint: disable=broad-except
        return {"message": f'unable to purge file "{file}"; error: {str(err)}'}

    return None


def stow_has_conflicts(module, package, cmd):
    """Verify if a package has any conflicting files.

    Args:
        module (AnsibleModule): The Ansible module object.
        package (str): The name of the package to be un/re/stowed.
        cmd (str): The complete stow command, with all flags and arguments, to
            be executed in dry-run mode (no change is made on the filesystem).

    Returns:
        dict or null: If no conflict is found, a None object is returned.
            If a conflict is found, a dictionary is returned.

            Recoverable (i.e., conflicts on pre-existing files and symlinks on
            the filesystem) conflicts returns a different dict from a
            non-recoverable one:

                {
                    'recoverable': True,
                    'message': '...',
                    'files': ['/home/user/.bashrc', '/home/user/.config/foo']
                }

                ---

                {
                    'recoverable': False,
                    'message': '...'
                }
    """

    params = module.params

    # Dry-run to check if there's any conflict.
    cmd = f"{cmd} --no"
    rc_, _, stderr = module.run_command(cmd)

    if rc_ == 0:
        return None

    # Return code 2 means that the package points to a path that has a
    # directory on it. E.g.:
    #
    # Package "foo" is meant to be stowed at the home directory at
    # ".config/foo/bar" (absolute path being "/home/user/.config/foo/bar").
    #
    # If "bar" already exists as a directory at "/home/user/.config/foo",
    # stow can't continue.
    #
    # One way of dealing with this situation would be removing the directory.
    # Another way would be by backuping it. Either way, it's risky to
    # recursively delete an entire directory or even move it.
    #
    # This kind of scenario should be handled manually by the user, hence
    # the function returns with a non-recoverable flag error.
    if rc_ == 2:
        return {"recoverable": False, "message": ""}

    conflicts = []

    # Grab the conflicting files path.
    stderr_lines = stderr.split("\n")
    for sel in stderr_lines:
        if "* existing target is" in sel:
            conflict = sel.split(":")
            conflict = conflict[-1].strip()
            conflict = os.path.join(params["target"], conflict)

            conflicts.append(conflict)

    conff = ", ".join(f'"{f}"' for f in conflicts)
    msg = f'unable to stow package "{package}" to "{params["target"]}"; conflicted files: {conff}'

    return {"recoverable": True, "message": msg, "files": conflicts}


def stow(module, package, state):
    """Perform stow on a package against the filesystem.

    Args:
        module (AnsibleModule): The Ansible module object.
        package (str): The name of the package to be un/re/stowed.
        state (str): The desirable package state within the system.

    Returns:
        dict: A dictionary that contains an error flag, the returned message
            and wether something changed or not.
    """

    params = module.params

    flag = ""
    if state in ("present", "supress"):
        flag = "--stow"

    elif state == "absent":
        flag = "--delete"

    elif state == "latest":
        flag = "--restow"

    cmd = f'stow {flag} {package} --target={params["target"]} --dir={params["dir"]} --verbose'

    conflict = stow_has_conflicts(module, package, cmd)
    if conflict:
        if state != "supress" or not conflict["recoverable"]:
            return {"error": True, "message": conflict["message"]}

        err = purge_conflicts(conflict["files"])
        if err:
            return {"error": True, "message": err["message"]}

    # When increasing verbosity level with the "--verbose" flag, all output
    # will be sent to the standard error (stderr).
    #
    # Stow is, by itself, an idempotent tool.
    # If a given package is already stowed, the tool will not perform again.
    # If a package is succesfully stowed, stow will output what have been done.
    #
    # That's why "information on stderr" equals "something has changed"
    # (supposing execution passed all errors checking).
    rc_, _, se_ = module.run_command(cmd)
    if rc_ != 0:
        msg = 'execution of command "{cmd}" failed with error code {rc_}; output: "{se_}"'
        return {"error": True, "message": msg}

    return {"error": False, "changed": se_ != ""}


def parse_for_packages(stdout):
    packages = []
    data = stdout.split("\n")
    regex = re.compile(r"^\(\d+/\d+\)\s+\S+\s+(\S+)")
    for l in data:
        p = regex.search(l)
        if p:
            packages.append(p.group(1))
    return packages


# ==========================================
# Main control flow.


def main():
    module = AnsibleModule(
        argument_spec={
            "dir": {"required": True, "type": "str"},
            "package": {"required": True, "type": "list"},
            "target": {"required": False, "type": "str", "default": os.environ.get("HOME")},
            "state": {
                "required": True,
                "type": "str",
                "choices": ["absent", "present", "latest", "supress"],
            },
        }
    )

    # Set LANG env since we parse stdout
    module.run_command_environ_update = dict(LANG="C", LC_ALL="C", LC_MESSAGES="C", LC_CTYPE="C")

    global STOW_PATH
    STOW_PATH = module.get_bin_path("stow", required=True)

    has_changed = False
    params = module.params

    for package in list(params["package"]):
        ret = stow(module, package, params["state"])

        if ret["error"]:
            module.fail_json(msg=ret["message"])

        has_changed = has_changed or ret["changed"]

    module.exit_json(changed=has_changed)


if __name__ == "__main__":
    main()
