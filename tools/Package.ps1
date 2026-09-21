param([string]$OutputDirectory = '')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $projectRoot 'dist' }
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$outputPath = Join-Path (Resolve-Path -LiteralPath $OutputDirectory).Path 'DontHighFive-standalone.zip'
$files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
foreach ($name in @('project.godot','README.md','CONTRIBUTING.md','Play.cmd','Edit.cmd','Verify.cmd','.gitignore','.gitattributes')) {
    $files.Add((Get-Item -LiteralPath (Join-Path $projectRoot $name) -Force))
}
foreach ($folder in @('.github','scripts','scenes','shaders','assets','tests','art','docs','licenses')) {
    foreach ($file in Get-ChildItem -LiteralPath (Join-Path $projectRoot $folder) -Recurse -File -Force) {
        if ($file.Extension -in '.blend1','.pyc','.log') { continue }
        if ($file.FullName -match '[\\/]__pycache__[\\/]') { continue }
        $files.Add($file)
    }
}
foreach ($file in Get-ChildItem -LiteralPath $PSScriptRoot -File -Force) { $files.Add($file) }
foreach ($name in @('Godot.exe','Godot_console.exe','_sc_')) {
    $files.Add((Get-Item -LiteralPath (Join-Path $PSScriptRoot ('godot/' + $name)) -Force))
}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
# Replacing this one generated artifact is intentional; no source directories move.
$stream = [System.IO.File]::Open($outputPath, [System.IO.FileMode]::Create)
$zip = [System.IO.Compression.ZipArchive]::new($stream, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in $files) {
        if ($file.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { throw "Refusing to package a link: $($file.FullName)" }
        $relative = $file.FullName.Substring($projectRoot.Length + 1).Replace('\','/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, ('dont-high-five/' + $relative), [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
} finally {
    $zip.Dispose()
    $stream.Dispose()
}
Write-Host "Packaged $($files.Count) files: $outputPath"
