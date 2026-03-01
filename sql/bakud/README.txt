Backup SQL consolidado para importar en la BD sistema_donaciones.

Archivo principal:
- sistema_donaciones_backup.sql

Generar/actualizar (siempre mantiene solo 1 backup actual):
powershell -ExecutionPolicy Bypass -File sql/bakud/generar_backup.ps1

Ejecucion en mysql:
mysql -u root < sql/bakud/sistema_donaciones_backup.sql

Nota:
Si root no tiene clave, presiona Enter cuando la pida.

Importante:
El backup consolidado ya incluye creacion de base y tablas base.
