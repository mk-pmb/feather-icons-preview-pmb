#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function rebuild () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?

  local ICONS_DIR="$(dirname -- "$(node-resolve feather-icons)")"
  [ -d "$ICONS_DIR" ] || return 3$(echo "E: Failed to detect icons dir" >&2)
  ICONS_DIR+='/icons'
  local ICON="$ICONS_DIR"/x.svg
  [ -f "$ICON" ] || return 3$(
    echo "E: Wrong icons dir? Not a file: $ICON" >&2)

  local ICON_NAMES=()
  for ICON in "$ICONS_DIR"/*.svg; do
    ICON="${ICON%.svg}"
    ICON="${ICON##*/}"
    ICON_NAMES+=( "$ICON" )
  done

  for TMPL in *.tmpl.html; do
    <"$TMPL" render_tmpl "$TMPL" >"${TMPL%.tmpl.html}".html || return $?$(
      echo "E: failed to render $TMPL" >&2)
  done
}


function render_tmpl () {
  local ITEM="$(cat)" Q='"'
  local MARK='-- ||'
  ITEM="${ITEM//$MARK/$MARK$'\a'}"
  local HEAD="${ITEM%%$'\a'*}"
  local FOOT="${ITEM##*$'\a'}"
  ITEM="${ITEM#*$'\a'}"
  ITEM="${ITEM%$'\a'*}"

  ICON="$ITEM"
  ICON="${ICON#*<li icon=$Q}"
  ICON="${ICON%%$Q*}"

  ITEM="${ITEM#* }"
  ITEM="${ITEM//$ICON/$'\a'}"
  echo -n "$HEAD"
  for ICON in "${ICON_NAMES[@]}"; do
    echo "${ITEM//$'\a'/$ICON}"
  done
  echo "$FOOT"
}





rebuild "$@"; exit $?
