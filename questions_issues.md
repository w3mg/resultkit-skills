# Questions & Issues

Ongoing log of open questions and known issues across rkit skills.

---

## Issues

### Redundant confirmations in skills

Skills sometimes have multiple confirmation points where a single confirmation would suffice, creating unnecessary friction.

**Example:** The setup skill had two separate confirmation points — one to confirm the team selection, and one to confirm the final config write. A single "yes" clearly covers both.

**Action:** Audit all `rkit:*` skills and collapse redundant confirmation prompts.

---

## Questions

_(none yet)_
