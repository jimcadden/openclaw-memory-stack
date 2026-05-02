# Troubleshooting Guide

This guide covers common operational edge cases in the OpenClaw memory subsystem.

## 1. Dreaming Process Failures
If `scripts/promote_candidates.sh` returns errors or skips runs:
- **Check Logs:** Inspect `memory/logs/dreaming-YYYY-MM-DD.log`.
- **Token Limits:** If the daily digest prompt failed, the input might be too large. Archive older daily logs in `memory/archive/`.
- **Clock Drift:** Verify the system time matches the `dreaming.timezone` (America/New_York) defined in `openclaw.json`.
- **Cron Check:** Ensure the scheduler is active: `crontab -l | grep memory`.

## 2. Wiki Entropy & Hygiene
As the wiki grows, entropy increases. Apply these maintenance tasks:
- **Orphan Cleanup:** Run `grep -r "\[\[" . | grep -v "\]\]"` to find broken links. Use `wiki_lint` to find orphaned pages.
- **Synthesis Refactor:** If a concept page exceeds 200 lines or 15+ sources, split it into a "Hub Page" and child concept pages to keep complexity manageable.

## 3. Semantic Audit
To ensure the memory stack hasn't "drifted" from your core research focus:
- **Audit Query:** Ask the agent: *"Summarize my research mission on [Topic]."*
- **Validation:** If the summary contradicts recent `memory/` logs, the `MEMORY.md` weighting is likely stale. 
- **Correction:** Run a manual `wiki_lint` and manually update the key claims in `MEMORY.md`.
