$watcher = New-Object FileSystemWatcher
$watcher.Path = "$PSScriptRoot\lib"
$watcher.Filter = "*.dart"
$watcher.EnableRaisingEvents = $true
$watcher.IncludeSubdirectories = $true

$action = {
    Start-Sleep -Milliseconds 300
    $null = [System.Console]::OpenStandardInput()
    Start-Sleep -Milliseconds 50
    $host.ui.rawui.KeyAvailable = $false
    [System.Console]::Write("r")
}

Register-ObjectEvent $watcher "Changed" -Action $action | Out-Null
Register-ObjectEvent $watcher "Created" -Action $action | Out-Null
Register-ObjectEvent $watcher "Renamed" -Action $action | Out-Null

Write-Host "Monitoreando cambios en lib/... Guarda un archivo .dart y se enviara 'r' automaticamente."
Write-Host "Presiona Ctrl+C para detener."

flutter run -d emulator-5554

Get-EventSubscriber | Unregister-Event
