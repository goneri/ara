#!/bin/bash
#  Copyright (c) 2018 Red Hat, Inc.
#
#  This file is part of ARA: Ansible Run Analysis.
#
#  ARA is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  ARA is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with ARA.  If not, see <http://www.gnu.org/licenses/>.

# The parent directory of this script
tests=$(dirname $0)
export PROJECT_ROOT=$(cd `dirname $tests` && pwd -P)
export PROJECT_LIB="${PROJECT_ROOT}/ara"

function banner() {
    echo
    printf '#%.0s' {1..50}
    echo
    echo "# ${1}"
    printf '#%.0s' {1..50}
    echo
}

# Let this script work even though it might not be run by tox
if [ -z "${VIRTUAL_ENV}" ]; then
    pushd "${PROJECT_ROOT}"
    tox -e linters --notest
    source .tox/linters/bin/activate
    popd
fi

banner black
time black --diff --check "${PROJECT_LIB}"

banner isort
time isort --recursive --check-only --diff "${PROJECT_LIB}"

banner flake8
time flake8 "${PROJECT_LIB}"

# B303 - Use of insecure MD2, MD4, or MD5 hash function.
# We're using sha1 to generate a hash of file contents.
banner bandit
time bandit -r "${PROJECT_LIB}" --skip B303
