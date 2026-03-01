param(
    [string]$RootPath = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

$ErrorActionPreference = "Stop"

$bakudDir = Join-Path $RootPath "sql\bakud"
$outFile = Join-Path $bakudDir "sistema_donaciones_backup.sql"

$parts = @(
    "sql\schema_base.sql",
    "sql\roles_permisos_base.sql",
    "sql\sp_institucion_base.sql",
    "sql\sp_campania_base.sql",
    "sql\sp_comunidad_base.sql",
    "sql\sp_voluntario_base.sql",
    "sql\sp_donacion_base.sql",
    "sql\sp_entregas_finanzas.sql",
    "sql\seed_datos_humanizados.sql"
)

if (-not (Test-Path $bakudDir)) {
    New-Item -ItemType Directory -Path $bakudDir | Out-Null
}

$legacy = Get-ChildItem -Path $bakudDir -Filter "sistema_donaciones_backup_*.sql" -ErrorAction SilentlyContinue
foreach ($f in $legacy) {
    Remove-Item -Path $f.FullName -Force
}

$header = @(
    "-- Backup funcional consolidado",
    "-- Generado: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "-- Base: sistema_donaciones",
    "-- Nota: schema_base.sql crea y selecciona la base de datos",
    ""
)
Set-Content -Path $outFile -Encoding UTF8 -Value $header

foreach ($part in $parts) {
    $fullPath = Join-Path $RootPath $part
    if (-not (Test-Path $fullPath)) {
        throw "No se encontro el archivo requerido: $part"
    }

    Add-Content -Path $outFile -Encoding UTF8 -Value @(
        "",
        "-- ============================================================",
        "-- SOURCE: $part",
        "-- ============================================================",
        ""
    )

    Get-Content -Path $fullPath | Add-Content -Path $outFile -Encoding UTF8
}

Write-Output "Backup actualizado: $outFile"
