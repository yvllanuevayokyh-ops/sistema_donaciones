param(
    [string]$MysqlExe = "C:\xampp\mysql\bin\mysql.exe",
    [string]$User = "root",
    [string]$Database = "sistema_donaciones",
    [switch]$Reset
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $MysqlExe)) {
    throw "No se encontro mysql.exe en: $MysqlExe"
}

$scriptRoot = $PSScriptRoot
$scripts = @(
    "schema_base.sql",
    "roles_permisos_base.sql",
    "sp_institucion_base.sql",
    "sp_campania_base.sql",
    "sp_comunidad_base.sql",
    "sp_voluntario_base.sql",
    "sp_donacion_base.sql",
    "sp_entregas_finanzas.sql",
    "seed_datos_humanizados.sql"
)

if ($Reset) {
    Write-Output "Reset de base [$Database]..."
    $dropCreate = "DROP DATABASE IF EXISTS $Database; CREATE DATABASE IF NOT EXISTS $Database CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    & $MysqlExe -u $User --default-character-set=utf8mb4 -e $dropCreate
    if ($LASTEXITCODE -ne 0) {
        throw "No se pudo reiniciar la base [$Database]."
    }
}

foreach ($name in $scripts) {
    $path = Join-Path $scriptRoot $name
    if (-not (Test-Path $path)) {
        throw "No se encontro el script: $path"
    }

    Write-Output "Ejecutando $name ..."
    if ($name -eq "schema_base.sql") {
        Get-Content -Raw $path | & $MysqlExe -u $User --default-character-set=utf8mb4
    } else {
        Get-Content -Raw $path | & $MysqlExe -u $User --default-character-set=utf8mb4 $Database
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Fallo al ejecutar: $name"
    }
}

Write-Output "Reconstruccion completada para [$Database]."
