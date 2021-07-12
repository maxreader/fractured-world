$mod_directory = 'C:\Users\travi\AppData\Roaming\Factorio\mods'
$github_directory = 'C:\Users\travi\AppData\Roaming\Factorio\fractured-world'
$mods = @('fractured-world',
    'aaa-fractured-world-data-scraper')

foreach ($mod in $mods) {
    # Load mod info
    $info = Get-Content -Raw -Path ($github_directory + '\' + $mod + '\info.json') | ConvertFrom-Json

    # Find and delete any existing symlinks
    $links = Get-Childitem -Path ($mod_directory) -Filter ($info.name + '*')

    if ($null -ne $links) {
        foreach ($link in $links) {
            if ($link.linktype -eq 'SymbolicLink') {
                $link.Delete()
            }
        }
    }

    # Create new symlink
    New-Item -ItemType SymbolicLink -Path ($mod_directory + '\' + $info.name) -Target ($github_directory + '\' + $mod)
}
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');