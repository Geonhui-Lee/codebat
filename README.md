# Codebat

Codebat provides simple Windows batch launchers for AI agent software. Add it
to a repository as a Git submodule, open a launcher, and Codebat handles the
local agent installation before starting it in the parent project.

OpenCode is the first supported agent.

## Features

- Installs OpenCode locally with npm when it is not already available.
- Keeps agent dependencies, configuration, data, and cache inside Codebat.
- Starts the agent in the parent repository so it can work on that project.
- Reports clear errors when Node.js, npm, or installation is unavailable.

## Prerequisites

- Windows
- Git
- [Node.js](https://nodejs.org/) with npm available on `PATH`
- Internet access during the first OpenCode installation

## Quick Start

Open Windows Command Prompt in the root of the repository where you want to
use an AI agent, then add Codebat as a direct child of that repository:

```bat
git submodule add https://github.com/Geonhui-Lee/codebat.git codebat
git commit -m "chore: add Codebat submodule"
```

Launch OpenCode:

```bat
codebat\_opencode.bat
```

You can also open `_opencode.bat` from File Explorer. On its first run, the
launcher installs `opencode-ai` in `codebat\node_modules`. It then starts
OpenCode with the parent repository as its working directory.

> [!IMPORTANT]
> Keep Codebat directly inside the repository root. The launcher uses its
> immediate parent directory as the workspace. For example, placing it at
> `tools\codebat` would make `tools` the workspace instead of the repository
> root.

## Cloning a Project

To clone a repository and initialize Codebat at the same time, use:

```bat
git clone --recurse-submodules <repository-url>
```

If the repository was already cloned without its submodules, initialize them
with:

```bat
git submodule update --init --recursive
```

## How It Works

`_opencode.bat` performs the following steps:

1. Locates the Codebat directory and its parent workspace.
2. Checks that Node.js and npm are available.
3. Runs `npm install --save-dev opencode-ai` if OpenCode is missing locally.
4. Stores OpenCode state under `codebat\.opencode`.
5. Starts the local OpenCode executable from the parent workspace.

The generated `node_modules` and `.opencode` directories are ignored by Git.

## Updating Codebat

From the parent repository, update the submodule and record its new commit:

```bat
git submodule update --remote codebat
git add codebat
git commit -m "chore: update Codebat submodule"
```

## Troubleshooting

### Node.js is not available

Install [Node.js](https://nodejs.org/), open a new Command Prompt, and confirm
that both commands work:

```bat
node --version
npm --version
```

### OpenCode installation fails

Check your internet connection and npm configuration, then retry the launcher.
You can also run the installation directly from the submodule:

```bat
cd codebat
npm install --save-dev opencode-ai
```

### Codebat is missing after cloning

Initialize the submodule from the parent repository:

```bat
git submodule update --init --recursive
```

## Supported Agents

| Agent | Launcher | Status |
| --- | --- | --- |
| [OpenCode](https://opencode.ai/) | `_opencode.bat` | Supported |

Additional agent launchers may be added in future versions.
