@echo off
setlocal

pushd "%~dp0" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Could not open the Codebat directory.
    pause
    exit /b 1
)

set "CODEBAT_DIR=%CD%"
for %%I in ("%CODEBAT_DIR%\..") do set "WORKSPACE_DIR=%%~fI"
set "PI_CMD=%CODEBAT_DIR%\node_modules\.bin\pi.cmd"
set "OPENCODE_CMD=%CODEBAT_DIR%\node_modules\.bin\opencode.cmd"

set "PI_CODING_AGENT_DIR=%CODEBAT_DIR%\.pi\agent"

where node >nul 2>&1
if errorlevel 1 goto :missing_node

where npm >nul 2>&1
if errorlevel 1 goto :missing_npm

node -e "const [major, minor] = process.versions.node.split('.').map(Number); process.exit(major > 22 || (major === 22 && minor >= 19) ? 0 : 1)" >nul 2>&1
if errorlevel 1 goto :unsupported_node

if exist "%PI_CMD%" (
    call "%PI_CMD%" --version >nul 2>&1
    if not errorlevel 1 goto :run_pi
)

echo Pi is not installed locally. Installing it now...
call npm install --save-dev --ignore-scripts @earendil-works/pi-coding-agent
if errorlevel 1 goto :install_failed

if not exist "%OPENCODE_CMD%" goto :validate_pi
call "%OPENCODE_CMD%" --version >nul 2>&1
if not errorlevel 1 goto :validate_pi

echo Restoring OpenCode's required installation step...
call npm rebuild opencode-ai
if errorlevel 1 goto :opencode_repair_failed
call "%OPENCODE_CMD%" --version >nul 2>&1
if errorlevel 1 goto :opencode_repair_failed

:validate_pi
if not exist "%PI_CMD%" goto :install_failed
call "%PI_CMD%" --version >nul 2>&1
if errorlevel 1 goto :install_failed

:run_pi
pushd "%WORKSPACE_DIR%" >nul 2>&1
if errorlevel 1 goto :workspace_failed

echo Running Pi in "%CD%"...
call "%PI_CMD%" %*
set "exitCode=%errorlevel%"

popd
popd
endlocal & exit /b %exitCode%

:missing_node
echo ERROR: Node.js is not installed or is not available on PATH.
echo Install Node.js 22.19.0 or newer, then try again.
goto :fail

:missing_npm
echo ERROR: npm is not installed or is not available on PATH.
echo Install npm, then try again.
goto :fail

:unsupported_node
echo ERROR: Pi requires Node.js 22.19.0 or newer.
goto :fail

:install_failed
echo ERROR: Pi could not be installed with npm.
goto :fail

:opencode_repair_failed
echo ERROR: Pi was installed, but OpenCode's installation could not be restored.
goto :fail

:workspace_failed
echo ERROR: Could not open the parent workspace directory:
echo "%WORKSPACE_DIR%"

:fail
pause
popd
endlocal & exit /b 1
