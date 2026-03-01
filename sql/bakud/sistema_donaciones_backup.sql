-- Backup funcional consolidado
-- Generado: 2026-03-01 09:55:05
-- Base: sistema_donaciones
-- Nota: schema_base.sql crea y selecciona la base de datos


-- ============================================================
-- SOURCE: sql\schema_base.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS sistema_donaciones
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sistema_donaciones;

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS pais (
    id_pais INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    UNIQUE KEY uk_pais_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS rol_usuario (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    UNIQUE KEY uk_rol_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS usuario_sistema (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    usuario VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    UNIQUE KEY uk_usuario_sistema_usuario (usuario),
    KEY idx_usuario_sistema_rol (id_rol),
    CONSTRAINT fk_usuario_sistema_rol
        FOREIGN KEY (id_rol) REFERENCES rol_usuario(id_rol)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS donante (
    id_donante INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    email VARCHAR(100) NULL,
    telefono VARCHAR(20) NULL,
    direccion VARCHAR(200) NULL,
    tipo_donante VARCHAR(30) NOT NULL,
    id_pais INT NOT NULL,
    fecha_registro DATE NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    KEY idx_donante_nombre (nombre),
    KEY idx_donante_email (email),
    KEY idx_donante_tipo (tipo_donante),
    KEY idx_donante_activo (activo),
    KEY idx_donante_pais (id_pais),
    CONSTRAINT fk_donante_pais
        FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS campania (
    id_campania INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'Activa',
    monto_objetivo DECIMAL(12,2) NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    KEY idx_campania_nombre (nombre),
    KEY idx_campania_estado (estado),
    KEY idx_campania_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS comunidad_vulnerable (
    id_comunidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    ubicacion VARCHAR(200) NULL,
    descripcion TEXT NULL,
    cantidad_beneficiarios INT NULL DEFAULT 0,
    id_pais INT NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    KEY idx_comunidad_nombre (nombre),
    KEY idx_comunidad_activo (activo),
    KEY idx_comunidad_pais (id_pais),
    CONSTRAINT fk_comunidad_pais
        FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS voluntario (
    id_voluntario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(20) NULL,
    email VARCHAR(100) NULL,
    fecha_ingreso DATE NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    KEY idx_voluntario_nombre (nombre),
    KEY idx_voluntario_estado (estado),
    KEY idx_voluntario_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS donacion (
    id_donacion INT AUTO_INCREMENT PRIMARY KEY,
    id_donante INT NOT NULL,
    id_campania INT NULL,
    tipo_donacion VARCHAR(30) NOT NULL,
    estado_donacion VARCHAR(30) NOT NULL,
    fecha_donacion DATE NOT NULL,
    monto DECIMAL(10,2) NULL,
    descripcion TEXT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    KEY idx_donacion_donante (id_donante),
    KEY idx_donacion_campania (id_campania),
    KEY idx_donacion_estado (estado_donacion),
    KEY idx_donacion_activo (activo),
    KEY idx_donacion_fecha (fecha_donacion),
    CONSTRAINT fk_donacion_donante
        FOREIGN KEY (id_donante) REFERENCES donante(id_donante)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_donacion_campania
        FOREIGN KEY (id_campania) REFERENCES campania(id_campania)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS estado_entrega (
    id_estado_entrega INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL,
    UNIQUE KEY uk_estado_entrega_descripcion (descripcion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS entrega_donacion (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_donacion INT NOT NULL,
    id_comunidad INT NOT NULL,
    fecha_programada DATETIME NULL,
    fecha_entrega DATETIME NULL,
    id_estado_entrega INT NOT NULL DEFAULT 1,
    observaciones TEXT NULL,
    KEY idx_entrega_donacion (id_donacion),
    KEY idx_entrega_comunidad (id_comunidad),
    KEY idx_entrega_estado (id_estado_entrega),
    KEY idx_entrega_programada (fecha_programada),
    CONSTRAINT fk_entrega_donacion_donacion
        FOREIGN KEY (id_donacion) REFERENCES donacion(id_donacion)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_entrega_donacion_comunidad
        FOREIGN KEY (id_comunidad) REFERENCES comunidad_vulnerable(id_comunidad)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_entrega_donacion_estado
        FOREIGN KEY (id_estado_entrega) REFERENCES estado_entrega(id_estado_entrega)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS asignacion_voluntario_entrega (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_voluntario INT NOT NULL,
    id_entrega INT NOT NULL,
    fecha_asignacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_asignacion_voluntario_entrega (id_voluntario, id_entrega),
    KEY idx_asignacion_entrega (id_entrega),
    CONSTRAINT fk_asignacion_voluntario
        FOREIGN KEY (id_voluntario) REFERENCES voluntario(id_voluntario)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_asignacion_entrega
        FOREIGN KEY (id_entrega) REFERENCES entrega_donacion(id_entrega)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO rol_usuario (id_rol, nombre) VALUES
    (1, 'Administrador'),
    (2, 'Institucion Donante'),
    (3, 'Persona Natural'),
    (4, 'Comunidad')
ON DUPLICATE KEY UPDATE
    nombre = VALUES(nombre);

INSERT INTO pais (nombre) VALUES
    ('Peru'),
    ('Colombia'),
    ('Ecuador'),
    ('Bolivia'),
    ('Chile')
ON DUPLICATE KEY UPDATE
    nombre = VALUES(nombre);

INSERT INTO estado_entrega (id_estado_entrega, descripcion) VALUES
    (1, 'Programado'),
    (2, 'En transito'),
    (3, 'Entregado'),
    (4, 'Cancelado')
ON DUPLICATE KEY UPDATE
    descripcion = VALUES(descripcion);

INSERT INTO usuario_sistema (nombre, usuario, password, id_rol, estado)
SELECT 'Administrador Sistema', 'admin@donaciones.local', 'admin123', 1, 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM usuario_sistema WHERE usuario = 'admin@donaciones.local'
);

INSERT INTO usuario_sistema (nombre, usuario, password, id_rol, estado)
SELECT 'Fundacion Puentes del Norte', 'contacto@puentesnorte.org', 'donante123', 2, 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM usuario_sistema WHERE usuario = 'contacto@puentesnorte.org'
);

INSERT INTO usuario_sistema (nombre, usuario, password, id_rol, estado)
SELECT 'Lucia Herrera', 'lucia.herrera@email.com', 'persona123', 3, 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM usuario_sistema WHERE usuario = 'lucia.herrera@email.com'
);

INSERT INTO usuario_sistema (nombre, usuario, password, id_rol, estado)
SELECT 'Comunidad Los Andes', 'comunidad@losandes.org', 'comunidad123', 4, 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM usuario_sistema WHERE usuario = 'comunidad@losandes.org'
);

-- ============================================================
-- SOURCE: sql\roles_permisos_base.sql
-- ============================================================

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

-- ============================================================
-- SOURCE: sql\sp_institucion_base.sql
-- ============================================================

ALTER TABLE donante
    ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;

UPDATE donante SET activo = 1 WHERE activo IS NULL;

DROP PROCEDURE IF EXISTS sp_institucion_listar;
DROP PROCEDURE IF EXISTS sp_institucion_contar;
DROP PROCEDURE IF EXISTS sp_institucion_detalle;
DROP PROCEDURE IF EXISTS sp_institucion_crear;
DROP PROCEDURE IF EXISTS sp_institucion_editar;
DROP PROCEDURE IF EXISTS sp_institucion_inactivar;
DROP PROCEDURE IF EXISTS sp_institucion_restaurar;

DELIMITER $$

CREATE PROCEDURE sp_institucion_listar(
    IN p_q VARCHAR(255),
    IN p_activo INT,
    IN p_offset INT,
    IN p_limit INT
)
BEGIN
    SELECT
        d.id_donante,
        d.nombre,
        d.email,
        d.telefono,
        d.direccion,
        d.tipo_donante,
        d.id_pais,
        d.fecha_registro,
        d.activo
    FROM donante d
    INNER JOIN pais p ON p.id_pais = d.id_pais
    WHERE
        UPPER(d.tipo_donante) NOT LIKE 'PERSONA%'
        AND (
            p_q IS NULL OR p_q = '' OR
            UPPER(d.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(p.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(d.direccion, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND (p_activo IS NULL OR d.activo = p_activo)
    ORDER BY d.nombre ASC
    LIMIT p_offset, p_limit;
END$$

CREATE PROCEDURE sp_institucion_contar(
    IN p_q VARCHAR(255),
    IN p_activo INT
)
BEGIN
    SELECT COUNT(*) AS total
    FROM donante d
    INNER JOIN pais p ON p.id_pais = d.id_pais
    WHERE
        UPPER(d.tipo_donante) NOT LIKE 'PERSONA%'
        AND (
            p_q IS NULL OR p_q = '' OR
            UPPER(d.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(p.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(d.direccion, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND (p_activo IS NULL OR d.activo = p_activo);
END$$

CREATE PROCEDURE sp_institucion_detalle(
    IN p_id_donante INT
)
BEGIN
    SELECT
        d.id_donante,
        d.nombre,
        d.email,
        d.telefono,
        d.direccion,
        d.tipo_donante,
        d.id_pais,
        d.fecha_registro,
        d.activo
    FROM donante d
    WHERE d.id_donante = p_id_donante
      AND UPPER(d.tipo_donante) NOT LIKE 'PERSONA%'
    LIMIT 1;
END$$

CREATE PROCEDURE sp_institucion_crear(
    IN p_nombre VARCHAR(150),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_direccion VARCHAR(200),
    IN p_tipo_donante VARCHAR(30),
    IN p_id_pais INT,
    IN p_fecha_registro DATE
)
BEGIN
    INSERT INTO donante (
        nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo
    ) VALUES (
        p_nombre, p_email, p_telefono, p_direccion, p_tipo_donante, p_id_pais, p_fecha_registro, 1
    );

    SELECT LAST_INSERT_ID() AS new_id;
END$$

CREATE PROCEDURE sp_institucion_editar(
    IN p_id_donante INT,
    IN p_nombre VARCHAR(150),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_direccion VARCHAR(200),
    IN p_tipo_donante VARCHAR(30),
    IN p_id_pais INT
)
BEGIN
    UPDATE donante
    SET
        nombre = p_nombre,
        email = p_email,
        telefono = p_telefono,
        direccion = p_direccion,
        tipo_donante = p_tipo_donante,
        id_pais = p_id_pais
    WHERE id_donante = p_id_donante
      AND UPPER(tipo_donante) NOT LIKE 'PERSONA%';
END$$

CREATE PROCEDURE sp_institucion_inactivar(
    IN p_id_donante INT
)
BEGIN
    UPDATE donante
    SET activo = 0
    WHERE id_donante = p_id_donante
      AND UPPER(tipo_donante) NOT LIKE 'PERSONA%';
END$$

CREATE PROCEDURE sp_institucion_restaurar(
    IN p_id_donante INT
)
BEGIN
    UPDATE donante
    SET activo = 1
    WHERE id_donante = p_id_donante
      AND UPPER(tipo_donante) NOT LIKE 'PERSONA%';
END$$

DELIMITER ;

-- ============================================================
-- SOURCE: sql\sp_campania_base.sql
-- ============================================================

ALTER TABLE campania
    ADD COLUMN IF NOT EXISTS monto_objetivo DECIMAL(12,2) NULL;

ALTER TABLE campania
    ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;

UPDATE campania SET activo = 1 WHERE activo IS NULL;
UPDATE campania SET monto_objetivo = 5000.00 WHERE monto_objetivo IS NULL OR monto_objetivo = 0;

DROP PROCEDURE IF EXISTS sp_campania_listar;
DROP PROCEDURE IF EXISTS sp_campania_contar;
DROP PROCEDURE IF EXISTS sp_campania_detalle;
DROP PROCEDURE IF EXISTS sp_campania_crear;
DROP PROCEDURE IF EXISTS sp_campania_editar;
DROP PROCEDURE IF EXISTS sp_campania_eliminar;
DROP PROCEDURE IF EXISTS sp_campania_restaurar;

DELIMITER $$

-- Solo devuelve las 8 columnas que mapean exactamente a Campania.java
CREATE PROCEDURE sp_campania_listar(
    IN p_q VARCHAR(255),
    IN p_estado VARCHAR(30),
    IN p_activo INT,
    IN p_offset INT,
    IN p_limit INT
)
BEGIN
    SELECT
        c.id_campania,
        c.nombre,
        COALESCE(c.descripcion, '') AS descripcion,
        c.fecha_inicio,
        c.fecha_fin,
        COALESCE(c.estado, 'Activa') AS estado,
        COALESCE(c.monto_objetivo, 0) AS monto_objetivo,
        c.activo
    FROM campania c
    WHERE
        (
            p_q IS NULL OR p_q = '' OR
            UPPER(c.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(c.descripcion, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND (
            p_estado IS NULL OR p_estado = '' OR UPPER(p_estado) = 'TODAS' OR
            UPPER(COALESCE(c.estado, '')) = UPPER(p_estado)
        )
        AND (p_activo IS NULL OR c.activo = p_activo)
    ORDER BY c.id_campania DESC
    LIMIT p_offset, p_limit;
END$$

CREATE PROCEDURE sp_campania_contar(
    IN p_q VARCHAR(255),
    IN p_estado VARCHAR(30),
    IN p_activo INT
)
BEGIN
    SELECT COUNT(*) AS total
    FROM campania c
    WHERE
        (
            p_q IS NULL OR p_q = '' OR
            UPPER(c.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(c.descripcion, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND (
            p_estado IS NULL OR p_estado = '' OR UPPER(p_estado) = 'TODAS' OR
            UPPER(COALESCE(c.estado, '')) = UPPER(p_estado)
        )
        AND (p_activo IS NULL OR c.activo = p_activo);
END$$

-- Solo devuelve las 8 columnas que mapean exactamente a Campania.java
CREATE PROCEDURE sp_campania_detalle(
    IN p_id_campania INT
)
BEGIN
    SELECT
        c.id_campania,
        c.nombre,
        COALESCE(c.descripcion, '') AS descripcion,
        c.fecha_inicio,
        c.fecha_fin,
        COALESCE(c.estado, 'Activa') AS estado,
        COALESCE(c.monto_objetivo, 0) AS monto_objetivo,
        c.activo
    FROM campania c
    WHERE c.id_campania = p_id_campania
    LIMIT 1;
END$$

CREATE PROCEDURE sp_campania_crear(
    IN p_nombre VARCHAR(150),
    IN p_descripcion TEXT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_estado VARCHAR(30),
    IN p_monto_objetivo DECIMAL(12,2)
)
BEGIN
    INSERT INTO campania (nombre, descripcion, fecha_inicio, fecha_fin, estado, monto_objetivo, activo)
    VALUES (p_nombre, p_descripcion, p_fecha_inicio, p_fecha_fin, p_estado, p_monto_objetivo, 1);

    SELECT LAST_INSERT_ID() AS new_id;
END$$

CREATE PROCEDURE sp_campania_editar(
    IN p_id_campania INT,
    IN p_nombre VARCHAR(150),
    IN p_descripcion TEXT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_estado VARCHAR(30),
    IN p_monto_objetivo DECIMAL(12,2)
)
BEGIN
    UPDATE campania
    SET
        nombre = p_nombre,
        descripcion = p_descripcion,
        fecha_inicio = p_fecha_inicio,
        fecha_fin = p_fecha_fin,
        estado = p_estado,
        monto_objetivo = p_monto_objetivo
    WHERE id_campania = p_id_campania;
END$$

CREATE PROCEDURE sp_campania_eliminar(
    IN p_id_campania INT
)
BEGIN
    UPDATE campania
    SET activo = 0
    WHERE id_campania = p_id_campania;
END$$

CREATE PROCEDURE sp_campania_restaurar(
    IN p_id_campania INT
)
BEGIN
    UPDATE campania
    SET activo = 1
    WHERE id_campania = p_id_campania;
END$$

DELIMITER ;

-- ============================================================
-- SOURCE: sql\sp_comunidad_base.sql
-- ============================================================

ALTER TABLE comunidad_vulnerable
    ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;

UPDATE comunidad_vulnerable SET activo = 1 WHERE activo IS NULL;

DROP PROCEDURE IF EXISTS sp_comunidad_listar;
DROP PROCEDURE IF EXISTS sp_comunidad_contar;
DROP PROCEDURE IF EXISTS sp_comunidad_detalle;
DROP PROCEDURE IF EXISTS sp_comunidad_crear;
DROP PROCEDURE IF EXISTS sp_comunidad_editar;
DROP PROCEDURE IF EXISTS sp_comunidad_inactivar;
DROP PROCEDURE IF EXISTS sp_comunidad_restaurar;

DELIMITER $$

CREATE PROCEDURE sp_comunidad_listar(
    IN p_q VARCHAR(255),
    IN p_activo INT,
    IN p_offset INT,
    IN p_limit INT
)
BEGIN
    SELECT
        c.id_comunidad,
        c.nombre,
        c.ubicacion,
        c.descripcion,
        c.cantidad_beneficiarios,
        c.id_pais,
        c.activo
    FROM comunidad_vulnerable c
    WHERE
        (
            p_q IS NULL OR p_q = '' OR
            UPPER(c.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(c.ubicacion, '')) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(c.descripcion, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND (p_activo IS NULL OR c.activo = p_activo)
    ORDER BY c.nombre ASC
    LIMIT p_offset, p_limit;
END$$

CREATE PROCEDURE sp_comunidad_contar(
    IN p_q VARCHAR(255),
    IN p_activo INT
)
BEGIN
    SELECT COUNT(*) AS total
    FROM comunidad_vulnerable c
    WHERE
        (
            p_q IS NULL OR p_q = '' OR
            UPPER(c.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(c.ubicacion, '')) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(c.descripcion, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND (p_activo IS NULL OR c.activo = p_activo);
END$$

CREATE PROCEDURE sp_comunidad_detalle(
    IN p_id_comunidad INT
)
BEGIN
    SELECT
        c.id_comunidad,
        c.nombre,
        c.ubicacion,
        c.descripcion,
        c.cantidad_beneficiarios,
        c.id_pais,
        c.activo
    FROM comunidad_vulnerable c
    WHERE c.id_comunidad = p_id_comunidad
    LIMIT 1;
END$$

CREATE PROCEDURE sp_comunidad_crear(
    IN p_nombre VARCHAR(150),
    IN p_ubicacion VARCHAR(200),
    IN p_descripcion TEXT,
    IN p_cantidad_beneficiarios INT,
    IN p_id_pais INT
)
BEGIN
    INSERT INTO comunidad_vulnerable (
        nombre, ubicacion, descripcion, cantidad_beneficiarios, id_pais, activo
    ) VALUES (
        p_nombre, p_ubicacion, p_descripcion, p_cantidad_beneficiarios, p_id_pais, 1
    );

    SELECT LAST_INSERT_ID() AS new_id;
END$$

CREATE PROCEDURE sp_comunidad_editar(
    IN p_id_comunidad INT,
    IN p_nombre VARCHAR(150),
    IN p_ubicacion VARCHAR(200),
    IN p_descripcion TEXT,
    IN p_cantidad_beneficiarios INT,
    IN p_id_pais INT
)
BEGIN
    UPDATE comunidad_vulnerable
    SET
        nombre = p_nombre,
        ubicacion = p_ubicacion,
        descripcion = p_descripcion,
        cantidad_beneficiarios = p_cantidad_beneficiarios,
        id_pais = p_id_pais
    WHERE id_comunidad = p_id_comunidad;
END$$

CREATE PROCEDURE sp_comunidad_inactivar(
    IN p_id_comunidad INT
)
BEGIN
    UPDATE comunidad_vulnerable
    SET activo = 0
    WHERE id_comunidad = p_id_comunidad;
END$$

CREATE PROCEDURE sp_comunidad_restaurar(
    IN p_id_comunidad INT
)
BEGIN
    UPDATE comunidad_vulnerable
    SET activo = 1
    WHERE id_comunidad = p_id_comunidad;
END$$

DELIMITER ;

-- ============================================================
-- SOURCE: sql\sp_voluntario_base.sql
-- ============================================================

ALTER TABLE voluntario
    ADD COLUMN IF NOT EXISTS estado TINYINT(1) NOT NULL DEFAULT 1;

UPDATE voluntario SET estado = 1 WHERE estado IS NULL;

DROP PROCEDURE IF EXISTS sp_voluntario_listar;
DROP PROCEDURE IF EXISTS sp_voluntario_contar;
DROP PROCEDURE IF EXISTS sp_voluntario_detalle;
DROP PROCEDURE IF EXISTS sp_voluntario_crear;
DROP PROCEDURE IF EXISTS sp_voluntario_editar;
DROP PROCEDURE IF EXISTS sp_voluntario_eliminar;
DROP PROCEDURE IF EXISTS sp_voluntario_restaurar;

DELIMITER $$

CREATE PROCEDURE sp_voluntario_listar(
    IN p_q VARCHAR(255),
    IN p_estado INT,
    IN p_offset INT,
    IN p_limit INT
)
BEGIN
    SELECT
        v.id_voluntario,
        v.nombre,
        v.email,
        v.telefono,
        v.fecha_ingreso,
        v.estado
    FROM voluntario v
    WHERE
        (
            p_q IS NULL OR p_q = '' OR
            UPPER(v.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(v.email, '')) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(v.telefono, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND (p_estado IS NULL OR v.estado = p_estado)
    ORDER BY v.nombre ASC
    LIMIT p_offset, p_limit;
END$$

CREATE PROCEDURE sp_voluntario_contar(
    IN p_q VARCHAR(255),
    IN p_estado INT
)
BEGIN
    SELECT COUNT(*) AS total
    FROM voluntario v
    WHERE
        (
            p_q IS NULL OR p_q = '' OR
            UPPER(v.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(v.email, '')) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(v.telefono, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND (p_estado IS NULL OR v.estado = p_estado);
END$$

CREATE PROCEDURE sp_voluntario_detalle(
    IN p_id_voluntario INT
)
BEGIN
    SELECT
        v.id_voluntario,
        v.nombre,
        v.email,
        v.telefono,
        v.fecha_ingreso,
        v.estado
    FROM voluntario v
    WHERE v.id_voluntario = p_id_voluntario
    LIMIT 1;
END$$

CREATE PROCEDURE sp_voluntario_crear(
    IN p_nombre VARCHAR(150),
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_fecha_ingreso DATE
)
BEGIN
    INSERT INTO voluntario (nombre, telefono, email, fecha_ingreso, estado)
    VALUES (p_nombre, p_telefono, p_email, p_fecha_ingreso, 1);

    SELECT LAST_INSERT_ID() AS new_id;
END$$

CREATE PROCEDURE sp_voluntario_editar(
    IN p_id_voluntario INT,
    IN p_nombre VARCHAR(150),
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_fecha_ingreso DATE
)
BEGIN
    UPDATE voluntario
    SET
        nombre = p_nombre,
        telefono = p_telefono,
        email = p_email,
        fecha_ingreso = p_fecha_ingreso
    WHERE id_voluntario = p_id_voluntario;
END$$

CREATE PROCEDURE sp_voluntario_eliminar(
    IN p_id_voluntario INT
)
BEGIN
    UPDATE voluntario
    SET estado = 0
    WHERE id_voluntario = p_id_voluntario;
END$$

CREATE PROCEDURE sp_voluntario_restaurar(
    IN p_id_voluntario INT
)
BEGIN
    UPDATE voluntario
    SET estado = 1
    WHERE id_voluntario = p_id_voluntario;
END$$

DELIMITER ;

-- ============================================================
-- SOURCE: sql\sp_donacion_base.sql
-- ============================================================

ALTER TABLE donacion
    ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;

UPDATE donacion SET activo = 1 WHERE activo IS NULL;

DROP PROCEDURE IF EXISTS sp_donacion_listar;
DROP PROCEDURE IF EXISTS sp_donacion_contar;
DROP PROCEDURE IF EXISTS sp_donacion_detalle;
DROP PROCEDURE IF EXISTS sp_donacion_crear;
DROP PROCEDURE IF EXISTS sp_donacion_editar;
DROP PROCEDURE IF EXISTS sp_donacion_inactivar;
DROP PROCEDURE IF EXISTS sp_donacion_restaurar;

DELIMITER $$

CREATE PROCEDURE sp_donacion_listar(
    IN p_q VARCHAR(255),
    IN p_estado VARCHAR(30),
    IN p_activo INT,
    IN p_offset INT,
    IN p_limit INT
)
BEGIN
    SELECT
        d.id_donacion,
        d.id_donante,
        d.id_campania,
        d.tipo_donacion,
        d.estado_donacion,
        d.fecha_donacion,
        d.monto,
        d.descripcion,
        d.activo,
        COALESCE(CONCAT('S/ ', FORMAT(d.monto, 2)), d.tipo_donacion) AS detalle,
        dn.nombre AS donante
    FROM donacion d
    INNER JOIN donante dn ON dn.id_donante = d.id_donante
    WHERE
        (
            p_q IS NULL OR p_q = '' OR
            CAST(d.id_donacion AS CHAR) LIKE CONCAT('%', REPLACE(REPLACE(UPPER(p_q), 'DON-', ''), ' ', ''), '%') OR
            CONCAT('DON-', LPAD(d.id_donacion, 3, '0')) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(d.descripcion) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(dn.nombre, '')) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(dn.email, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND
        (
            p_estado IS NULL OR p_estado = '' OR UPPER(p_estado) = 'TODAS' OR
            UPPER(d.estado_donacion) = UPPER(p_estado)
        )
        AND
        (
            p_activo IS NULL OR d.activo = p_activo
        )
    ORDER BY d.fecha_donacion DESC, d.id_donacion DESC
    LIMIT p_offset, p_limit;
END$$

CREATE PROCEDURE sp_donacion_contar(
    IN p_q VARCHAR(255),
    IN p_estado VARCHAR(30),
    IN p_activo INT
)
BEGIN
    SELECT COUNT(*) AS total
    FROM donacion d
    INNER JOIN donante dn ON dn.id_donante = d.id_donante
    WHERE
        (
            p_q IS NULL OR p_q = '' OR
            CAST(d.id_donacion AS CHAR) LIKE CONCAT('%', REPLACE(REPLACE(UPPER(p_q), 'DON-', ''), ' ', ''), '%') OR
            CONCAT('DON-', LPAD(d.id_donacion, 3, '0')) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(d.descripcion) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(dn.nombre, '')) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(dn.email, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND
        (
            p_estado IS NULL OR p_estado = '' OR UPPER(p_estado) = 'TODAS' OR
            UPPER(d.estado_donacion) = UPPER(p_estado)
        )
        AND
        (
            p_activo IS NULL OR d.activo = p_activo
        );
END$$

CREATE PROCEDURE sp_donacion_detalle(
    IN p_id_donacion INT
)
BEGIN
    SELECT
        d.id_donacion,
        d.id_donante,
        d.id_campania,
        d.tipo_donacion,
        d.estado_donacion,
        d.fecha_donacion,
        d.monto,
        d.descripcion,
        d.activo,
        DATE_FORMAT(d.fecha_donacion, '%Y-%m-%d') AS fecha_donacion_fmt,
        COALESCE(CONCAT('S/ ', FORMAT(d.monto, 2)), 'N/A') AS monto_fmt,
        dn.nombre AS donante,
        COALESCE(dn.email, 'N/A') AS email,
        COALESCE(c.nombre, 'Sin campania') AS campania
    FROM donacion d
    INNER JOIN donante dn ON dn.id_donante = d.id_donante
    LEFT JOIN campania c ON c.id_campania = d.id_campania
    WHERE d.id_donacion = p_id_donacion
    LIMIT 1;
END$$

CREATE PROCEDURE sp_donacion_crear(
    IN p_id_donante INT,
    IN p_id_campania INT,
    IN p_tipo_donacion VARCHAR(30),
    IN p_estado_donacion VARCHAR(30),
    IN p_fecha_donacion DATE,
    IN p_monto DECIMAL(10,2),
    IN p_descripcion TEXT
)
BEGIN
    INSERT INTO donacion (
        id_donante, id_campania, tipo_donacion, estado_donacion,
        fecha_donacion, monto, descripcion, activo
    ) VALUES (
        p_id_donante, p_id_campania, p_tipo_donacion, p_estado_donacion,
        p_fecha_donacion, p_monto, p_descripcion, 1
    );

    SELECT LAST_INSERT_ID() AS new_id;
END$$

CREATE PROCEDURE sp_donacion_editar(
    IN p_id_donacion INT,
    IN p_id_donante INT,
    IN p_id_campania INT,
    IN p_tipo_donacion VARCHAR(30),
    IN p_estado_donacion VARCHAR(30),
    IN p_fecha_donacion DATE,
    IN p_monto DECIMAL(10,2),
    IN p_descripcion TEXT
)
BEGIN
    UPDATE donacion
    SET
        id_donante = p_id_donante,
        id_campania = p_id_campania,
        tipo_donacion = p_tipo_donacion,
        estado_donacion = p_estado_donacion,
        fecha_donacion = p_fecha_donacion,
        monto = p_monto,
        descripcion = p_descripcion
    WHERE id_donacion = p_id_donacion;
END$$

CREATE PROCEDURE sp_donacion_inactivar(
    IN p_id_donacion INT
)
BEGIN
    UPDATE donacion
    SET activo = 0
    WHERE id_donacion = p_id_donacion;
END$$

CREATE PROCEDURE sp_donacion_restaurar(
    IN p_id_donacion INT
)
BEGIN
    UPDATE donacion
    SET activo = 1
    WHERE id_donacion = p_id_donacion;
END$$

DELIMITER ;

-- ============================================================
-- SOURCE: sql\sp_entregas_finanzas.sql
-- ============================================================

-- ============================================================
-- TABLAS
-- ============================================================
CREATE TABLE IF NOT EXISTS estado_entrega (
    id_estado_entrega INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);

INSERT IGNORE INTO estado_entrega (id_estado_entrega, descripcion) VALUES
(1, 'Programado'),
(2, 'En transito'),
(3, 'Entregado'),
(4, 'Cancelado');

CREATE TABLE IF NOT EXISTS entrega_donacion (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_donacion INT NOT NULL,
    id_comunidad INT NOT NULL,
    fecha_programada DATETIME,
    fecha_entrega DATETIME,
    id_estado_entrega INT NOT NULL DEFAULT 1,
    observaciones TEXT,
    FOREIGN KEY (id_donacion) REFERENCES donacion(id_donacion),
    FOREIGN KEY (id_comunidad) REFERENCES comunidad_vulnerable(id_comunidad),
    FOREIGN KEY (id_estado_entrega) REFERENCES estado_entrega(id_estado_entrega)
);

ALTER TABLE entrega_donacion
    MODIFY COLUMN fecha_programada DATETIME NULL;

ALTER TABLE entrega_donacion
    MODIFY COLUMN fecha_entrega DATETIME NULL;

-- ============================================================
-- STORED PROCEDURES - ENTREGAS
-- ============================================================
DROP PROCEDURE IF EXISTS sp_entrega_listar;
DROP PROCEDURE IF EXISTS sp_entrega_contar;
DROP PROCEDURE IF EXISTS sp_entrega_detalle;
DROP PROCEDURE IF EXISTS sp_entrega_crear;
DROP PROCEDURE IF EXISTS sp_entrega_editar;
DROP PROCEDURE IF EXISTS sp_entrega_cambiar_estado;

DELIMITER $$

CREATE PROCEDURE sp_entrega_listar(
    IN p_q VARCHAR(255),
    IN p_estado VARCHAR(50),
    IN p_offset INT,
    IN p_limit INT
)
BEGIN
    SELECT
        e.id_entrega,
        e.id_donacion,
        e.id_comunidad,
        e.fecha_programada,
        e.fecha_entrega,
        e.id_estado_entrega,
        COALESCE(e.observaciones, '') AS observaciones
    FROM entrega_donacion e
    INNER JOIN estado_entrega ee ON ee.id_estado_entrega = e.id_estado_entrega
    INNER JOIN donacion d ON d.id_donacion = e.id_donacion
    INNER JOIN comunidad_vulnerable c ON c.id_comunidad = e.id_comunidad
    WHERE
        (p_q IS NULL OR p_q = '' OR
         UPPER(c.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
         UPPER(COALESCE(d.descripcion, '')) LIKE CONCAT('%', UPPER(p_q), '%'))
        AND
        (p_estado IS NULL OR p_estado = '' OR UPPER(p_estado) = 'TODOS' OR
         UPPER(ee.descripcion) = UPPER(p_estado))
    ORDER BY e.id_entrega DESC
    LIMIT p_offset, p_limit;
END$$

CREATE PROCEDURE sp_entrega_contar(
    IN p_q VARCHAR(255),
    IN p_estado VARCHAR(50)
)
BEGIN
    SELECT COUNT(*) AS total
    FROM entrega_donacion e
    INNER JOIN estado_entrega ee ON ee.id_estado_entrega = e.id_estado_entrega
    INNER JOIN donacion d ON d.id_donacion = e.id_donacion
    INNER JOIN comunidad_vulnerable c ON c.id_comunidad = e.id_comunidad
    WHERE
        (p_q IS NULL OR p_q = '' OR
         UPPER(c.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
         UPPER(COALESCE(d.descripcion, '')) LIKE CONCAT('%', UPPER(p_q), '%'))
        AND
        (p_estado IS NULL OR p_estado = '' OR UPPER(p_estado) = 'TODOS' OR
         UPPER(ee.descripcion) = UPPER(p_estado));
END$$

CREATE PROCEDURE sp_entrega_detalle(
    IN p_id_entrega INT
)
BEGIN
    SELECT
        e.id_entrega,
        e.id_donacion,
        e.id_comunidad,
        e.fecha_programada,
        e.fecha_entrega,
        e.id_estado_entrega,
        COALESCE(e.observaciones, '') AS observaciones
    FROM entrega_donacion e
    WHERE e.id_entrega = p_id_entrega
    LIMIT 1;
END$$

CREATE PROCEDURE sp_entrega_crear(
    IN p_id_donacion INT,
    IN p_id_comunidad INT,
    IN p_id_estado_entrega INT,
    IN p_fecha_programada DATETIME,
    IN p_fecha_entrega DATETIME,
    IN p_observaciones TEXT
)
BEGIN
    INSERT INTO entrega_donacion (
        id_donacion, id_comunidad, id_estado_entrega,
        fecha_programada, fecha_entrega, observaciones
    ) VALUES (
        p_id_donacion, p_id_comunidad, p_id_estado_entrega,
        p_fecha_programada, p_fecha_entrega, p_observaciones
    );
    SELECT LAST_INSERT_ID() AS new_id;
END$$

CREATE PROCEDURE sp_entrega_editar(
    IN p_id_entrega INT,
    IN p_id_donacion INT,
    IN p_id_comunidad INT,
    IN p_id_estado_entrega INT,
    IN p_fecha_programada DATETIME,
    IN p_fecha_entrega DATETIME,
    IN p_observaciones TEXT
)
BEGIN
    UPDATE entrega_donacion
    SET id_donacion = p_id_donacion,
        id_comunidad = p_id_comunidad,
        id_estado_entrega = p_id_estado_entrega,
        fecha_programada = p_fecha_programada,
        fecha_entrega = p_fecha_entrega,
        observaciones = p_observaciones
    WHERE id_entrega = p_id_entrega;
END$$

CREATE PROCEDURE sp_entrega_cambiar_estado(
    IN p_id_entrega INT,
    IN p_id_estado_entrega INT,
    IN p_fecha_entrega DATETIME,
    IN p_observaciones TEXT
)
BEGIN
    UPDATE entrega_donacion
    SET id_estado_entrega = p_id_estado_entrega,
        fecha_entrega = p_fecha_entrega,
        observaciones = p_observaciones
    WHERE id_entrega = p_id_entrega;
END$$

-- ============================================================
-- STORED PROCEDURES - FINANZAS
-- ============================================================
DROP PROCEDURE IF EXISTS sp_finanzas_resumen;
DROP PROCEDURE IF EXISTS sp_finanzas_por_campania;
DROP PROCEDURE IF EXISTS sp_finanzas_por_comunidad;

CREATE PROCEDURE sp_finanzas_resumen()
BEGIN
    SELECT
        COALESCE(SUM(CASE WHEN d.activo = 1 THEN COALESCE(d.monto, 0) ELSE 0 END), 0) AS total_recaudado,
        COALESCE((
            SELECT SUM(COALESCE(d2.monto, 0))
            FROM donacion d2
            WHERE d2.activo = 1
              AND d2.id_donacion IN (
                  SELECT e2.id_donacion
                  FROM entrega_donacion e2
                  INNER JOIN estado_entrega ee2 ON ee2.id_estado_entrega = e2.id_estado_entrega
                  WHERE UPPER(ee2.descripcion) = 'ENTREGADO'
              )
        ), 0) AS total_entregado,
        COUNT(DISTINCT CASE WHEN d.activo = 1 THEN d.id_donacion END) AS total_donaciones,
        COUNT(DISTINCT e.id_entrega) AS total_entregas,
        MAX(d.fecha_donacion) AS ultima_donacion,
        MAX(e.fecha_entrega) AS ultima_entrega
    FROM donacion d
    LEFT JOIN entrega_donacion e ON e.id_donacion = d.id_donacion;
END$$

CREATE PROCEDURE sp_finanzas_por_campania()
BEGIN
    SELECT
        c.id_campania,
        c.nombre,
        COALESCE(c.monto_objetivo, 0) AS meta,
        COALESCE(SUM(COALESCE(d.monto, 0)), 0) AS recaudado,
        COALESCE(c.monto_objetivo, 0) - COALESCE(SUM(COALESCE(d.monto, 0)), 0) AS saldo,
        COUNT(DISTINCT d.id_donacion) AS donaciones,
        MAX(d.fecha_donacion) AS ultima_donacion,
        MAX(e.fecha_entrega) AS ultima_entrega
    FROM campania c
    LEFT JOIN donacion d ON d.id_campania = c.id_campania AND d.activo = 1
    LEFT JOIN entrega_donacion e ON e.id_donacion = d.id_donacion
    WHERE c.activo = 1
    GROUP BY c.id_campania, c.nombre, c.monto_objetivo
    ORDER BY recaudado DESC;
END$$

CREATE PROCEDURE sp_finanzas_por_comunidad()
BEGIN
    SELECT
        cv.id_comunidad,
        cv.nombre,
        cv.cantidad_beneficiarios,
        COUNT(DISTINCT e.id_entrega) AS entregas_totales,
        COUNT(DISTINCT CASE WHEN UPPER(ee.descripcion) = 'ENTREGADO' THEN e.id_entrega END) AS entregas_completadas,
        COALESCE(SUM(
            CASE WHEN UPPER(ee.descripcion) = 'ENTREGADO' THEN COALESCE(d.monto, 0) ELSE 0 END
        ), 0) AS monto_recibido,
        MAX(e.fecha_programada) AS ultima_programada,
        MAX(e.fecha_entrega) AS ultima_entrega
    FROM comunidad_vulnerable cv
    LEFT JOIN entrega_donacion e ON e.id_comunidad = cv.id_comunidad
    LEFT JOIN estado_entrega ee ON ee.id_estado_entrega = e.id_estado_entrega
    LEFT JOIN donacion d ON d.id_donacion = e.id_donacion
    WHERE cv.activo = 1
    GROUP BY cv.id_comunidad, cv.nombre, cv.cantidad_beneficiarios
    ORDER BY monto_recibido DESC;
END$$

DELIMITER ;

-- ============================================================
-- SOURCE: sql\seed_datos_humanizados.sql
-- ============================================================

USE sistema_donaciones;

-- ============================================================
-- SEED HUMANIZADO Y CREIBLE
-- Ejecuta este script para agregar datos realistas sin duplicar.
-- ============================================================

INSERT INTO pais (nombre)
SELECT 'Peru' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pais WHERE UPPER(nombre) = 'PERU');

INSERT INTO pais (nombre)
SELECT 'Colombia' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pais WHERE UPPER(nombre) = 'COLOMBIA');

INSERT INTO pais (nombre)
SELECT 'Ecuador' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pais WHERE UPPER(nombre) = 'ECUADOR');

INSERT INTO pais (nombre)
SELECT 'Bolivia' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pais WHERE UPPER(nombre) = 'BOLIVIA');

INSERT INTO pais (nombre)
SELECT 'Chile' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pais WHERE UPPER(nombre) = 'CHILE');

-- ------------------------------
-- Donantes (institucionales y persona natural)
-- ------------------------------
INSERT INTO donante (nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo)
SELECT 'Fundacion Puentes del Norte', 'contacto@puentesnorte.org', '+51 944111221',
       'Av. Alfonso Ugarte 223, Chiclayo', 'Fundacion',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), '2026-01-08', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'contacto@puentesnorte.org');

INSERT INTO donante (nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo)
SELECT 'Asociacion Horizonte Verde', 'donaciones@horizonteverde.pe', '+51 955300410',
       'Jr. Manco Capac 870, Cusco', 'Institucion',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), '2026-01-10', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'donaciones@horizonteverde.pe');

INSERT INTO donante (nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo)
SELECT 'Grupo Empresarial Andino', 'rse@grupoandino.com', '+51 935221090',
       'Av. Javier Prado 1510, Lima', 'Institucion',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), '2026-01-12', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'rse@grupoandino.com');

INSERT INTO donante (nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo)
SELECT 'Red Solidaria del Pacifico', 'alianzas@redpacifico.org', '+56 934410220',
       'Av. Libertad 900, Valparaiso', 'ONG',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'CHILE' LIMIT 1), '2026-01-15', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'alianzas@redpacifico.org');

INSERT INTO donante (nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo)
SELECT 'Lucia Herrera', 'lucia.herrera@email.com', '+51 987101221',
       'Urbanizacion Los Geranios 222, Piura', 'Persona Natural',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), '2026-01-17', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'lucia.herrera@email.com');

INSERT INTO donante (nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo)
SELECT 'Jorge Paredes', 'jorge.paredes@email.com', '+51 968450220',
       'Calle San Martin 449, Trujillo', 'Persona Natural',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), '2026-01-18', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'jorge.paredes@email.com');

INSERT INTO donante (nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo)
SELECT 'Camila Rojas', 'camila.rojas@email.com', '+57 3105508812',
       'Cra 19 #32-11, Medellin', 'Persona Natural',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'COLOMBIA' LIMIT 1), '2026-01-20', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'camila.rojas@email.com');

-- ------------------------------
-- Campanias
-- ------------------------------
INSERT INTO campania (nombre, descripcion, fecha_inicio, fecha_fin, estado, monto_objetivo, activo)
SELECT 'Agua Segura para Los Andes', 'Instalacion de reservorios y filtros para comunidades altoandinas.',
       '2026-01-05', '2026-06-30', 'Activa', 95000.00, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM campania WHERE UPPER(nombre) = 'AGUA SEGURA PARA LOS ANDES');

INSERT INTO campania (nombre, descripcion, fecha_inicio, fecha_fin, estado, monto_objetivo, activo)
SELECT 'Aulas Dignas 2026', 'Rehabilitacion de aulas rurales con mobiliario y conectividad basica.',
       '2026-01-12', '2026-08-15', 'Activa', 120000.00, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM campania WHERE UPPER(nombre) = 'AULAS DIGNAS 2026');

INSERT INTO campania (nombre, descripcion, fecha_inicio, fecha_fin, estado, monto_objetivo, activo)
SELECT 'Salud Comunitaria Preventiva', 'Kits medicos, brigadas y medicamentos esenciales para zonas vulnerables.',
       '2026-01-20', '2026-07-30', 'Activa', 80000.00, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM campania WHERE UPPER(nombre) = 'SALUD COMUNITARIA PREVENTIVA');

INSERT INTO campania (nombre, descripcion, fecha_inicio, fecha_fin, estado, monto_objetivo, activo)
SELECT 'Nutricion Infantil Sierra Norte', 'Programa de suplementacion alimentaria para ninos menores de 10 anos.',
       '2026-01-25', '2026-10-20', 'Activa', 105000.00, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM campania WHERE UPPER(nombre) = 'NUTRICION INFANTIL SIERRA NORTE');

-- ------------------------------
-- Comunidades
-- ------------------------------
INSERT INTO comunidad_vulnerable (nombre, ubicacion, descripcion, cantidad_beneficiarios, id_pais, activo)
SELECT 'Comunidad Los Andes', 'Ayacucho, Peru', 'Zona altoandina con acceso limitado a agua segura y salud primaria.', 380,
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comunidad_vulnerable WHERE UPPER(nombre) = 'COMUNIDAD LOS ANDES');

INSERT INTO comunidad_vulnerable (nombre, ubicacion, descripcion, cantidad_beneficiarios, id_pais, activo)
SELECT 'Villa Esperanza', 'Puno, Peru', 'Poblacion en recuperacion economica con prioridad en educacion y nutricion.', 420,
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comunidad_vulnerable WHERE UPPER(nombre) = 'VILLA ESPERANZA');

INSERT INTO comunidad_vulnerable (nombre, ubicacion, descripcion, cantidad_beneficiarios, id_pais, activo)
SELECT 'Nueva Semilla', 'Cajamarca, Peru', 'Comunidad rural con deficit de infraestructura educativa.', 295,
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comunidad_vulnerable WHERE UPPER(nombre) = 'NUEVA SEMILLA');

INSERT INTO comunidad_vulnerable (nombre, ubicacion, descripcion, cantidad_beneficiarios, id_pais, activo)
SELECT 'Barrio San Miguel', 'Guayaquil, Ecuador', 'Sector periurbano con necesidades de atencion medica preventiva.', 510,
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'ECUADOR' LIMIT 1), 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comunidad_vulnerable WHERE UPPER(nombre) = 'BARRIO SAN MIGUEL');

-- ------------------------------
-- Voluntarios
-- ------------------------------
INSERT INTO voluntario (nombre, email, telefono, fecha_ingreso, estado)
SELECT 'Mariana Flores', 'mariana.flores@voluntarios.org', '+51 977442211', '2026-01-03', 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM voluntario WHERE email = 'mariana.flores@voluntarios.org');

INSERT INTO voluntario (nombre, email, telefono, fecha_ingreso, estado)
SELECT 'Diego Torres', 'diego.torres@voluntarios.org', '+51 966883300', '2026-01-06', 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM voluntario WHERE email = 'diego.torres@voluntarios.org');

INSERT INTO voluntario (nombre, email, telefono, fecha_ingreso, estado)
SELECT 'Paola Medina', 'paola.medina@voluntarios.org', '+51 988002144', '2026-01-09', 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM voluntario WHERE email = 'paola.medina@voluntarios.org');

INSERT INTO voluntario (nombre, email, telefono, fecha_ingreso, estado)
SELECT 'Luis Cardenas', 'luis.cardenas@voluntarios.org', '+51 955228844', '2026-01-11', 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM voluntario WHERE email = 'luis.cardenas@voluntarios.org');

-- ------------------------------
-- Donaciones (15 registros creibles)
-- ------------------------------
INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'rse@grupoandino.com' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'AGUA SEGURA PARA LOS ANDES' LIMIT 1),
       'Monetaria', 'Entregado', '2026-02-01', 18000.00,
       'Transferencia para adquisicion de tanques de agua comunitarios', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Transferencia para adquisicion de tanques de agua comunitarios');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'contacto@puentesnorte.org' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'SALUD COMUNITARIA PREVENTIVA' LIMIT 1),
       'Monetaria', 'En transito', '2026-02-03', 9500.00,
       'Fondo para compra de medicamentos de atencion primaria', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Fondo para compra de medicamentos de atencion primaria');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'lucia.herrera@email.com' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'AULAS DIGNAS 2026' LIMIT 1),
       'Monetaria', 'Pendiente', '2026-02-05', 2500.00,
       'Aporte para compra de carpetas y pizarras para dos aulas rurales', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Aporte para compra de carpetas y pizarras para dos aulas rurales');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'jorge.paredes@email.com' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'NUTRICION INFANTIL SIERRA NORTE' LIMIT 1),
       'Monetaria', 'Entregado', '2026-02-06', 1200.00,
       'Donacion para canastas alimentarias de primera infancia', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Donacion para canastas alimentarias de primera infancia');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'alianzas@redpacifico.org' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'AGUA SEGURA PARA LOS ANDES' LIMIT 1),
       'Recurso', 'En transito', '2026-02-07', NULL,
       'Envio de 30 filtros domesticos para tratamiento de agua', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Envio de 30 filtros domesticos para tratamiento de agua');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'camila.rojas@email.com' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'SALUD COMUNITARIA PREVENTIVA' LIMIT 1),
       'Monetaria', 'Pendiente', '2026-02-08', 1700.00,
       'Aporte solidario para brigada medica de fin de mes', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Aporte solidario para brigada medica de fin de mes');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'donaciones@horizonteverde.pe' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'AULAS DIGNAS 2026' LIMIT 1),
       'Recurso', 'Entregado', '2026-02-09', NULL,
       'Entrega de 20 escritorios metalicos y 40 sillas escolares', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Entrega de 20 escritorios metalicos y 40 sillas escolares');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'contacto@puentesnorte.org' LIMIT 1),
       NULL,
       'Monetaria', 'Pendiente', '2026-02-10', 3200.00,
       'Fondo libre para emergencias de comunidades afectadas por lluvias', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Fondo libre para emergencias de comunidades afectadas por lluvias');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'rse@grupoandino.com' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'NUTRICION INFANTIL SIERRA NORTE' LIMIT 1),
       'Monetaria', 'Entregado', '2026-02-11', 7600.00,
       'Cobertura de compras para suplemento nutricional trimestral', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Cobertura de compras para suplemento nutricional trimestral');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'lucia.herrera@email.com' LIMIT 1),
       NULL,
       'Recurso', 'En transito', '2026-02-12', NULL,
       'Donacion de 12 cajas de utiles escolares para primaria', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Donacion de 12 cajas de utiles escolares para primaria');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'jorge.paredes@email.com' LIMIT 1),
       NULL,
       'Monetaria', 'Entregado', '2026-02-13', 850.00,
       'Aporte para movilidad de voluntarios en jornada de entrega', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Aporte para movilidad de voluntarios en jornada de entrega');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'donaciones@horizonteverde.pe' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'AGUA SEGURA PARA LOS ANDES' LIMIT 1),
       'Monetaria', 'Pendiente', '2026-02-14', 5400.00,
       'Financiamiento para instalacion de conexiones domiciliarias basicas', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Financiamiento para instalacion de conexiones domiciliarias basicas');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'alianzas@redpacifico.org' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'SALUD COMUNITARIA PREVENTIVA' LIMIT 1),
       'Recurso', 'Pendiente', '2026-02-15', NULL,
       'Lote de botiquines familiares para atencion de primeros auxilios', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Lote de botiquines familiares para atencion de primeros auxilios');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'camila.rojas@email.com' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'AULAS DIGNAS 2026' LIMIT 1),
       'Monetaria', 'En transito', '2026-02-16', 2150.00,
       'Apoyo para reparacion electrica y luminarias de aulas comunitarias', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Apoyo para reparacion electrica y luminarias de aulas comunitarias');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'rse@grupoandino.com' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'SALUD COMUNITARIA PREVENTIVA' LIMIT 1),
       'Monetaria', 'Entregado', '2026-02-18', 12400.00,
       'Fondo corporativo para compras de equipamiento de posta medica rural', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Fondo corporativo para compras de equipamiento de posta medica rural');

-- ------------------------------
-- Estados de entrega base
-- ------------------------------
INSERT INTO estado_entrega (id_estado_entrega, descripcion)
SELECT 1, 'Programado' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM estado_entrega WHERE id_estado_entrega = 1);

INSERT INTO estado_entrega (id_estado_entrega, descripcion)
SELECT 2, 'En transito' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM estado_entrega WHERE id_estado_entrega = 2);

INSERT INTO estado_entrega (id_estado_entrega, descripcion)
SELECT 3, 'Entregado' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM estado_entrega WHERE id_estado_entrega = 3);

INSERT INTO estado_entrega (id_estado_entrega, descripcion)
SELECT 4, 'Cancelado' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM estado_entrega WHERE id_estado_entrega = 4);

-- ------------------------------
-- Entregas
-- ------------------------------
INSERT INTO entrega_donacion (id_donacion, id_comunidad, fecha_programada, fecha_entrega, id_estado_entrega, observaciones)
SELECT d.id_donacion,
       (SELECT id_comunidad FROM comunidad_vulnerable WHERE UPPER(nombre) = 'COMUNIDAD LOS ANDES' LIMIT 1),
       '2026-02-12 09:30:00', '2026-02-14 16:15:00', 3,
       'Entrega completada con acta firmada por comite comunal'
FROM donacion d
WHERE d.descripcion = 'Transferencia para adquisicion de tanques de agua comunitarios'
  AND NOT EXISTS (SELECT 1 FROM entrega_donacion e WHERE e.observaciones = 'Entrega completada con acta firmada por comite comunal');

INSERT INTO entrega_donacion (id_donacion, id_comunidad, fecha_programada, fecha_entrega, id_estado_entrega, observaciones)
SELECT d.id_donacion,
       (SELECT id_comunidad FROM comunidad_vulnerable WHERE UPPER(nombre) = 'VILLA ESPERANZA' LIMIT 1),
       '2026-02-15 10:00:00', NULL, 2,
       'Carga consolidada y en ruta, pendiente arribo final'
FROM donacion d
WHERE d.descripcion = 'Fondo para compra de medicamentos de atencion primaria'
  AND NOT EXISTS (SELECT 1 FROM entrega_donacion e WHERE e.observaciones = 'Carga consolidada y en ruta, pendiente arribo final');

INSERT INTO entrega_donacion (id_donacion, id_comunidad, fecha_programada, fecha_entrega, id_estado_entrega, observaciones)
SELECT d.id_donacion,
       (SELECT id_comunidad FROM comunidad_vulnerable WHERE UPPER(nombre) = 'NUEVA SEMILLA' LIMIT 1),
       '2026-02-18 08:45:00', NULL, 1,
       'Programada para jornada educativa de fin de mes'
FROM donacion d
WHERE d.descripcion = 'Aporte para compra de carpetas y pizarras para dos aulas rurales'
  AND NOT EXISTS (SELECT 1 FROM entrega_donacion e WHERE e.observaciones = 'Programada para jornada educativa de fin de mes');

INSERT INTO entrega_donacion (id_donacion, id_comunidad, fecha_programada, fecha_entrega, id_estado_entrega, observaciones)
SELECT d.id_donacion,
       (SELECT id_comunidad FROM comunidad_vulnerable WHERE UPPER(nombre) = 'BARRIO SAN MIGUEL' LIMIT 1),
       '2026-02-20 11:00:00', '2026-02-21 14:40:00', 3,
       'Distribucion realizada en centro comunal con apoyo de voluntarios'
FROM donacion d
WHERE d.descripcion = 'Cobertura de compras para suplemento nutricional trimestral'
  AND NOT EXISTS (SELECT 1 FROM entrega_donacion e WHERE e.observaciones = 'Distribucion realizada en centro comunal con apoyo de voluntarios');

-- ------------------------------
-- Lote adicional (20 registros realistas)
-- ------------------------------

-- Donantes (+4)
INSERT INTO donante (nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo)
SELECT 'Cooperativa Agrovida Junin', 'alianzas@agrovida.pe', '+51 964110845',
       'Av. Real 880, Huancayo', 'Institucion',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), '2026-02-19', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'alianzas@agrovida.pe');

INSERT INTO donante (nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo)
SELECT 'Fundacion Manos del Sur', 'contacto@manosdelsur.org', '+56 931440225',
       'Av. Matta 1420, Santiago', 'Fundacion',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'CHILE' LIMIT 1), '2026-02-20', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'contacto@manosdelsur.org');

INSERT INTO donante (nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo)
SELECT 'Emilia Navarro', 'emilia.navarro@email.com', '+593 992331480',
       'Cdla. Kennedy Norte, Guayaquil', 'Persona Natural',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'ECUADOR' LIMIT 1), '2026-02-21', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'emilia.navarro@email.com');

INSERT INTO donante (nombre, email, telefono, direccion, tipo_donante, id_pais, fecha_registro, activo)
SELECT 'Carlos Mena', 'carlos.mena@email.com', '+51 982113406',
       'Jr. Pizarro 590, Trujillo', 'Persona Natural',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), '2026-02-22', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'carlos.mena@email.com');

-- Campanias (+3)
INSERT INTO campania (nombre, descripcion, fecha_inicio, fecha_fin, estado, monto_objetivo, activo)
SELECT 'Recuperacion de Viviendas Altoandinas',
       'Mejora de techos termicos y reparacion estructural para familias vulnerables en zonas de friaje.',
       '2026-02-01', '2026-09-30', 'Activa', 135000.00, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM campania WHERE UPPER(nombre) = 'RECUPERACION DE VIVIENDAS ALTOANDINAS');

INSERT INTO campania (nombre, descripcion, fecha_inicio, fecha_fin, estado, monto_objetivo, activo)
SELECT 'Conectividad Escolar Rural',
       'Dotacion de routers, paneles solares y puntos de acceso para escuelas comunitarias.',
       '2026-02-05', '2026-11-15', 'Activa', 98000.00, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM campania WHERE UPPER(nombre) = 'CONECTIVIDAD ESCOLAR RURAL');

INSERT INTO campania (nombre, descripcion, fecha_inicio, fecha_fin, estado, monto_objetivo, activo)
SELECT 'Banco Comunitario de Alimentos',
       'Fortalecimiento de comedores populares con abastecimiento mensual y cadena de frio basica.',
       '2026-02-10', '2026-12-20', 'Activa', 87000.00, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM campania WHERE UPPER(nombre) = 'BANCO COMUNITARIO DE ALIMENTOS');

-- Comunidades (+4)
INSERT INTO comunidad_vulnerable (nombre, ubicacion, descripcion, cantidad_beneficiarios, id_pais, activo)
SELECT 'Centro Poblado Santa Rosa', 'Huancavelica, Peru',
       'Comunidad de altura con brechas de vivienda segura y servicios de salud.', 360,
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comunidad_vulnerable WHERE UPPER(nombre) = 'CENTRO POBLADO SANTA ROSA');

INSERT INTO comunidad_vulnerable (nombre, ubicacion, descripcion, cantidad_beneficiarios, id_pais, activo)
SELECT 'Comunidad El Porvenir', 'La Paz, Bolivia',
       'Zona periurbana con alta demanda de apoyo alimentario y educacion inicial.', 270,
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'BOLIVIA' LIMIT 1), 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comunidad_vulnerable WHERE UPPER(nombre) = 'COMUNIDAD EL PORVENIR');

INSERT INTO comunidad_vulnerable (nombre, ubicacion, descripcion, cantidad_beneficiarios, id_pais, activo)
SELECT 'Sector Nueva Luz', 'Quito, Ecuador',
       'Sector con necesidades de conectividad educativa y programas de nutricion infantil.', 430,
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'ECUADOR' LIMIT 1), 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comunidad_vulnerable WHERE UPPER(nombre) = 'SECTOR NUEVA LUZ');

INSERT INTO comunidad_vulnerable (nombre, ubicacion, descripcion, cantidad_beneficiarios, id_pais, activo)
SELECT 'Barrio Los Pinos Solidario', 'Arequipa, Peru',
       'Asentamiento con deficit de infraestructura basica y gestion de riesgos climaticos.', 390,
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comunidad_vulnerable WHERE UPPER(nombre) = 'BARRIO LOS PINOS SOLIDARIO');

-- Voluntarios (+3)
INSERT INTO voluntario (nombre, email, telefono, fecha_ingreso, estado)
SELECT 'Andrea Poma', 'andrea.poma@voluntarios.org', '+51 974112850', '2026-02-19', 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM voluntario WHERE email = 'andrea.poma@voluntarios.org');

INSERT INTO voluntario (nombre, email, telefono, fecha_ingreso, estado)
SELECT 'Renato Silva', 'renato.silva@voluntarios.org', '+51 986330194', '2026-02-20', 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM voluntario WHERE email = 'renato.silva@voluntarios.org');

INSERT INTO voluntario (nombre, email, telefono, fecha_ingreso, estado)
SELECT 'Sofia Calderon', 'sofia.calderon@voluntarios.org', '+51 965008421', '2026-02-22', 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM voluntario WHERE email = 'sofia.calderon@voluntarios.org');

-- Donaciones (+6)
INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'alianzas@agrovida.pe' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'RECUPERACION DE VIVIENDAS ALTOANDINAS' LIMIT 1),
       'Monetaria', 'Entregado', '2026-02-20', 9800.00,
       'Aporte para compra de planchas termicas y kits de reparacion de viviendas', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Aporte para compra de planchas termicas y kits de reparacion de viviendas');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'contacto@manosdelsur.org' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'BANCO COMUNITARIO DE ALIMENTOS' LIMIT 1),
       'Recurso', 'En transito', '2026-02-21', NULL,
       'Entrega de conservadoras y menaje para tres comedores comunitarios', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Entrega de conservadoras y menaje para tres comedores comunitarios');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'emilia.navarro@email.com' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'CONECTIVIDAD ESCOLAR RURAL' LIMIT 1),
       'Monetaria', 'Pendiente', '2026-02-22', 1450.00,
       'Aporte familiar para compra de modem y baterias de respaldo escolar', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Aporte familiar para compra de modem y baterias de respaldo escolar');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'carlos.mena@email.com' LIMIT 1),
       NULL,
       'Monetaria', 'Entregado', '2026-02-22', 650.00,
       'Apoyo para transporte de brigada y traslado de materiales de entrega', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Apoyo para transporte de brigada y traslado de materiales de entrega');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'rse@grupoandino.com' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'RECUPERACION DE VIVIENDAS ALTOANDINAS' LIMIT 1),
       'Monetaria', 'En transito', '2026-02-23', 11200.00,
       'Fondo corporativo para rehabilitar techos y muros en zona altoandina', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Fondo corporativo para rehabilitar techos y muros en zona altoandina');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'camila.rojas@email.com' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'BANCO COMUNITARIO DE ALIMENTOS' LIMIT 1),
       'Monetaria', 'Pendiente', '2026-02-23', 2300.00,
       'Contribucion para abastecimiento mensual de alimentos de primera necesidad', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Contribucion para abastecimiento mensual de alimentos de primera necesidad');

-- ------------------------------
-- Normalizacion de fechas (sin nulos y consistentes)
-- ------------------------------
UPDATE campania
SET fecha_inicio = COALESCE(fecha_inicio, CURDATE() - INTERVAL 30 DAY),
    fecha_fin    = COALESCE(fecha_fin,    CURDATE() + INTERVAL 180 DAY)
WHERE fecha_inicio IS NULL OR fecha_fin IS NULL;

UPDATE voluntario
SET fecha_ingreso = COALESCE(fecha_ingreso, CURDATE() - INTERVAL 10 DAY)
WHERE fecha_ingreso IS NULL;

UPDATE entrega_donacion
SET fecha_programada = COALESCE(fecha_programada, NOW())
WHERE fecha_programada IS NULL;

UPDATE entrega_donacion
SET fecha_entrega = CASE
    WHEN id_estado_entrega = 1 THEN DATE_ADD(fecha_programada, INTERVAL 7 DAY)
    WHEN id_estado_entrega = 2 THEN DATE_ADD(fecha_programada, INTERVAL 2 DAY)
    ELSE COALESCE(fecha_programada, NOW())
END
WHERE fecha_entrega IS NULL;

UPDATE entrega_donacion
SET fecha_entrega = CASE
    WHEN id_estado_entrega = 1 THEN DATE_ADD(fecha_programada, INTERVAL 7 DAY)
    WHEN id_estado_entrega = 2 THEN DATE_ADD(fecha_programada, INTERVAL 2 DAY)
    ELSE fecha_programada
END
WHERE fecha_programada IS NOT NULL
  AND fecha_entrega IS NOT NULL
  AND fecha_entrega < fecha_programada;
