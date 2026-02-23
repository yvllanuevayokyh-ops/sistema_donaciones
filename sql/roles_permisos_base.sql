CREATE TABLE IF NOT EXISTS permiso (
    id_permiso INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(80) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(250) NULL,
    activo TINYINT NOT NULL DEFAULT 1,
    UNIQUE KEY uk_permiso_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS rol_permiso (
    id_rol INT NOT NULL,
    id_permiso INT NOT NULL,
    permitido TINYINT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_rol, id_permiso),
    CONSTRAINT fk_rol_permiso_rol
        FOREIGN KEY (id_rol) REFERENCES rol_usuario(id_rol)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rol_permiso_permiso
        FOREIGN KEY (id_permiso) REFERENCES permiso(id_permiso)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO permiso (codigo, nombre, descripcion, activo) VALUES
('DASHBOARD_VER', 'Ver Dashboard', 'Acceso al panel principal', 1),
('DONACIONES_GESTIONAR', 'Gestionar Donaciones', 'Crear, editar y cambiar estado de donaciones', 1),
('COMUNIDADES_GESTIONAR', 'Gestionar Comunidades', 'Crear, editar y cambiar estado de comunidades', 1),
('INSTITUCIONES_GESTIONAR', 'Gestionar Instituciones', 'Crear, editar y cambiar estado de instituciones', 1),
('VOLUNTARIOS_GESTIONAR', 'Gestionar Voluntarios', 'Crear, editar y cambiar estado de voluntarios', 1),
('CAMPANIAS_GESTIONAR', 'Gestionar Campanias', 'Crear, editar y cambiar estado de campanias', 1),
('ROLES_PERMISOS_GESTIONAR', 'Gestionar Roles y Permisos', 'Administrar roles y su matriz de permisos', 1),
('REPORTES_VER', 'Ver Reportes', 'Acceso a reportes del sistema', 1)
ON DUPLICATE KEY UPDATE
nombre = VALUES(nombre),
descripcion = VALUES(descripcion),
activo = 1;

INSERT INTO rol_permiso (id_rol, id_permiso, permitido)
SELECT r.id_rol, p.id_permiso, CASE WHEN r.id_rol = 1 THEN 1 ELSE 0 END
FROM rol_usuario r
CROSS JOIN permiso p
LEFT JOIN rol_permiso rp
    ON rp.id_rol = r.id_rol
   AND rp.id_permiso = p.id_permiso
WHERE rp.id_rol IS NULL;

UPDATE rol_permiso
SET permitido = 1
WHERE id_rol = 1;
