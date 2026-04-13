# CC.md 🧠

> **The definitive Markdown-driven memory & workflow layer for Claude Code.**

**CC.md** is a local-first context management system designed to transform Claude Code into a project-aware senior engineer. By leveraging structured Markdown files within your repository, it ensures Claude remembers every architectural decision, learns from every bug, and never loses track of the project's roadmap.

---

## 🌟 Why CC.md?

Claude Code is powerful, but sessions are often stateless. **CC.md** provides the persistent "brain" your CLI was missing:

- **Local Persistence**: No databases or external APIs. Your memory lives in human-readable `.md` files.
- **Protocol-Driven**: Mandatory start/end session protocols ensure your project state is always fresh.
- **Architectural History**: Uses ADR (Architectural Decision Records) to prevent circular debates and maintain technical consistency.
- **Zero-Filler Workflow**: Optimized for senior developers who value technical depth and surgical precision.

---

## 🏗️ The "CC.md Standard" Structure

The system is organized into clear, functional layers:

- **Global/CLAUDE.md**: The "Brain" — User identity, general rules, and session protocols.
- **Project/CLAUDE.md**: The "Dashboard" — Project-specific constraints and entry points.
- **Project/Memory/**: The "Vault" — Deep technical context.
    - `project_state.md`: Active focus, roadmap, and task status.
    - `learnings.md`: A record of both errors/bugs and success patterns.
    - `decisions.md`: Architectural Decision Records (ADR).
    - `tech_architecture.md`: Stack, database, and patterns.

---

## 🚀 How it Works

1. **Session Start**: Claude reads `global/CLAUDE.md` and `project_state.md` to sync with your current objective.
2. **Execution**: Every bug fixed or pattern found is documented immediately in `learnings.md`.
3. **Session End**: Claude updates the status in `project_state.md` and defines the "Next Step" for the next time you open the CLI.

---

## 🛠️ Installation & Usage

*(Coming soon as a Claude Code Plugin)*

Currently, you can implement the **CC.md Standard** by copying the memory structure into your repository and setting the global instructions in your Claude Code configuration.

---

## 🤝 Contributing

**CC.md** is built by developers, for developers. If you have ideas for better memory structures or cleaner workflows, feel free to open an issue or a PR.

---

**CC.md** — *Local Memory, Global Intelligence.*
