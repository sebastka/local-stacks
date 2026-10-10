# local-stacks

Docker Compose stacks for poking at Kubernetes clusters and the databases in
them, from your machine.

## Setup

```sh
cp .env.dist .env  # optional settings, see comments inside
direnv allow       # optional: .env in your shell too, bin/ on PATH
bin/gen-configs    # kubeconfigs, kite, pgadmin, pma, ch-ui, *.dist copies
bin/forward        # only if gen-configs says so; keep it running
```

In-cluster dashboards, served on localhost from your own kubeconfig, without
exposing them in the cluster. The cluster: a context given as last argument
(not to `bin/argocd-ui`: `ARGOCD_CONTEXT`), else `DASHBOARD_CONTEXT`, else the
current one.

| Command | UI | Port |
|---|---|---|
| `bin/argocd-ui` | Argo CD, run locally in core mode | 8086 |
| `bin/envoy-gateway-ui` | Envoy Gateway admin console | 8087 |
| `bin/hubble-ui` | Hubble, Cilium's flows and service map | 8088 |
| `bin/svc-ui <ns> <svc> [port]` | any other web UI behind a Service | 8089 |
| `bin/victoria-logs-ui` | VictoriaLogs vmui, at `/select/vmui/` | 8090 |
| `bin/victoria-metrics-ui` | VictoriaMetrics vmui, at `/vmui/` | 8091 |
| `bin/vmalert-ui` | vmalert rules and their state | 8092 |
| `bin/alertmanager-ui` | Alertmanager alerts and silences | 8093 |
| `bin/longhorn-ui` | Longhorn volumes, nodes and backups | 8094 |

CrowdSec has no UI of its own besides its hosted Console: `bin/cscli <args>` runs
`cscli` in its LAPI pod, e.g. `bin/cscli decisions list`.

Everything comes from your kubeconfig as kubectl finds it: `$KUBECONFIG`,
else `~/.kube/config`. Set `KUBECONFIG` in `.env` (or `.envrc`) to use another.

Re-run `bin/gen-configs` when credentials expire or clusters change, with
`--restart` to recreate the stacks that are running. `bin/gen-configs --help`
and the header of each script say what they generate and how.
