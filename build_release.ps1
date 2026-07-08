<#
.SYNOPSIS
    Builds release artifacts for Cowtastic Cafe's Archipelago integration.

.DESCRIPTION
    1. Rebuilds the .apworld: cleans __pycache__, deletes the old bundle, and
       re-zips Cowtastic/cowtastic_cafe/ as cowtastic_cafe.apworld (with the
       folder as the zip root, which AP requires).
    2. Packages each Unity build it finds (Windows/Linux/Mac) into its own
       per-platform versioned zip. Platforms with no build folder are skipped.
    3. Collects everything into Output_AP/ alongside a generated SETUP.txt.

    The Unity builds themselves are NOT produced here - build each target from
    the Unity Editor (File > Build Settings > select platform > Build) into its
    folder first, then run this script to package whatever exists. Producing
    Linux/Mac targets requires the matching Build Support modules installed via
    Unity Hub. The mod is pure managed code (Game.dll), so no source changes are
    needed to run on other platforms.

.PARAMETER BuildDir
    Folder containing the finished Windows Unity build. Default: ./Output
    The folder's name becomes the root folder inside the game zip, so building
    into a nicely-named folder (e.g. "Cowtastic Cafe") gives a tidier archive.

.PARAMETER LinuxDir
    Folder containing the finished Linux Unity build. Default: ./Output-Linux
    Packaged only if the folder exists and is non-empty.

.PARAMETER MacDir
    Folder containing the finished Mac Unity build (the .app's parent folder).
    Default: ./Output-Mac. Packaged only if the folder exists and is non-empty.

.PARAMETER SkipGame
    Only rebuild the .apworld; don't touch the Unity builds.

.EXAMPLE
    ./build_release.ps1
.EXAMPLE
    ./build_release.ps1 -BuildDir "C:\builds\Cowtastic Cafe"
.EXAMPLE
    ./build_release.ps1 -LinuxDir "C:\builds\Cowtastic-Linux"
.EXAMPLE
    ./build_release.ps1 -SkipGame
#>
[CmdletBinding()]
param(
    [string]$BuildDir   = (Join-Path $PSScriptRoot 'Output'),
    [string]$LinuxDir   = (Join-Path $PSScriptRoot 'Output-Linux'),
    [string]$MacDir     = (Join-Path $PSScriptRoot 'Output-Mac'),
    [string]$ReleaseDir = (Join-Path $PSScriptRoot 'Output_AP'),
    [switch]$SkipGame
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression           # ZipArchive, ZipArchiveMode
Add-Type -AssemblyName System.IO.Compression.FileSystem # ZipFile, ZipFileExtensions

$WorldName  = 'cowtastic_cafe'
$WorldDir   = Join-Path $PSScriptRoot "Cowtastic\$WorldName"
$ApworldOut = Join-Path $PSScriptRoot "Cowtastic\$WorldName.apworld"

function New-Zip {
    # Builds entries manually with forward-slash separators. .NET's
    # CreateFromDirectory uses the OS separator (backslash on Windows), which
    # breaks Python's zipimport - the mechanism Archipelago uses to load
    # apworlds. Forward slashes are also universally safe for the game zip.
    #
    # -RootName overrides the top-level folder inside the zip when
    # -IncludeRootFolder is set (default: the source folder's own name), so a
    # build folder like "Output-Linux" can extract as a tidy "Cowtastic Cafe".
    # Unity "*_BurstDebugInformation_DoNotShip" / "*_BackUpThisFolder_*" build
    # cruft is always excluded - Unity marks it as debug data, not for release.
    param(
        [string]$SourceDir,
        [string]$DestZip,
        [bool]$IncludeRootFolder,
        [string]$RootName = ''
    )
    if (Test-Path $DestZip) { Remove-Item $DestZip -Force }

    $SourceDir = (Resolve-Path $SourceDir).Path.TrimEnd('\')
    $baseLen   = $SourceDir.Length + 1
    $prefix    = ''
    if ($IncludeRootFolder) {
        $root   = if ($RootName) { $RootName } else { Split-Path $SourceDir -Leaf }
        $prefix = $root + '/'
    }

    $zip = [System.IO.Compression.ZipFile]::Open(
        $DestZip, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($file in Get-ChildItem $SourceDir -Recurse -File) {
            $rel = $file.FullName.Substring($baseLen) -replace '\\', '/'
            if ($rel -match '_BurstDebugInformation_DoNotShip/' -or
                $rel -match '_BackUpThisFolder_ButDontShipItWithYourGame/') {
                continue  # Unity debug cruft - never ship it.
            }
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                $zip, $file.FullName, ($prefix + $rel),
                [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
        }
    } finally {
        $zip.Dispose()
    }
}

# --- Read version from the manifest --------------------------------------
if (-not (Test-Path $WorldDir)) { throw "World source not found: $WorldDir" }
$manifest = Get-Content (Join-Path $WorldDir 'archipelago.json') -Raw | ConvertFrom-Json
$version  = $manifest.world_version
Write-Host "Cowtastic Cafe release - apworld v$version" -ForegroundColor Cyan

# --- Fresh release dir ---------------------------------------------------
if (Test-Path $ReleaseDir) { Remove-Item $ReleaseDir -Recurse -Force }
New-Item -ItemType Directory -Path $ReleaseDir | Out-Null

# --- 1. Build the .apworld ----------------------------------------------
Write-Host "`n[1/3] Building .apworld..." -ForegroundColor Yellow

# Strip compiled-python cruft so it doesn't end up in the bundle.
Get-ChildItem $WorldDir -Recurse -Directory -Filter '__pycache__' -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force
Get-ChildItem $WorldDir -Recurse -File -Filter '*.pyc' -ErrorAction SilentlyContinue |
    Remove-Item -Force

# IncludeRootFolder = $true  ->  zip contains "cowtastic_cafe/..." (required).
$tmpZip = Join-Path $PSScriptRoot "Cowtastic\$WorldName.zip"
New-Zip -SourceDir $WorldDir -DestZip $tmpZip -IncludeRootFolder $true
if (Test-Path $ApworldOut) { Remove-Item $ApworldOut -Force }
Move-Item $tmpZip $ApworldOut
Copy-Item $ApworldOut (Join-Path $ReleaseDir "$WorldName.apworld")
Write-Host "  -> $WorldName.apworld" -ForegroundColor Green

# --- 2. Package the Unity builds ----------------------------------------
# One zip per platform whose build folder exists and is non-empty. Missing
# platforms are skipped quietly (you may only build one target at a time).
$Platforms = @(
    [pscustomobject]@{ Name = 'Windows'; Dir = $BuildDir }
    [pscustomobject]@{ Name = 'Linux';   Dir = $LinuxDir }
    [pscustomobject]@{ Name = 'Mac';     Dir = $MacDir }
)
$builtGames = @()
if (-not $SkipGame) {
    Write-Host "`n[2/3] Packaging Unity builds..." -ForegroundColor Yellow
    foreach ($p in $Platforms) {
        if ((Test-Path $p.Dir) -and
            (Get-ChildItem $p.Dir -ErrorAction SilentlyContinue)) {
            $gameZip = Join-Path $ReleaseDir ("CowtasticCafe-{0}-v{1}.zip" -f $p.Name, $version)
            # Extracts as a single tidy "Cowtastic Cafe" folder regardless of the
            # build folder's name (Output / Output-Linux / Output-Mac).
            New-Zip -SourceDir $p.Dir -DestZip $gameZip -IncludeRootFolder $true `
                    -RootName 'Cowtastic Cafe'
            $sizeMb = [math]::Round((Get-Item $gameZip).Length / 1MB, 1)
            $leaf   = Split-Path $gameZip -Leaf
            Write-Host ("  -> {0} ({1} MB)" -f $leaf, $sizeMb) -ForegroundColor Green
            $builtGames += [pscustomobject]@{ Platform = $p.Name; Zip = $leaf }
        } else {
            Write-Host ("  (skip {0}: no build at {1})" -f $p.Name, $p.Dir) -ForegroundColor DarkGray
        }
    }
    if (-not $builtGames) {
        Write-Warning "  No platform builds found."
        Write-Warning "  Build from the Unity Editor first, then re-run (or use -SkipGame)."
    }
} else {
    Write-Host "`n[2/3] Skipping Unity builds (-SkipGame)." -ForegroundColor DarkGray
}

# --- 3. Generate SETUP.txt ----------------------------------------------
Write-Host "`n[3/3] Writing SETUP.txt..." -ForegroundColor Yellow

# List whichever game zips were actually packaged, plus any non-Windows notes.
if ($builtGames) {
    $gameList = ($builtGames | ForEach-Object {
        "  {0}  - the modded game ({1})." -f $_.Zip, $_.Platform }) -join "`n"
} else {
    $gameList = "  (no game build packaged this run - build in Unity, then re-run)"
}
$platformNotes = ''
if ($builtGames | Where-Object { $_.Platform -ne 'Windows' }) {
    $platformNotes = @"

LINUX / MAC NOTES
  These zips are built on Windows, which cannot store the Unix executable bit.
  After extracting:
    Linux:  chmod +x the game's *.x86_64 launcher, then run it.
    Mac:    Gatekeeper may block the .app - clear the quarantine flag with
              xattr -dr com.apple.quarantine "<Game>.app"
            A Mac .app also holds symlinks/permissions a Windows-made zip can
            drop; for a dependable Mac package, zip the .app on macOS instead.

"@
}

$setup = @"
Cowtastic Cafe - Archipelago Setup (apworld v$version)
======================================================

WHAT'S IN THIS RELEASE
  $WorldName.apworld  - the Archipelago world definition.
$gameList

INSTALL THE APWORLD (needed to generate a multiworld)
  1. Install Archipelago: https://github.com/ArchipelagoMW/Archipelago/releases
  2. Double-click $WorldName.apworld  - OR -  copy it into:
       <Archipelago install>\custom_worlds\
  3. Restart the Archipelago Launcher.

MAKE A YAML
  1. In the Launcher, open "Generate Template Options" and grab the
     Cowtastic Cafe template, or write a yaml with these options:
       drinks_per_check:       how many drinks per ingredient = 1 check
       checks_per_ingredient:  how many checks each ingredient grants
       shop_locations:         how many shop-slot checks exist
  2. Put your yaml in the Players/ folder and Generate.

PLAY
  1. Unzip the game zip for your platform and run the game.
  2. On the main menu, enter the server host, port, and your slot name,
     then click Connect. The game loads on a successful connection.
$platformNotes
GOAL
  Collect all milk-capacity upgrades to reach maximum milk.
"@
Set-Content -Path (Join-Path $ReleaseDir 'SETUP.txt') -Value $setup -Encoding utf8
Write-Host "  -> SETUP.txt" -ForegroundColor Green

Write-Host "`nDone. Release contents in: $ReleaseDir" -ForegroundColor Cyan
foreach ($f in Get-ChildItem $ReleaseDir) {
    $sz = if ($f.PSIsContainer) { '<dir>' }
          else { '{0} KB' -f [math]::Round($f.Length / 1KB, 1) }
    Write-Host ("  {0,-40} {1}" -f $f.Name, $sz)
}
