#!/usr/bin/env bash
# Source: https://github.com/ralish/bash-script-template

set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
set -o xtrace           # Trace the execution of the script (debug)

# local hugo: HUGO=${HUGO:-"~/dev/go/bin/hugo --verbose"}
HUGO="hugo --verbose"

# DESC: Generic script initialisation
# ARGS: None
function script_init() {
    # Useful paths
    readonly orig_cwd="$PWD"
    readonly script_path="${BASH_SOURCE[0]}"
    readonly script_dir="$(dirname "$script_path")"
    readonly script_name="$(basename "$script_path")"

    # Important to always set as we use it in the exit handler
    readonly ta_none="$(tput sgr0 || true)"
}

# DESC: serve the hugo project
# ARGS: ${PORT}
function serve() {
  PORT="$1"

  CMD="${HUGO} serve \
        --config=\"./config.yaml\" \
        --buildDrafts --buildFuture \
        --disableFastRender \
        --port \"${PORT}\""
  eval ${CMD}
}

# DESC: build the hugo project
# ARGS: OPT:${newBaseURL}
function build() {
  rm -rf "./build/"

  CMD="${HUGO} --config=\"./config.yaml\" --destination \"./build/\""

  if [ ! -z ${1:-} ]; then
    URL="https://$1";
    CMD="${CMD} --baseURL=\"${URL}\"";
  fi

  if [ ${IS_DRAFT:-} ]; then
     CMD="${CMD} --buildDrafts --buildFuture";
  fi

  eval ${CMD}
}

# DESC: publish the hugo project
# ARGS: ${URL}
function publish() {
  URL="$1"

  CMD="gsutil -m rsync -R -d \"./build/\" \"gs://${URL}\""
  eval ${CMD}
}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
function main() {
    script_init

    echo "use \`serve PORT\`"
    echo "    \`IS_DRAFT=true build \`"
    echo "    \`publish URL\`"

    COMMAND="$1";
    shift;
    case $COMMAND in
      serve)
      serve "$@";
      ;;
      build)
      build "$@";
      ;;
      publish)
      build "$@" && publish "$@";
      ;;
    esac
}


# Make it rain
main "$@"

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
