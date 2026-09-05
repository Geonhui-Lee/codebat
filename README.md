# Codebat

Codebat provides simple Windows batch launchers for AI agent software. Add it
to a repository as a Git submodule, open a launcher, and Codebat handles the
local agent installation before starting it in the parent project.

Codebat currently supports OpenCode and Pi Coding Agent.

## Features

- Installs supported agents locally with npm when they are not available.
- Keeps agent dependencies, configuration, data, and cache inside Codebat.
- Starts the agent in the parent repository so it can work on that project.
- Reports clear errors when Node.js, npm, or installation is unavailable.

## Prerequisites

- Windows
- [Git for Windows](https://git-scm.com/download/win); Pi uses its bundled Git
  Bash by default
- [Node.js](https://nodejs.org/) 22.19.0 or newer with npm available on `PATH`
- Internet access during the first agent installation

## Quick Start

### Add Codebat to Your Project

Open Windows Command Prompt in the root of the repository where you want to
use an AI agent, then add Codebat as a direct child of that repository:

```bat
git submodule add https://github.com/Geonhui-Lee/codebat.git codebat
git config --local submodule.recurse true
git commit -m "chore: add Codebat submodule"
```

The `git config` command enables recursive submodule handling for future
`git pull` commands in this local project without changing your global Git
configuration.

Launch OpenCode:

```bat
codebat\_opencode.bat
```

Or launch Pi Coding Agent:

```bat
codebat\_pi.bat
```

You can also open either launcher from File Explorer. On its first run, each
launcher installs its agent in `codebat\node_modules`. It then starts the agent
with the parent repository as its working directory.

> [!IMPORTANT]
> Keep Codebat directly inside the repository root. The launcher uses its
> immediate parent directory as the workspace. For example, placing it at
> `tools\codebat` would make `tools` the workspace instead of the repository
> root.

## Collaborators on Your Project

This section is for people who collaborate on your project after you add
Codebat as a submodule, not for contributors to Codebat itself. Each
collaborator must initialize Codebat in their own clone.

`git config --local` writes to each clone's `.git/config`, which is not
committed with your project. Every collaborator should therefore enable
recursive submodule handling once after cloning.

### Fresh Clone

Your collaborator can clone your project and initialize Codebat at the same
time:

```bat
git clone --recurse-submodules <repository-url>
cd <repository-directory>
git config --local submodule.recurse true
```

### Existing Clone

If your collaborator already cloned your project without its submodules, they
should run these commands from the project root:

```bat
git submodule update --init --recursive
git config --local submodule.recurse true
```

They can then launch either supported agent:

```bat
codebat\_opencode.bat
```

```bat
codebat\_pi.bat
```

The first launch installs the selected agent locally for that collaborator.
Their `codebat\node_modules`, `codebat\.opencode`, and `codebat\.pi`
directories remain local and are ignored by Git.

### Daily Use

After this one-time setup, a collaborator can pull your project's changes and
launch an agent normally:

```bat
git pull
```

The recursive Git configuration makes `git pull` update Codebat to the exact
commit recorded by your project. The collaborator can then open the launcher
for the agent they want to use.

## How It Works

Each launcher performs the following steps:

1. Locates the Codebat directory and its parent workspace.
2. Checks that Node.js and npm are available.
3. Installs and validates its agent if it is missing locally.
4. Stores that agent's user state inside Codebat.
5. Starts the local agent executable from the parent workspace.

| Agent | Local install command | User state |
| --- | --- | --- |
| OpenCode | `npm install --save-dev --ignore-scripts opencode-ai` | `codebat\.opencode` |
| Pi | `npm install --save-dev --ignore-scripts @earendil-works/pi-coding-agent` | `codebat\.pi\agent` |

Pi officially recommends disabling dependency lifecycle scripts during npm
installation. Both launchers therefore disable scripts while installing the
shared dependencies. `_opencode.bat` then runs only OpenCode's required
postinstall through `npm rebuild opencode-ai`. `_pi.bat` performs the same
targeted rebuild if installing Pi leaves OpenCode unprepared.

The generated `node_modules`, `.opencode`, and `.pi` directories are ignored by
Git.

## Updating Codebat in Your Project

Your collaborators should use normal `git pull` commands to receive the
Codebat version selected by your project. They should not run the following
commands unless they are responsible for maintaining your project's Codebat
version.

To intentionally move your project to a newer Codebat commit, run:

```bat
git submodule update --remote codebat
git add codebat
git commit -m "chore: update Codebat submodule"
```

## Troubleshooting

### Node.js is not available or is too old

Install [Node.js](https://nodejs.org/), open a new Command Prompt, and confirm
that both commands work:

```bat
node --version
npm --version
```

Pi requires Node.js 22.19.0 or newer.

### OpenCode installation fails

Check your internet connection and npm configuration, then retry the launcher.
You can also run the installation directly from the submodule:

```bat
cd codebat
npm install --save-dev --ignore-scripts opencode-ai
npm rebuild opencode-ai
```

### Pi installation fails

Confirm that Node.js 22.19.0 or newer, npm, and Git for Windows are installed.
Then retry `_pi.bat`. Pi's npm installation intentionally uses
`--ignore-scripts` as recommended by its maintainers.

### Codebat is missing after cloning

Initialize the submodule from the parent repository:

```bat
git submodule update --init --recursive
```

## Supported Agents

| Agent | Launcher | Status |
| --- | --- | --- |
| [OpenCode](https://opencode.ai/) | `_opencode.bat` | Supported |
| [Pi Coding Agent](https://pi.dev/) | `_pi.bat` | Supported |

Additional agent launchers may be added in future versions.
