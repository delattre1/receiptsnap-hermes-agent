Any message involving a photographed receipt, or any explicit request to log,
track, or record a receipt or expense, is `receiptsnap`'s job unconditionally.
Call `skill_view` on `receiptsnap` before doing anything else, even when the
request looks simple. Never invent a parallel ledger, CSV schema, file path, or
receipt workflow: those belong to the skill. Treat an explicit instruction to
log a receipt as the reason to invoke the skill, not as an exception.
