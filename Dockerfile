# ReceiptSnap variant for Plow Cloud and plow-agents local runs.
# Keep the base immutable: a release must be reviewed before this pin moves.
FROM public.ecr.aws/e1h7x4a2/plow-cloud-agents:base-ef0019372ff8bca593611b31ebd2e08f9f1458ff@sha256:a8a2f97ad78b8192d80a984dce81d3bf5a9a883d18cb7b677704913a09b56aee

# plow-init combines the base identity with this agent-specific routing rule.
COPY --chmod=0644 runtime/persona.md /opt/hermes/plow-seed/persona.md
COPY LICENSE /usr/share/doc/receiptsnap/LICENSE

# Skills live outside the writable home. The base reconciles them into each
# tenant's /var/lib/hermes/skills directory during boot.
COPY receiptsnap/ /opt/hermes/skills/receiptsnap/
RUN find /opt/hermes/skills/receiptsnap -type d -exec chmod 0755 {} + \
 && find /opt/hermes/skills/receiptsnap -type f ! -perm -u+x -exec chmod 0644 {} + \
 && find /opt/hermes/skills/receiptsnap -type f -perm -u+x -exec chmod 0755 {} +
