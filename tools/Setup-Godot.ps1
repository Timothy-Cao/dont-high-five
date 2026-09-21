param()
$ErrorActionPreference = 'Stop'
$runtimeRoot = Join-Path $PSScriptRoot 'godot'
$cacheRoot = Join-Path (Split-Path -Parent $PSScriptRoot) '.local/setup'
New-Item -ItemType Directory -Path $runtimeRoot,$cacheRoot -Force | Out-Null
$archivePath = Join-Path $cacheRoot 'Godot_v4.7.2-stable_win64.exe.zip'
$downloadUrl = 'https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_win64.exe.zip'
$expectedHash = '731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953'
if (-not (Test-Path -LiteralPath $archivePath)) {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath
}
if ((Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expectedHash) {
    throw "Godot archive checksum mismatch. Remove only $archivePath and retry."
}
# Extract only the two known files; never trust arbitrary archive paths.
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($archivePath)
try {
    foreach ($pair in @(@('Godot_v4.7.2-stable_win64.exe','Godot.exe'),@('Godot_v4.7.2-stable_win64_console.exe','Godot_console.exe'))) {
        $entry = $archive.GetEntry($pair[0])
        if ($null -eq $entry) { throw "Missing Godot binary: $($pair[0])" }
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry,(Join-Path $runtimeRoot $pair[1]),$true)
    }
} finally { $archive.Dispose() }
New-Item -ItemType File -Path (Join-Path $runtimeRoot '_sc_') -Force | Out-Null
Write-Host 'Godot 4.7.2 is ready. Run Play.cmd, Edit.cmd or Verify.cmd.'
