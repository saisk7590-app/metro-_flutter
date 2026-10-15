# Coding Guidelines & Line Rules for Metro Flutter

## Mandatory Code Line Rules Across All Categories

| Category | Folder Path | Line Rule Limit | Target / Ideal | Action When Exceeded |
|---|---|---|---|---|
| **Screens** | `lib/screens/**` | **<= 300 lines** | `<= 250` | Extract complex sections, empty states, or dialogs into `lib/widgets/`. |
| **Widgets** | `lib/widgets/**` | **<= 700 lines** | `<= 500` | Extract headers, footers, tables, or sub-component rows into separate files. |
| **Providers** | `lib/providers/**` | **<= 500 lines** | `<= 400` | Decompose large state into sub-providers, mixins, or domain state handlers. |
| **Services** | `lib/services/**` | **<= 500 lines** | `<= 400` | Split into modular domain services (e.g., auth, meter, bay, checklist). |
| **Repositories** | `lib/repositories/**` | **<= 200 lines** | `<= 120` | Keep thin and focused as data brokers between services and state. |
| **Models & Data** | `lib/models/**`, `lib/data/**` | **<= 350 lines** | `<= 250` | Keep pure data fields & JSON serialization; separate schemas. |
| **Theme & Utils** | `lib/theme/**`, `lib/utils/**`, `lib/constants/**` | **<= 250 lines** | `<= 200` | Keep compact, single-purpose helper functions and token sets. |

## General Rules
1. **No Duplicate Tracking Files**:
   - `metro_flutter/codelines.md` is the **only** code lines tracking file. Do not create `codelines.md` in the root workspace folder.
2. **Update Tracking**:
   - After adding new features, modifying code, or refactoring, always run:
     `powershell -ExecutionPolicy Bypass -File "e:\Sai Kiran\Metro\metro_flutter\tool\generate_codelines_md.ps1"`
     to keep `metro_flutter/codelines.md` synchronized.
3. **Stability & Reliability**:
   - Never break imports or shared types (e.g., `DropdownOption`).
   - Verify code compiles cleanly without errors.
