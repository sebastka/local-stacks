# shellcheck shell=bash
# Sourced by the bin/*-ui wrappers: an in-cluster web UI on localhost, through
# kubectl port-forward on the host, so your kubeconfig's exec plugins (OIDC,
# doctl) keep its credentials fresh. Nothing is exposed beyond 127.0.0.1.

set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")/.."

# Settings from .env, over the environment, as in bin/gen-configs.
if [[ -f .env ]]; then
    set -a
    # shellcheck source=/dev/null
    . ./.env
    set +a
fi

# dashboard_context [<context>] -- the given one, else DASHBOARD_CONTEXT, else
# your kubeconfig's current context
dashboard_context()
{
    printf '%s' "${1:-${DASHBOARD_CONTEXT:-$(kubectl config current-context)}}"
}

# Forward <local port> to <remote port> of <resource> until interrupted,
# reconnecting when it drops (pod restarted, network blip). <path> is where
# the UI lives on it, for the URL printed.
# dashboard <name> <context> <namespace> <resource> <local port> <remote port> [<path>]
dashboard()
{
    echo "$1 in $2/$3: http://localhost:$5${7:-/}"
    while :; do
        kubectl --context "$2" -n "$3" port-forward --address 127.0.0.1 "$4" "$5:$6" || true
        echo "port-forward dropped, reconnecting" >&2
        sleep 2
    done
}

# Forward to the first Service, in any namespace, whose name matches <regex>:
# for UIs whose Service is named after a Helm release.
# dashboard_find <name> <context> <regex> <local port> [<path>]
dashboard_find()
{
    local found ns svc port
    found=$(kubectl --context "$2" get services -A -o json | jq -r --arg re "$3" '
        [.items[] | select(.metadata.name | test($re))][0] // empty
        | "\(.metadata.namespace) \(.metadata.name) \(.spec.ports[0].port)"')
    if [[ -z $found ]]; then
        echo "$1: no Service matching /$3/ in $2" >&2
        exit 1
    fi
    read -r ns svc port <<<"$found"
    dashboard "$1" "$2" "$ns" "svc/$svc" "$4" "$port" "${5:-/}"
}
