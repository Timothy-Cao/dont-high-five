param([ValidateSet('Play','Edit','Verify','Import')][string]$Mode = 'Play')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$engine = Join-Path $PSScriptRoot 'godot/Godot_console.exe'
$windowEngine = Join-Path $PSScriptRoot 'godot/Godot.exe'
$logRoot = Join-Path $projectRoot '.local/logs'
New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $projectRoot '.local/reports') -Force | Out-Null
if (-not (Test-Path -LiteralPath $engine)) {
    Write-Host 'Bundled Godot is missing. Put Godot 4.7.2 Windows x64 executables in tools/godot/ as Godot.exe and Godot_console.exe, or import project.godot into your installed editor.'
    exit 1
}
function Invoke-CheckedEngine([string]$LogName, [string[]]$EngineArgs) {
    $log = Join-Path $logRoot $LogName
    & $engine --path $projectRoot --log-file $log @EngineArgs
    if ($LASTEXITCODE -ne 0) { throw "Godot failed. See $log" }
    if ((Test-Path -LiteralPath $log) -and (Select-String -LiteralPath $log -Pattern 'SCRIPT ERROR:|Parse Error:|^FAIL  ' -Quiet)) {
        throw "Godot reported a script or test failure. See $log"
    }
}
try {
    # A copied source project needs its GLB import cache before running a scene.
    if ($Mode -in 'Verify','Import' -or -not (Test-Path -LiteralPath (Join-Path $projectRoot '.godot/imported'))) {
        Invoke-CheckedEngine 'import.log' @('--headless','--editor','--import','--quit')
    }
    if ($Mode -eq 'Import') { exit 0 }
    if ($Mode -eq 'Verify') {
        foreach ($suite in @('verify','metrics','polish','arena-verify')) {
            Invoke-CheckedEngine ($suite + '.log') @('--headless','--',('--' + $suite))
        }
        Write-Host 'All four suites passed. Reports and logs are in .local/.'
        exit 0
    }
    $arguments = @('--path', ('"' + $projectRoot + '"'), '--log-file', ('"' + (Join-Path $logRoot ($Mode.ToLower() + '.log')) + '"'))
    if ($Mode -eq 'Edit') { $arguments += '--editor' }
    # Play/Edit are user-invoked interactive launchers: show a normal visible window.
    Start-Process -FilePath $windowEngine -ArgumentList $arguments -WorkingDirectory $projectRoot -WindowStyle Normal
    exit 0
} catch {
    Write-Host $_.Exception.Message
    exit 1
}
