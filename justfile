#!/usr/bin/env -S just --justfile
# SPDX-License-Identifier: ISC OR Apache-2.0
# SPDX-FileCopyrightText: © 2024 Dusk Banks <me@bb010g.com>
set shell := ["bash", "-euo", "pipefail", "-O", "inherit_errexit", "-c"]
export BASH_COMPAT := "51"
set windows-shell := ["pwsh", "-NoLogo", "-CommandWithArgs"]

[private]
[no-exit-message]
default:
  @{{ error("No recipe specified. List available recipes with `just --list`.") }}

# Automatically update dependencies.
[positional-arguments]
renovate *ARGS:
  @LOG_LEVEL=DEBUG renovate --platform=local "$@"

[group('nixos')]
[positional-arguments]
nixos-rebuild SUBCOMMAND *ARGS:
  nixos-rebuild --fast "$1" -L --show-trace --use-remote-sudo --flake "${@:2}"

[group('dsc')]
[positional-arguments]
dsc-winget-validate *ARGS:
  winget configuration validate -f dsc/configurations/configuration.dsc.yaml $args[1..$args.Length]

[group('dsc')]
[positional-arguments]
dsc-winget-test *ARGS:
  winget configuration test -f dsc/configurations/configuration.dsc.yaml --accept-configuration-agreements $args[1..$args.Length]

[group('dsc')]
[positional-arguments]
dsc-winget-set *ARGS:
  winget configuration -f dsc/configurations/configuration.dsc.yaml --accept-configuration-agreements $args[1..$args.Length]
