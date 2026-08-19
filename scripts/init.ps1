# scripts/init.ps1 -- interactive bootstrap for projects forked from this template.
#
# Replaces placeholders in AGENTS.md, docs/PROJECT_BRIEF.md, and README.md;
# optionally demotes 8 personas to personas/optional/; runs the drift check.
#
# Idempotent: safe to re-run. If a placeholder is already replaced, the script
# leaves it alone unless -Force is passed.
#
# Usage:
#   ./scripts/init.ps1
#   ./scripts/init.ps1 -Force          # overwrite already-customized fields
#   ./scripts/init.ps1 -NonInteractive # skip prompts; use defaults / env vars

param(
    [switch]$Force,
    [switch]$NonInteractive,
    [string]$ProjectName,
    [string]$ProjectType,
    [string]$Vibe,
    [string]$PrimaryUser,
    [string]$InstallCmd,
    [string]$RunCmd,
    [string]$TestCmd,
    [string]$LintCmd,
    [string]$BuildCmd,
    [ValidateSet("claude","codex","cursor","gemini","copilot","")][string]$PrimaryAgent = "",
    [ValidateSet("prototype","active build","maintenance","archived","")][string]$CurrentStage = "",
    [ValidateSet("minimal","standard","full","")][string]$PersonasTier = "",
    [ValidateSet("local","committed","")][string]$SessionLogs = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

function Read-WithDefault {
    param([string]$Prompt, [string]$Default = "")
    if ($NonInteractive) { return $Default }
    $suffix = if ($Default) { " [$Default]" } else { "" }
    $value = Read-Host "$Prompt$suffix"
    if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
    return $value
}

function Confirm-Choice {
    param([string]$Prompt, [string[]]$Options, [string]$Default)
    if ($NonInteractive) { return $Default }
    $list = ($Options | ForEach-Object { if ($_ -eq $Default) { "[$_]" } else { $_ } }) -join " / "
    $value = Read-Host "$Prompt ($list)"
    if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
    if ($Options -notcontains $value) {
        Write-Host "  (not a valid choice; using default '$Default')" -ForegroundColor Yellow
        return $Default
    }
    return $value
}

function Replace-InFile {
    param([string]$RelPath, [string]$Pattern, [string]$Replacement, [switch]$Literal)
    $path = Join-Path $root $RelPath
    if (-not (Test-Path -LiteralPath $path)) { return $false }
    $content = Get-Content -Raw -LiteralPath $path
    if ($Literal) {
        if (-not $content.Contains($Pattern)) { return $false }
        $new = $content.Replace($Pattern, $Replacement)
    } else {
        if ($content -notmatch $Pattern) { return $false }
        $new = [regex]::Replace($content, $Pattern, $Replacement)
    }
    if ($new -ne $content) {
        Set-Content -LiteralPath $path -Value $new -NoNewline
        Write-Host "  updated $RelPath" -ForegroundColor DarkGray
        return $true
    }
    return $false
}

function ConvertTo-YamlScalar {
    param([string]$Value)
    return ($Value | ConvertTo-Json -Compress)
}

function Write-ProjectBrief {
    param(
        [string]$Name,
        [string]$Type,
        [string]$Feeling,
        [string]$User,
        [string]$Stage
    )

    $safeName = if ($Name) { $Name } else { "This project" }
    $safeType = if ($Type) { $Type } else { "Not specified yet" }
    $safeFeeling = if ($Feeling) { $Feeling } else { "Not specified yet" }
    $safeUser = if ($User) { $User } else { "Not specified yet" }
    $safeStage = if ($Stage) { $Stage } else { "prototype" }

    $brief = @"
# Project Brief

This is the project context agents should read before product, architecture, UI, or roadmap work.

## Summary

$safeName is a $safeType project.

$safeFeeling

## Vibe

- Desired feeling: $safeFeeling
- Reference products / experiences: To be refined.
- Anti-vibe: To be refined.
- First impression target: To be refined.

## User

- Primary user: $safeUser
- Secondary users: To be refined.
- User skill level: To be refined.
- Context of use: To be refined.

## Problem

To be refined.

## Product Promise

To be refined.

## Core Workflows

1. User does the primary action and gets the intended outcome.
2. User handles an empty, loading, or error state without confusion.
3. Maintainer runs the documented checks before shipping changes.

## Success Criteria

- The primary workflow works end-to-end.
- The project can be installed, run, verified, and built with the documented commands.
- The experience matches the intended vibe.

## Non-Goals

- To be refined.

## Constraints

- Time: To be refined.
- Budget: To be refined.
- Stack: To be refined.
- Deployment target: To be refined.
- Data sensitivity: To be refined.
- Performance expectations: To be refined.
- Accessibility expectations: To be refined.

## Quality Gates

- Core workflow works end-to-end.
- Loading, empty, and error states exist where relevant.
- UI is responsive across target screen sizes.
- Project commands in `AGENTS.md` are accurate.
- Tests/checks cover the most important changed behavior.

## Technical Notes

- Architecture: To be refined.
- Data model: To be refined.
- External services: To be refined.
- Authentication/authorization: To be refined.
- Observability/logging: To be refined.

## Open Questions

- [ ] Refine the product brief after the first working slice.

## References

- `AGENTS.md`
- `ROADMAP.md`
- `TODO.md`

"@

    Set-Content -LiteralPath (Join-Path $root "docs/PROJECT_BRIEF.md") -Value $brief -NoNewline
    Write-Host "  generated docs/PROJECT_BRIEF.md" -ForegroundColor DarkGray
}

# Generated files deliberately avoid backtick characters (PowerShell's escape
# char in here-strings). Commands use indented code blocks instead of fences.
function Write-ForkReadme {
    param([string]$Name, [string]$Type, [string]$Feeling, [string]$User, [string]$Stage)

    $safeName = if ($Name) { $Name } else { "This project" }
    $safeType = if ($Type) { $Type } else { "software" }
    $safeUser = if ($User) { $User } else { "its primary user" }
    $safeStage = if ($Stage) { $Stage } else { "prototype" }
    $installLine = if ($InstallCmd) { $InstallCmd } else { "(not set yet - update AGENTS.md and this file)" }
    $runLine = if ($RunCmd) { $RunCmd } else { "(not set yet)" }
    $testLine = if ($TestCmd) { $TestCmd } else { "(not set yet)" }
    $lintLine = if ($LintCmd) { $LintCmd } else { "(not set yet)" }
    $buildLine = if ($BuildCmd) { $BuildCmd } else { "(not set yet)" }

    $readme = @"
# $safeName

$Feeling

## What this is

$safeName is a $safeType project built for $safeUser. The durable context — problem, vibe, workflows, quality gates — lives in docs/PROJECT_BRIEF.md.

## Commands

    # Install dependencies
    $installLine

    # Run development server
    $runLine

    # Run tests
    $testLine

    # Lint / type checks
    $lintLine

    # Build
    $buildLine

## Working with AI agents

This repo uses an agent operating contract:

- AGENTS.md — canonical rules for every AI coding agent. Read it first.
- docs/PROJECT_BRIEF.md — what this project is, who it serves, and what it should feel like.
- Slash commands (Claude Code): /brief, /spec, /council, /review, /session-log, /drift-check, /handoff, /todo-triage, /retro.
- Persona subagents (Claude Code): .claude/agents/ — isolated review lenses; see docs/SUBAGENTS.md.
- After editing any agent instruction file, run scripts/check-agent-docs.ps1 (or the .sh twin).

## Status

- Stage: $safeStage
- Working queue: see TODO.md
- Direction: see ROADMAP.md

---

Built from the AgentOps Template (currently distributed from vibe-coding-generalist-template; template version recorded in .vibe-template-version).
"@

    Set-Content -LiteralPath (Join-Path $root "README.md") -Value $readme -NoNewline
    Write-Host "  generated README.md" -ForegroundColor DarkGray
}

function Write-TodoStub {
    param([string]$Name)
    $safeName = if ($Name) { $Name } else { "this project" }

    $todo = @"
# TODO

Working queue for $safeName. Keep items concrete; promote durable direction into ROADMAP.md.

## Now

- [ ] Build the first vertical slice of the core workflow (see docs/PROJECT_BRIEF.md).

## Soon

- [ ] Refine docs/PROJECT_BRIEF.md once the first slice exists.
- [ ] Wire up CI: rename .github/workflows/quality.yml.example to quality.yml when there are real checks to run.

## Parking lot

- [ ] Revisit which optional personas this project needs as it matures.
"@

    Set-Content -LiteralPath (Join-Path $root "TODO.md") -Value $todo -NoNewline
    Write-Host "  generated TODO.md" -ForegroundColor DarkGray
}

function Write-RoadmapStub {
    param([string]$Name)
    $safeName = if ($Name) { $Name } else { "this project" }

    $roadmap = @"
# Roadmap

Medium-term direction for $safeName. TODO.md holds the working queue; this file holds phases, decisions, and risks.

## Phase 1 — First working slice

- Goal: the primary user can complete the core workflow end-to-end.
- Done when: the workflow runs with the documented commands and matches the intended vibe.

## Phase 2 — Hardening

- Goal: loading, empty, and error states exist; checks run in CI.
- Done when: the quality gates in docs/PROJECT_BRIEF.md pass.

## Later

- Capture bigger bets here once Phase 1 ships.

## Decisions

| Date | Decision | Reason |
|---|---|---|

## Risks

- Record real risks as they appear.
"@

    Set-Content -LiteralPath (Join-Path $root "ROADMAP.md") -Value $roadmap -NoNewline
    Write-Host "  generated ROADMAP.md" -ForegroundColor DarkGray
}

function Write-SessionIndex {
    $index = @'
---
type: session-log-index
status: active
mutability: living
---

# Session Logs

Use this folder for durable records of meaningful AI coding sessions.

## Logging Rule

Create or append a session log when a session includes one or more of:

- Architectural or product decisions.
- Multiple files touched.
- Debugging with important findings.
- A handoff another agent or future session will need.
- User feedback that changes project direction.
- Any work that should not be reconstructed from chat history.

Small one-line fixes do not need a session log unless the user asks.

## Logs

Add one row per session log, newest first. If this project commits its session logs, use markdown links (the drift check validates that linked files exist); if logs are local-only, use plain filenames, since the linked files will not exist in CI or fresh clones.

| Date | File | Summary |
|---|---|---|

## Current Themes

Update this section as durable themes emerge from the logs. Keep entries non-sensitive: this index is committed even when the logs themselves are not.
'@

    Set-Content -LiteralPath (Join-Path $root "Session Logs/_Session Logs Index.md") -Value $index -NoNewline
    Write-Host "  reset Session Logs/_Session Logs Index.md" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "AgentOps Template -- interactive setup" -ForegroundColor Cyan
Write-Host "----------------------------------------"

# Detect prior runs by checking AGENTS.md for the literal placeholder.
$agentsContent = Get-Content -Raw -LiteralPath (Join-Path $root "AGENTS.md")
$alreadyCustomized = -not ($agentsContent -match 'Project name: `TODO`')
if ($alreadyCustomized -and -not $Force) {
    Write-Host "AGENTS.md project identity is already customized." -ForegroundColor Yellow
    Write-Host "Re-run with -Force to overwrite, or skip prompts with -NonInteractive." -ForegroundColor Yellow
    Write-Host ""
}

if (-not $ProjectName) { $ProjectName = Read-WithDefault "Project name" "" }
if (-not $ProjectType) { $ProjectType = Read-WithDefault "Project type" "" }
if (-not $Vibe)        { $Vibe        = Read-WithDefault "One-line vibe (the feeling/goal)" "" }
if (-not $PrimaryUser) { $PrimaryUser = Read-WithDefault "Primary user" "" }
if (-not $InstallCmd)  { $InstallCmd  = Read-WithDefault "Install command" "" }
if (-not $RunCmd)      { $RunCmd      = Read-WithDefault "Run/dev command" "" }
if (-not $TestCmd)     { $TestCmd     = Read-WithDefault "Test command" "" }
if (-not $LintCmd)     { $LintCmd     = Read-WithDefault "Lint/type-check command" "" }
if (-not $BuildCmd)    { $BuildCmd    = Read-WithDefault "Build command" "" }
if (-not $PrimaryAgent) {
    $PrimaryAgent = Confirm-Choice "Primary agent" @("claude","codex","cursor","gemini","copilot") "claude"
}
if (-not $CurrentStage) {
    $CurrentStage = Confirm-Choice "Current stage" @("prototype","active build","maintenance","archived") "prototype"
}
if (-not $PersonasTier) {
    $tierPrompt = "Personas tier - minimal=3 (Product/CTO/QA), standard=6 (+Code Reviewer/Design/Delivery), full=all 11"
    $PersonasTier = Confirm-Choice $tierPrompt @("minimal","standard","full") "standard"
}
if (-not $SessionLogs) {
    $logsPrompt = "Session logs - local=gitignored/private, committed=travel with the repo (pick committed for teams or cloud agents)"
    $SessionLogs = Confirm-Choice $logsPrompt @("local","committed") "local"
}

Write-Host ""
Write-Host "Applying changes..." -ForegroundColor Cyan

$regen = (-not $alreadyCustomized) -or $Force

if ($ProjectName -and $regen) {
    Replace-InFile "AGENTS.md" 'Project name: `TODO`' "Project name: ``$ProjectName``" -Literal | Out-Null
}

if ($ProjectType) {
    Replace-InFile "AGENTS.md" 'Project type: `TODO`' "Project type: ``$ProjectType``" -Literal | Out-Null
}

if ($PrimaryAgent) {
    Replace-InFile "AGENTS.md" 'Primary agent: `TODO`' "Primary agent: ``$PrimaryAgent``" -Literal | Out-Null
}

if ($PrimaryUser) {
    Replace-InFile "AGENTS.md" 'Primary user: `TODO`' "Primary user: ``$PrimaryUser``" -Literal | Out-Null
}

if ($CurrentStage) {
    Replace-InFile "AGENTS.md" 'Current stage: `prototype | active build | maintenance | archived`' "Current stage: ``$CurrentStage``" -Literal | Out-Null
}

if ($Vibe) {
    Replace-InFile "AGENTS.md" '(?ms)```text\r?\nTODO: one or two paragraphs.*?\r?\n```' "``````text`n$Vibe`n``````" | Out-Null
}

if ($regen) {
    Write-ProjectBrief -Name $ProjectName -Type $ProjectType -Feeling $Vibe -User $PrimaryUser -Stage $CurrentStage
    Write-ForkReadme -Name $ProjectName -Type $ProjectType -Feeling $Vibe -User $PrimaryUser -Stage $CurrentStage
    Write-TodoStub -Name $ProjectName
    Write-RoadmapStub -Name $ProjectName
    Write-SessionIndex
} else {
    Write-Host "  skipped regenerating brief/README/TODO/ROADMAP (already customized; re-run with -Force to overwrite)" -ForegroundColor Yellow
}

if ($InstallCmd) {
    Replace-InFile "AGENTS.md" '(?m)^# Install dependencies\r?\nTODO\b' "# Install dependencies`n$InstallCmd" | Out-Null
}
if ($RunCmd) {
    Replace-InFile "AGENTS.md" '(?m)^# Run development server\r?\nTODO\b' "# Run development server`n$RunCmd" | Out-Null
}
if ($TestCmd) {
    Replace-InFile "AGENTS.md" '(?m)^# Run tests\r?\nTODO\b' "# Run tests`n$TestCmd" | Out-Null
}
if ($LintCmd) {
    Replace-InFile "AGENTS.md" '(?m)^# Run lint/type checks\r?\nTODO\b' "# Run lint/type checks`n$LintCmd" | Out-Null
}
if ($BuildCmd) {
    Replace-InFile "AGENTS.md" '(?m)^# Build\r?\nTODO\b' "# Build`n$BuildCmd" | Out-Null
}

Replace-InFile "AGENTS.md" 'Language/framework: `TODO`' "Language/framework: ``$ProjectType``" -Literal | Out-Null
Replace-InFile "AGENTS.md" 'Package manager: `TODO`' "Package manager: ``Not specified``" -Literal | Out-Null
Replace-InFile "AGENTS.md" 'Formatting: `TODO`' "Formatting: ``Follow surrounding code``" -Literal | Out-Null
Replace-InFile "AGENTS.md" 'Test framework: `TODO`' "Test framework: ``Not specified``" -Literal | Out-Null

# Keep the machine-readable AgentOps config aligned with the generated docs.
# JSON strings are valid YAML scalars and safely preserve spaces and punctuation.
$configMode = switch ($PersonasTier) {
    "minimal" { "lite" }
    "full" { "full-agentic" }
    default { "standard" }
}
if ($ProjectName) {
    Replace-InFile "agentops.config.yml" "  name: TODO" "  name: $(ConvertTo-YamlScalar $ProjectName)" -Literal | Out-Null
}
if ($ProjectType) {
    Replace-InFile "agentops.config.yml" "  type: TODO" "  type: $(ConvertTo-YamlScalar $ProjectType)" -Literal | Out-Null
}
if ($CurrentStage) {
    Replace-InFile "agentops.config.yml" "  stage: prototype" "  stage: $(ConvertTo-YamlScalar $CurrentStage)" -Literal | Out-Null
}
if ($PrimaryUser) {
    Replace-InFile "agentops.config.yml" "  primaryUser: TODO" "  primaryUser: $(ConvertTo-YamlScalar $PrimaryUser)" -Literal | Out-Null
}
Replace-InFile "agentops.config.yml" "  mode: standard" "  mode: $(ConvertTo-YamlScalar $configMode)" -Literal | Out-Null
if ($InstallCmd) {
    Replace-InFile "agentops.config.yml" "  install: TODO" "  install: $(ConvertTo-YamlScalar $InstallCmd)" -Literal | Out-Null
}
if ($RunCmd) {
    Replace-InFile "agentops.config.yml" "  dev: TODO" "  dev: $(ConvertTo-YamlScalar $RunCmd)" -Literal | Out-Null
}
if ($TestCmd) {
    Replace-InFile "agentops.config.yml" "  test: TODO" "  test: $(ConvertTo-YamlScalar $TestCmd)" -Literal | Out-Null
}
if ($LintCmd) {
    Replace-InFile "agentops.config.yml" "  lint: TODO" "  lint: $(ConvertTo-YamlScalar $LintCmd)" -Literal | Out-Null
}
if ($BuildCmd) {
    Replace-InFile "agentops.config.yml" "  build: TODO" "  build: $(ConvertTo-YamlScalar $BuildCmd)" -Literal | Out-Null
}

# Persona tiering
$tierDemotions = @{
    "minimal"  = @(
        "aegis-defensive-security.md",
        "code-reviewer-maintainability.md",
        "data-analytics-lead.md",
        "delivery-lead.md",
        "design-director-vibe-coding.md",
        "growth-launch-strategist.md",
        "ops-deployment-engineer.md",
        "research-scout.md"
    )
    "standard" = @(
        "aegis-defensive-security.md",
        "data-analytics-lead.md",
        "growth-launch-strategist.md",
        "ops-deployment-engineer.md",
        "research-scout.md"
    )
    "full"     = @()
}

if ($tierDemotions.ContainsKey($PersonasTier) -and $tierDemotions[$PersonasTier].Count -gt 0) {
    $optionalDir = Join-Path $root "personas/optional"
    if (-not (Test-Path -LiteralPath $optionalDir)) {
        New-Item -ItemType Directory -Path $optionalDir | Out-Null
    }
    foreach ($p in $tierDemotions[$PersonasTier]) {
        $src = Join-Path $root "personas/$p"
        $dst = Join-Path $optionalDir $p
        if (Test-Path -LiteralPath $src) {
            Move-Item -LiteralPath $src -Destination $dst -Force
            Write-Host "  moved personas/$p -> personas/optional/$p" -ForegroundColor DarkGray
        }
    }
}

if ($SessionLogs -eq "committed") {
    $gitignoreOld = "# Local session memory`n# Keep the folder index public, but keep actual session logs out of Git by default.`nSession Logs/*.md`n!Session Logs/_Session Logs Index.md"
    $gitignoreNew = "# Session logs are committed in this project (chosen at init).`n# To make them local-only again, ignore `"Session Logs/*.md`" and keep the index tracked."
    if (Replace-InFile ".gitignore" $gitignoreOld $gitignoreNew -Literal) {
        Write-Host "  session logs will be committed (.gitignore updated)" -ForegroundColor DarkGray
    } else {
        Write-Host "  could not update .gitignore for committed session logs; edit the Session Logs block manually" -ForegroundColor Yellow
    }
}

if ($PrimaryAgent) {
    Write-Host "  primary agent recorded as '$PrimaryAgent'" -ForegroundColor DarkGray
}

# Stamp the template version this fork was initialized from. Future CLI tooling
# uses this marker to detect upgradable forks.
$versionPath = Join-Path $root "VERSION"
$stampPath = Join-Path $root ".vibe-template-version"
if (Test-Path -LiteralPath $versionPath) {
    $stampVersion = (Get-Content -Raw -LiteralPath $versionPath).Trim()
    Set-Content -LiteralPath $stampPath -Value $stampVersion -NoNewline
    Write-Host "  recorded template version $stampVersion in .vibe-template-version" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Running drift check..." -ForegroundColor Cyan
& (Join-Path $PSScriptRoot "check-agent-docs.ps1")
$driftExit = $LASTEXITCODE

Write-Host ""
if ($driftExit -eq 0) {
    Write-Host "Setup complete." -ForegroundColor Green
} else {
    Write-Host "Setup ran but drift check failed -- see errors above." -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Refine docs/PROJECT_BRIEF.md after the first working slice."
Write-Host "  2. Replace the generated TODO.md / ROADMAP.md starters with real work."
Write-Host "  3. Run strict mode before the first real handoff:"
Write-Host "       ./scripts/check-agent-docs.ps1 -Strict"
Write-Host "  4. Make the first commit."
exit $driftExit
