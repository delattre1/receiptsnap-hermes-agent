# ReceiptSnap variant for Plow Cloud and plow-agents local runs.
# Keep the base immutable: a release must be reviewed before this pin moves.
FROM public.ecr.aws/e1h7x4a2/plow-cloud-agents:base-51f83158a70a383f03a4d03dbd8b6ea102cf0361@sha256:253d7ed3409effa7fa59113d93b4b79bb731d8264cdaf4cd60294924d0110a2e

# plow-init combines the base identity with this agent-specific routing rule.
COPY --chmod=0644 runtime/persona.md /opt/hermes/plow-seed/persona.md
COPY LICENSE /usr/share/doc/receiptsnap/LICENSE

# Skills live outside the writable home. The base reconciles them into each
# tenant's /var/lib/hermes/skills directory during boot.
COPY receiptsnap/ /opt/hermes/skills/receiptsnap/
RUN find /opt/hermes/skills/receiptsnap -type d -exec chmod 0755 {} + \
 && find /opt/hermes/skills/receiptsnap -type f ! -perm -u+x -exec chmod 0644 {} + \
 && find /opt/hermes/skills/receiptsnap -type f -perm -u+x -exec chmod 0755 {} +

# Agent Index usage reporter, pinned and checksum-verified at build time.
COPY vendor/client.pin /opt/plow/agent-index-client.pin
RUN set -eu; \
    sha="$(sed -n 's/^sha=//p' /opt/plow/agent-index-client.pin)"; \
    want="$(sed -n 's/^sha256=//p' /opt/plow/agent-index-client.pin)"; \
    path="$(sed -n 's/^path=//p' /opt/plow/agent-index-client.pin)"; \
    curl -fsS --max-time 60 -o /opt/plow/agent-index-client.py \
      "https://raw.githubusercontent.com/plow-pbc/agent-index-client/${sha}/${path}"; \
    got="$(sha256sum /opt/plow/agent-index-client.py | cut -d' ' -f1)"; \
    [ "$got" = "$want" ] || { echo "agent-index client is $got, pin says $want" >&2; exit 1; }; \
    chmod 0644 /opt/plow/agent-index-client.py

COPY image/s6-overlay/ /etc/s6-overlay/
