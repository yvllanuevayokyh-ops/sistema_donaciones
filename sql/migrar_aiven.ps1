param(
    [string]$RemoteHost = "server-db-sd-server-db-sd.a.aivencloud.com",
    [int]$RemotePort = 14732,
    [string]$RemoteUser = "avnadmin",
    [string]$RemotePassword = "",
    [string]$Database = "sistema_donaciones",
    [string]$LocalHost = "localhost",
    [int]$LocalPort = 3306,
    [string]$LocalUser = "root",
    [string]$LocalPassword = "",
    [string]$MysqlExe = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
    [string]$MysqldumpExe = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe",
    [switch]$ForceRebuild
)

$ErrorActionPreference = "Stop"

function Invoke-MySqlQuery {
    param(
        [string]$ServerHost,
        [int]$Port,
        [string]$User,
        [string]$Password,
        [string]$Query
    )

    $previous = $env:MYSQL_PWD
    try {
        $env:MYSQL_PWD = $Password
        $output = & $MysqlExe `
            -h $ServerHost `
            -P $Port `
            -u $User `
            --ssl-mode=REQUIRED `
            --connect-timeout=20 `
            --default-character-set=utf8mb4 `
            -N `
            -e $Query
        if ($LASTEXITCODE -ne 0) {
            throw "mysql.exe devolvio codigo $LASTEXITCODE para query: $Query"
        }
        return @($output)
    } finally {
        if ($null -eq $previous) {
            Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
        } else {
            $env:MYSQL_PWD = $previous
        }
    }
}

function Get-ScalarInt {
    param([string[]]$Rows)
    if ($Rows.Count -eq 0) { return 0 }
    $value = $Rows[0].ToString().Trim()
    if ([string]::IsNullOrWhiteSpace($value)) { return 0 }
    return [int]$value
}

if (-not (Test-Path $MysqlExe)) {
    throw "No se encontro mysql.exe en: $MysqlExe"
}
if (-not (Test-Path $MysqldumpExe)) {
    throw "No se encontro mysqldump.exe en: $MysqldumpExe"
}
if ([string]::IsNullOrWhiteSpace($RemotePassword)) {
    throw "Debes enviar -RemotePassword para conectarte a Aiven."
}

Write-Output "Verificando conectividad remota [${RemoteHost}:${RemotePort}]..."
try {
    [void](Invoke-MySqlQuery -ServerHost $RemoteHost -Port $RemotePort -User $RemoteUser -Password $RemotePassword -Query "SELECT 1;")
} catch {
    throw "No se pudo autenticar contra la BD remota. Verifica usuario/password y lista de IPs permitidas en Aiven. Detalle: $($_.Exception.Message)"
}

Write-Output "Verificando existencia de base [$Database]..."
$dbExists = Get-ScalarInt (Invoke-MySqlQuery -ServerHost $RemoteHost -Port $RemotePort -User $RemoteUser -Password $RemotePassword -Query "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='$Database';")
if ($dbExists -eq 0) {
    Write-Output "La base no existe, creando..."
    [void](Invoke-MySqlQuery -ServerHost $RemoteHost -Port $RemotePort -User $RemoteUser -Password $RemotePassword -Query "CREATE DATABASE $Database CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
}

$remoteTableCount = Get-ScalarInt (Invoke-MySqlQuery -ServerHost $RemoteHost -Port $RemotePort -User $RemoteUser -Password $RemotePassword -Query "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$Database';")
$remoteProcCount = Get-ScalarInt (Invoke-MySqlQuery -ServerHost $RemoteHost -Port $RemotePort -User $RemoteUser -Password $RemotePassword -Query "SELECT COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='$Database' AND ROUTINE_TYPE='PROCEDURE';")
$remoteRowCount = Get-ScalarInt (Invoke-MySqlQuery -ServerHost $RemoteHost -Port $RemotePort -User $RemoteUser -Password $RemotePassword -Query "SELECT COALESCE(SUM(TABLE_ROWS),0) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$Database';")

Write-Output "Estado remoto actual: tablas=$remoteTableCount, procedimientos=$remoteProcCount, filas_aprox=$remoteRowCount"

if (-not $ForceRebuild -and $remoteTableCount -gt 0 -and $remoteProcCount -gt 0 -and $remoteRowCount -gt 0) {
    Write-Output "La BD remota ya tiene estructura, SP e inserciones. No se migra nada (usa -ForceRebuild para forzar)."
    exit 0
}

Write-Output "Preparando dump de BD local [$Database]..."
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$dumpRaw = Join-Path $env:TEMP ("sd_migracion_raw_" + $stamp + ".sql")
$dumpClean = Join-Path $env:TEMP ("sd_migracion_clean_" + $stamp + ".sql")

$previousLocal = $env:MYSQL_PWD
try {
    if ([string]::IsNullOrEmpty($LocalPassword)) {
        Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
    } else {
        $env:MYSQL_PWD = $LocalPassword
    }

    $dumpOutput = & $MysqldumpExe `
        -h $LocalHost `
        -P $LocalPort `
        -u $LocalUser `
        --default-character-set=utf8mb4 `
        --single-transaction `
        --skip-column-statistics `
        --routines `
        --triggers `
        --events `
        --databases $Database 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "mysqldump fallo: $dumpOutput"
    }
    $dumpOutput | Set-Content -Path $dumpRaw -Encoding UTF8
} finally {
    if ($null -eq $previousLocal) {
        Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
    } else {
        $env:MYSQL_PWD = $previousLocal
    }
}

Write-Output "Normalizando dump (removiendo definers locales)..."
$dumpText = Get-Content -Path $dumpRaw -Raw -Encoding UTF8
$dumpText = $dumpText -replace 'DEFINER=`[^`]+`@`[^`]+` ', ''
$dumpText = $dumpText -replace 'SQL SECURITY DEFINER', 'SQL SECURITY INVOKER'
Set-Content -Path $dumpClean -Value $dumpText -Encoding UTF8

if ($ForceRebuild) {
    Write-Output "Recreando base remota por -ForceRebuild..."
    [void](Invoke-MySqlQuery -ServerHost $RemoteHost -Port $RemotePort -User $RemoteUser -Password $RemotePassword -Query "DROP DATABASE IF EXISTS $Database; CREATE DATABASE $Database CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
}

Write-Output "Importando dump limpio hacia Aiven..."
$previousRemote = $env:MYSQL_PWD
try {
    $env:MYSQL_PWD = $RemotePassword
    $sourcePath = (Resolve-Path $dumpClean).Path.Replace('\', '/')
    & $MysqlExe `
        -h $RemoteHost `
        -P $RemotePort `
        -u $RemoteUser `
        --ssl-mode=REQUIRED `
        --connect-timeout=20 `
        --default-character-set=utf8mb4 `
        -e "SOURCE $sourcePath"
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo importando dump en remoto."
    }
} finally {
    if ($null -eq $previousRemote) {
        Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
    } else {
        $env:MYSQL_PWD = $previousRemote
    }
}

Write-Output "Validando migracion remota..."
$remoteTableCount2 = Get-ScalarInt (Invoke-MySqlQuery -ServerHost $RemoteHost -Port $RemotePort -User $RemoteUser -Password $RemotePassword -Query "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$Database';")
$remoteProcCount2 = Get-ScalarInt (Invoke-MySqlQuery -ServerHost $RemoteHost -Port $RemotePort -User $RemoteUser -Password $RemotePassword -Query "SELECT COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='$Database' AND ROUTINE_TYPE='PROCEDURE';")
$remoteRowCount2 = Get-ScalarInt (Invoke-MySqlQuery -ServerHost $RemoteHost -Port $RemotePort -User $RemoteUser -Password $RemotePassword -Query "SELECT COALESCE(SUM(TABLE_ROWS),0) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$Database';")

Write-Output "Estado remoto final: tablas=$remoteTableCount2, procedimientos=$remoteProcCount2, filas_aprox=$remoteRowCount2"
Write-Output "Migracion completada."
