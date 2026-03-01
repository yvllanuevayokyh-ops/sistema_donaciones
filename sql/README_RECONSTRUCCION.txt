Reconstruccion completa de BD: sistema_donaciones

Prerequisitos:
- XAMPP MySQL instalado (mysql.exe)
- Usuario root (sin contrasena, o ajusta el script)

Comando recomendado (PowerShell):
powershell -ExecutionPolicy Bypass -File sql/reconstruir_db.ps1 -Reset

Comando sin reset (idempotente):
powershell -ExecutionPolicy Bypass -File sql/reconstruir_db.ps1

Que ejecuta en orden:
1) schema_base.sql
2) roles_permisos_base.sql
3) sp_institucion_base.sql
4) sp_campania_base.sql
5) sp_comunidad_base.sql
6) sp_voluntario_base.sql
7) sp_donacion_base.sql
8) sp_entregas_finanzas.sql
9) seed_datos_humanizados.sql

Credenciales iniciales:
- admin@donaciones.org / 123456
- institucion@donaciones.org / 123456
- persona@email.com / 123456
- comunidad@donaciones.org / 123456
