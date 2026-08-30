#!/usr/bin/env bash
# OpenShip — print the stable project name for a path (default: current dir).
# Usage: project.sh [cwd]
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"
openship_project "${1:-$PWD}"
