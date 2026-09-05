# Codebat Agent Guidelines

## Launcher Conventions

- Keep user-facing AI agent batch launchers in the repository root.
- Name each launcher `_<agent>.bat`, using a lowercase agent identifier and a
  lowercase `.bat` extension.
- Preserve the leading underscore. It intentionally groups launchers together
  ahead of supporting files in directory listings.
- Follow the existing `_opencode.bat` pattern. For example, use `_codex.bat`
  for a Codex launcher.
- Keep launchers in the repository root because they use their immediate
  parent directory as the target workspace.
- Update `README.md`, including Quick Start and Supported Agents, whenever a
  launcher is added, removed, or renamed.
