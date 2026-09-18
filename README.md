# ReceiptSnap

A [Hermes](https://howto.plow.co/hermes) agent for Plow: photograph a receipt,
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
4. It replies with a one-line confirmation quoting the row it just read
   back from the file — merchant, total, date, category — not the raw
   extraction, so the confirmation can't drift from what actually landed
   on disk. Open `~/Plow/receiptsnap/receipts.csv` yourself (Numbers,
   Excel, `cat`) any time to see the whole ledger.
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

## Install

The simplest path is **Deploy this agent** on the
[ReceiptSnap Agent Index page](https://aiworthusing.com/agent-index/receiptsnap).
Install Plow Latch on the Mac and sign in to the same Plow account; ReceiptSnap
creates `~/Plow/receiptsnap/receipts.csv` automatically on first use.

To run the image from source, install Docker, Python 3.11+, and
[`plow-agents`](https://github.com/plow-pbc/plow-agents), then:

```sh
git clone https://github.com/ryanmiura/receiptsnap-hermes-agent.git
cd receiptsnap-hermes-agent
plow-agents login
plow-agents lines
plow-agents deploy --local --line <FREE_LINE_ID>
docker compose logs -f
```

Then text a photo of a receipt to the agent's Plow Chat line.

## License

MIT — see [LICENSE](LICENSE).
