# ABAP Reports — Cheat Sheets & Examples

Educational, copy-paste-ready materials for **SAP ABAP classic reports** (procedural and modularized), focused on clean structure, idiomatic syntax, and practical patterns you can reuse.  
Built to double as a **context pack** for an AI assistant that generates ABAP report code.

---

## 🎯 Goals

- Provide **minimal, production-ready templates** for common reporting tasks.
- Show **best practices** for classic report structure (selection screen, events, modularization).
- Include **working, runnable examples** (e.g., SALV non-editable output).
- Keep code **clean and consistent** so an AI assistant can extend it reliably.

---

## 📁 Repository Structure

- **`/zreporting_basics`** — Small, isolated building blocks:
  - Report skeleton & event flow
  - Selection screen patterns (parameters, select-options, validation)
  - Modularization (FORMs), local classes, global constants/structures
  - Message handling, basic authority checks, performance tips

- **`/zreporting_examples`** — Complete demos:
  - Data retrieval → formatting → output
  - Exception handling + user messages
  - **`znon_editable_alv_output`** — SALV table, column setup, hotspots, totals, toolbar tweaks

---
