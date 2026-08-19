param()

$ErrorActionPreference = "Stop"

$sourceRoot = Split-Path -Parent $PSScriptRoot
$tempParent = Join-Path ([System.IO.Path]::GetTempPath()) ("vibe-template-init-test-" + [System.Guid]::NewGuid().ToString("N"))
$tempRoot = Join-Path $tempParent "repo"

function Assert-Contains {
    param(
        [string]$Content,
        [string]$Expected,
        [string]$Label
    )
    if (-not $Content.Contains($Expected)) {
        throw "Missing expected $Label`: $Expected"
    }
}

function Copy-Template {
    param([string]$Destination)
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    Get-ChildItem -LiteralPath $sourceRoot -Force |
        Where-Object { $_.Name -notin @(".git", "node_modules", "reports") } |
        Copy-Item -Destination $Destination -Recurse -Force
}

try {
    Copy-Template -Destination $tempRoot

    & (Join-Path $tempRoot "scripts/init.ps1") `
        -NonInteractive `
        -ProjectName "Bootstrap Smoke Project" `
        -ProjectType "Node app" `
        -Vibe "A small verified fork that feels ready to build from." `
        -PrimaryUser "Solo builder" `
        -InstallCmd "npm install" `
        -RunCmd "npm run dev" `
        -TestCmd "npm test" `
        -LintCmd "npm run lint" `
        -BuildCmd "npm run build" `
        -PrimaryAgent "codex" `
        -CurrentStage "prototype" `
        -PersonasTier "full"

    if ($LASTEXITCODE -ne 0) {
        throw "init.ps1 failed with exit code $LASTEXITCODE"
    }

    $agents = Get-Content -Raw -LiteralPath (Join-Path $tempRoot "AGENTS.md")
    Assert-Contains $agents 'Project name: `Bootstrap Smoke Project`' "project name"
    Assert-Contains $agents 'Project type: `Node app`' "project type"
    Assert-Contains $agents 'Primary agent: `codex`' "primary agent"
    Assert-Contains $agents 'Primary user: `Solo builder`' "primary user"
    Assert-Contains $agents 'Current stage: `prototype`' "current stage"
    Assert-Contains $agents "A small verified fork that feels ready to build from." "product goal"
    Assert-Contains $agents "npm install" "install command"
    Assert-Contains $agents "npm run dev" "run command"
    Assert-Contains $agents "npm test" "test command"
    Assert-Contains $agents "npm run lint" "lint command"
    Assert-Contains $agents "npm run build" "build command"

    $brief = Get-Content -Raw -LiteralPath (Join-Path $tempRoot "docs/PROJECT_BRIEF.md")
    Assert-Contains $brief "Bootstrap Smoke Project is a Node app project." "generated project brief summary"
    Assert-Contains $brief "Primary user: Solo builder" "generated project brief user"

    $readme = Get-Content -Raw -LiteralPath (Join-Path $tempRoot "README.md")
    Assert-Contains $readme "# Bootstrap Smoke Project" "generated README title"
    Assert-Contains $readme "npm install" "generated README install command"
    Assert-Contains $readme "AGENTS.md" "generated README agent contract pointer"
    Assert-Contains $readme "Built from the AgentOps Template" "generated README provenance"

    $config = Get-Content -Raw -LiteralPath (Join-Path $tempRoot "agentops.config.yml")
    Assert-Contains $config 'name: "Bootstrap Smoke Project"' "AgentOps config project name"
    Assert-Contains $config 'type: "Node app"' "AgentOps config project type"
    Assert-Contains $config 'primaryUser: "Solo builder"' "AgentOps config primary user"
    Assert-Contains $config 'mode: "full-agentic"' "AgentOps config full mode"
    Assert-Contains $config 'test: "npm test"' "AgentOps config test command"

    $todo = Get-Content -Raw -LiteralPath (Join-Path $tempRoot "TODO.md")
    Assert-Contains $todo "Working queue for Bootstrap Smoke Project" "generated TODO stub"

    $roadmap = Get-Content -Raw -LiteralPath (Join-Path $tempRoot "ROADMAP.md")
    Assert-Contains $roadmap "Medium-term direction for Bootstrap Smoke Project" "generated ROADMAP stub"

    $index = Get-Content -Raw -LiteralPath (Join-Path $tempRoot "Session Logs/_Session Logs Index.md")
    Assert-Contains $index "Add one row per session log" "reset session log index"
    if ($index.Contains("Obsidian")) {
        throw "Session log index still contains template-author residue"
    }

    $stampPath = Join-Path $tempRoot ".vibe-template-version"
    $expectedVersion = (Get-Content -Raw -LiteralPath (Join-Path $sourceRoot "VERSION")).Trim()
    if (-not (Test-Path -LiteralPath $stampPath)) {
        throw "Missing .vibe-template-version stamp"
    }
    $actualVersion = (Get-Content -Raw -LiteralPath $stampPath).Trim()
    if ($actualVersion -ne $expectedVersion) {
        throw "Version stamp mismatch: expected $expectedVersion, got $actualVersion"
    }

    & (Join-Path $tempRoot "scripts/check-agent-docs.ps1")
    if ($LASTEXITCODE -ne 0) {
        throw "check-agent-docs.ps1 failed in temp copy with exit code $LASTEXITCODE"
    }

    & (Join-Path $tempRoot "scripts/check-agent-docs.ps1") -Strict
    if ($LASTEXITCODE -ne 0) {
        throw "check-agent-docs.ps1 -Strict failed in temp copy with exit code $LASTEXITCODE"
    }

    & (Join-Path $tempRoot "scripts/check-agent-behavior.ps1")
    if ($LASTEXITCODE -ne 0) {
        throw "check-agent-behavior.ps1 failed in generated fork with exit code $LASTEXITCODE"
    }

    $allPersonas = @(
        "aegis-defensive-security.md",
        "code-reviewer-maintainability.md",
        "cto-vibe-coding.md",
        "data-analytics-lead.md",
        "delivery-lead.md",
        "design-director-vibe-coding.md",
        "growth-launch-strategist.md",
        "head-of-product-vibe-coding.md",
        "ops-deployment-engineer.md",
        "qa-acceptance-tester.md",
        "research-scout.md"
    )
    foreach ($p in $allPersonas) {
        if (-not (Test-Path -LiteralPath (Join-Path $tempRoot "personas/$p"))) {
            throw "Full tier missing persona: $p"
        }
    }

    # Standard-tier verification: demoted set should land under personas/optional/.
    $standardRoot = Join-Path $tempParent "repo-standard"
    Copy-Template -Destination $standardRoot

    & (Join-Path $standardRoot "scripts/init.ps1") `
        -NonInteractive `
        -ProjectName "Standard Tier Smoke" `
        -ProjectType "Web app" `
        -Vibe "A standard-tier fork with the ship-it personas." `
        -PrimaryUser "Solo builder" `
        -InstallCmd "npm install" `
        -RunCmd "npm run dev" `
        -TestCmd "npm test" `
        -LintCmd "npm run lint" `
        -BuildCmd "npm run build" `
        -PrimaryAgent "claude" `
        -CurrentStage "prototype" `
        -PersonasTier "standard" `
        -SessionLogs "committed" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "init.ps1 (standard tier) failed with exit code $LASTEXITCODE"
    }

    $kept = @(
        "head-of-product-vibe-coding.md",
        "cto-vibe-coding.md",
        "qa-acceptance-tester.md",
        "code-reviewer-maintainability.md",
        "design-director-vibe-coding.md",
        "delivery-lead.md"
    )
    foreach ($p in $kept) {
        $path = Join-Path $standardRoot "personas/$p"
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Standard tier missing kept persona: $p"
        }
    }

    $demoted = @(
        "aegis-defensive-security.md",
        "data-analytics-lead.md",
        "growth-launch-strategist.md",
        "ops-deployment-engineer.md",
        "research-scout.md"
    )
    foreach ($p in $demoted) {
        $optional = Join-Path $standardRoot "personas/optional/$p"
        $core = Join-Path $standardRoot "personas/$p"
        if (-not (Test-Path -LiteralPath $optional)) {
            throw "Standard tier did not demote persona: $p"
        }
        if (Test-Path -LiteralPath $core) {
            throw "Standard tier left persona in personas/ when it should have moved: $p"
        }
    }

    # Committed session-log mode must replace the ignore rule with the note.
    $gitignore = Get-Content -Raw -LiteralPath (Join-Path $standardRoot ".gitignore")
    Assert-Contains $gitignore "committed in this project" "committed session-log gitignore note"
    if ($gitignore -match '(?m)^Session Logs/\*\.md') {
        throw "Committed session-log mode left an active ignore rule in .gitignore"
    }

    $standardConfig = Get-Content -Raw -LiteralPath (Join-Path $standardRoot "agentops.config.yml")
    Assert-Contains $standardConfig 'mode: "standard"' "standard AgentOps config mode"

    # Minimal-tier verification: only Product, CTO, and QA remain active.
    $minimalRoot = Join-Path $tempParent "repo-minimal"
    Copy-Template -Destination $minimalRoot

    & (Join-Path $minimalRoot "scripts/init.ps1") `
        -NonInteractive `
        -ProjectName "Minimal Tier Smoke" `
        -ProjectType "CLI" `
        -Vibe "A minimal generated fork with only the core decision roles." `
        -PrimaryUser "Solo builder" `
        -InstallCmd "npm install" `
        -RunCmd "npm run dev" `
        -TestCmd "npm test" `
        -LintCmd "npm run lint" `
        -BuildCmd "npm run build" `
        -PrimaryAgent "codex" `
        -CurrentStage "prototype" `
        -PersonasTier "minimal" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "init.ps1 (minimal tier) failed with exit code $LASTEXITCODE"
    }

    foreach ($p in @("head-of-product-vibe-coding.md", "cto-vibe-coding.md", "qa-acceptance-tester.md")) {
        if (-not (Test-Path -LiteralPath (Join-Path $minimalRoot "personas/$p"))) {
            throw "Minimal tier missing kept persona: $p"
        }
    }
    foreach ($p in @(
        "aegis-defensive-security.md",
        "code-reviewer-maintainability.md",
        "data-analytics-lead.md",
        "delivery-lead.md",
        "design-director-vibe-coding.md",
        "growth-launch-strategist.md",
        "ops-deployment-engineer.md",
        "research-scout.md"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $minimalRoot "personas/optional/$p"))) {
            throw "Minimal tier did not demote persona: $p"
        }
        if (Test-Path -LiteralPath (Join-Path $minimalRoot "personas/$p")) {
            throw "Minimal tier left persona active when it should be optional: $p"
        }
    }

    $minimalConfig = Get-Content -Raw -LiteralPath (Join-Path $minimalRoot "agentops.config.yml")
    Assert-Contains $minimalConfig 'mode: "lite"' "minimal AgentOps config mode"
    & (Join-Path $minimalRoot "scripts/check-agent-docs.ps1") -Strict
    if ($LASTEXITCODE -ne 0) {
        throw "check-agent-docs.ps1 -Strict failed for minimal fork with exit code $LASTEXITCODE"
    }

    Write-Host "PowerShell init smoke tests passed (full, standard, minimal)." -ForegroundColor Green
}
finally {
    if (Test-Path -LiteralPath $tempParent) {
        Remove-Item -LiteralPath $tempParent -Recurse -Force
    }
}
