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

`bin/argocd-ui` runs Argo CD's UI locally against the cluster (core mode), on
http://localhost:8086.

Everything comes from your kubeconfig as kubectl finds it: `$KUBECONFIG`,
else `~/.kube/config`. Set `KUBECONFIG` in `.env` (or `.envrc`) to use another.

Re-run `bin/gen-configs` when credentials expire or clusters change, with
`--restart` to recreate the stacks that are running. `bin/gen-configs --help`
and the header of each script say what they generate and how.
