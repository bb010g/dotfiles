#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure

## # suckdifferent shell data structures
##
## > seize what's at hand
## > deny resignation to fragility
## > be gay, do crimes
##
## For when you're attempting complex programs in shell, from POSIX hell up to
## the relative heaven of Bash. (Available optimizations are utilized.)
##
## Copyright: 2020 suckdifferent <transrights@suckdifferent.catgirl-v.com>
##
## SPDX-License-Identifier: ISC
##
## # General notes
##
## The variable & function name prefixes `SDSDS_` & `sdsds_` are reserved.
##
## POSIX names follow `[a-zA-Z0-9_]+`. No more, no less.

# variables
. ${SDSDS_DIR-./}sdsds-variables.lib.sh

# arrays
. ${SDSDS_DIR-./}sdsds-arrays.lib.sh

# stacks
. ${SDSDS_DIR-./}sdsds-stacks.lib.sh
