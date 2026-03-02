param(
    [Parameter(Mandatory = $true)]
    [string]$DbPassword,

    [string]$DbUser = "avnadmin",
    [string]$DbHost = "server-db-sd-server-db-sd.a.aivencloud.com",
    [int]$DbPort = 14732,
    [string]$DbName = "sistema_donaciones"
)

$ErrorActionPreference = "Stop"

$env:SD_DB_URL = "jdbc:mysql://$DbHost`:$DbPort/$DbName?sslMode=REQUIRED&serverTimezone=UTC&useUnicode=true&characterEncoding=utf8&connectionCollation=utf8mb4_unicode_ci"
$env:SD_DB_USER = $DbUser
$env:SD_DB_PASSWORD = $DbPassword

Write-Host "Compilando proyecto..."
mvn -U clean package -DskipTests

Write-Host "Levantando servidor..."
mvn spring-boot:run
