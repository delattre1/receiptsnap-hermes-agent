# ReceiptSnap

A [Hermes](https://howto.plow.co/hermes) agent, run via
[`agent-mgr`](https://github.com/plow-pbc/agent-mgr): photograph a receipt,
text it to the agent's Plow Chat line, and it logs the merchant, total,
date and category into a CSV ledger on your own Mac — no Google account,
no browser, nothing to configure beyond Plow Latch itself.

## What it does

1. You text (or iMessage, via Plow Chat) a photo of a receipt to this
   agent's own phone line.
2. The agent reads the photo directly with its own vision — no external
   OCR call — and extracts merchant, total, date, and category.
3. It appends one row to `~/Plow/receiptsnap/receipts.csv` on your Mac,
   through [Plow Latch](https://plow.co/latch)'s file tools — the file is
   created automatically the first time.
4. It replies with a one-line confirmation and sends the updated ledger
   file back, so you can see the row actually landed.
5. Ask it a free-form question later — "how much did I spend on groceries
   this month?" — and it rereads the same file to answer.

See [`receiptsnap/SKILL.md`](receiptsnap/SKILL.md) for the exact flow.

## What it can and cannot reach

- **Reads**: photo attachments sent to its own Plow Chat line. Nothing
  else on your phone or Mac.
- **Touches exactly one file** on your Mac —
  `~/Plow/receiptsnap/receipts.csv` (or wherever `receiptsnap/config.json`'s
  `ledger_path` points) — through Plow Latch's `plow_read_file` /
  `plow_write_file`. Nothing else on disk, no browser, no other app.
- Paths under `~/Plow` — the shared folder Plow Latch already creates —
  auto-approve on every read/write; that's why the ledger lives there
  rather than somewhere that would pop an approval dialog on every receipt.
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

# Nothing to configure before the first run: receiptsnap/config.json's
# default ledger_path (~/Plow/receiptsnap/receipts.csv) just works as long
# as Plow Latch is installed. Change it only if you want the ledger
# somewhere else.

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
