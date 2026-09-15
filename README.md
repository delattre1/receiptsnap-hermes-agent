# ReceiptSnap

A [Hermes](https://howto.plow.co/hermes) agent, run via
[`agent-mgr`](https://github.com/plow-pbc/agent-mgr): photograph a receipt,
text it to the agent's Plow Chat line, and it logs the merchant, total,
date and category into your Google Sheet — confirmed with a screenshot of
the new row.

## What it does

1. You text (or iMessage, via Plow Chat) a photo of a receipt to this
   agent's own phone line.
2. The agent reads the photo directly with its own vision — no external
   OCR call — and extracts merchant, total, date, and category.
3. It drives your own browser (already signed into your Google account)
   through [Plow Latch](https://plow.co/latch) to open your configured
   Google Sheet and append one row.
4. It replies with a one-line confirmation and a screenshot of the sheet
   showing the new row, so you can see the numbers actually landed.
5. Ask it a free-form question later — "how much did I spend on groceries
   this month?" — and it rereads the same sheet to answer.

See [`receiptsnap/SKILL.md`](receiptsnap/SKILL.md) for the exact flow.

## What it can and cannot reach

- **Reads**: photo attachments sent to its own Plow Chat line. Nothing
  else on your phone or Mac.
- **Browser access is scoped to `docs.google.com` only**, enforced by
  Plow Latch's own origin allowlist — checked in code before every
  navigation, not just an instruction in the skill's prompt. If anything
  ever tried to navigate outside that scope, the page locks until it goes
  back in scope.
- It never touches any page other than the one Google Sheet named in its
  config — no checkout, no payment page, no other tab.
- It reports its own token usage to the
  [Agent Index](https://aiworthusing.com/agent-index/receiptsnap) every 5
  minutes (day + model + token counts only — never prompts, costs, or file
  paths).

## Bring it up

Prerequisites: `docker`, `python3` (3.11+), an authenticated `gh`, and
[`agent-mgr`](https://github.com/plow-pbc/agent-mgr) installed
(`agent-mgr ls` should run).

```sh
git clone https://github.com/ryanmiura/receiptsnap-hermes-agent.git
agent-mgr register receiptsnap ./receiptsnap-hermes-agent
agent-mgr deploy receiptsnap

# Point the skill at your own sheet before the first run:
#   edit receiptsnap-hermes-agent/receiptsnap/config.json,
#   replacing "sheet_url": "[SHEET_URL]" with your Google Sheet's URL.

agent-mgr compose receiptsnap build   # builds the derived image (adds the
                                      # Agent Index usage reporter)
agent-mgr activate receiptsnap        # texts a one-time code to your phone
agent-mgr up receiptsnap
agent-mgr sign-in receiptsnap         # device-code OAuth in your browser

# Pair it to a Mac running Plow Latch: in Latch, Agents pane -> MCP clients
# -> Connect MCP client -> "Can't use OAuth? Create a static credential" ->
# copy the JSON it shows once, then:
agent-mgr set-latch receiptsnap
agent-mgr check-latch receiptsnap     # expect "latch reachable ... (HTTP 200)"
```

Smoke test:

```sh
agent-mgr agent receiptsnap "hello, who are you?"
agent-mgr check-connectors receiptsnap
```

Then text a photo of a receipt to the agent's Plow Chat line.

## License

MIT — see [LICENSE](LICENSE).
