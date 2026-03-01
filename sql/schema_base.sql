CREATE DATABASE IF NOT EXISTS sistema_donaciones
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sistema_donaciones;

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS pais (
    id_pais INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    UNIQUE KEY uk_pais_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rol_usuario (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    UNIQUE KEY uk_rol_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS comunidad_responsable (
    id_responsable INT AUTO_INCREMENT PRIMARY KEY,
    id_comunidad INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(20) NULL,
    email VARCHAR(100) NULL,
    cargo VARCHAR(100) NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    KEY idx_responsable_comunidad (id_comunidad),
    KEY idx_responsable_nombre (nombre),
    KEY idx_responsable_activo (activo),
    CONSTRAINT fk_responsable_comunidad
        FOREIGN KEY (id_comunidad) REFERENCES comunidad_vulnerable(id_comunidad)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS voluntario (
    id_voluntario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(20) NULL,
    email VARCHAR(100) NULL,
    fecha_ingreso DATE NULL,
    id_campania INT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    KEY idx_voluntario_nombre (nombre),
    KEY idx_voluntario_estado (estado),
    KEY idx_voluntario_email (email),
    KEY idx_voluntario_campania (id_campania),
    CONSTRAINT fk_voluntario_campania
        FOREIGN KEY (id_campania) REFERENCES campania(id_campania)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS estado_entrega (
    id_estado_entrega INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL,
    UNIQUE KEY uk_estado_entrega_descripcion (descripcion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS entrega_donacion (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_donacion INT NOT NULL,
    id_comunidad INT NOT NULL,
    id_responsable INT NULL,
    fecha_programada DATETIME NULL,
    fecha_entrega DATETIME NULL,
    id_estado_entrega INT NOT NULL DEFAULT 1,
    observaciones TEXT NULL,
    KEY idx_entrega_donacion (id_donacion),
    KEY idx_entrega_comunidad (id_comunidad),
    KEY idx_entrega_responsable (id_responsable),
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
    CONSTRAINT fk_entrega_donacion_responsable
        FOREIGN KEY (id_responsable) REFERENCES comunidad_responsable(id_responsable)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_entrega_donacion_estado
        FOREIGN KEY (id_estado_entrega) REFERENCES estado_entrega(id_estado_entrega)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE entrega_donacion
    ADD COLUMN IF NOT EXISTS id_responsable INT NULL;

SET @fk_entrega_responsable_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'entrega_donacion'
      AND CONSTRAINT_NAME = 'fk_entrega_donacion_responsable'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_add_fk_entrega_responsable := IF(
    @fk_entrega_responsable_exists = 0,
    'ALTER TABLE entrega_donacion ADD CONSTRAINT fk_entrega_donacion_responsable FOREIGN KEY (id_responsable) REFERENCES comunidad_responsable(id_responsable) ON UPDATE CASCADE ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE stmt_fk_entrega_responsable FROM @sql_add_fk_entrega_responsable;
EXECUTE stmt_fk_entrega_responsable;
DEALLOCATE PREPARE stmt_fk_entrega_responsable;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS auditoria_log (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(120) NULL,
    rol VARCHAR(80) NULL,
    modulo VARCHAR(80) NULL,
    accion VARCHAR(80) NULL,
    detalle VARCHAR(500) NULL,
    estado_http INT NULL,
    KEY idx_auditoria_fecha (fecha_evento),
    KEY idx_auditoria_modulo (modulo),
    KEY idx_auditoria_accion (accion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE campania
    ADD COLUMN IF NOT EXISTS id_comunidad INT NULL;

SET @fk_campania_comunidad_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'campania'
      AND CONSTRAINT_NAME = 'fk_campania_comunidad'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_add_fk_campania_comunidad := IF(
    @fk_campania_comunidad_exists = 0,
    'ALTER TABLE campania ADD CONSTRAINT fk_campania_comunidad FOREIGN KEY (id_comunidad) REFERENCES comunidad_vulnerable(id_comunidad) ON UPDATE CASCADE ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE stmt_fk_campania_comunidad FROM @sql_add_fk_campania_comunidad;
EXECUTE stmt_fk_campania_comunidad;
DEALLOCATE PREPARE stmt_fk_campania_comunidad;

ALTER TABLE pais CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rol_usuario CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE usuario_sistema CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE donante CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE campania CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE comunidad_vulnerable CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE comunidad_responsable CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE voluntario CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE donacion CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE estado_entrega CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE entrega_donacion CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE asignacion_voluntario_entrega CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE auditoria_log CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

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

INSERT INTO comunidad_responsable (id_comunidad, nombre, telefono, email, cargo, activo)
SELECT c.id_comunidad, 'Rosa Quispe', '999111222', 'rosa.quispe@losandes.org', 'Presidenta comunal', 1
FROM comunidad_vulnerable c
WHERE LOWER(c.nombre) = LOWER('Comunidad Los Andes')
  AND NOT EXISTS (
      SELECT 1
      FROM comunidad_responsable r
      WHERE r.id_comunidad = c.id_comunidad
        AND LOWER(r.nombre) = LOWER('Rosa Quispe')
  );
