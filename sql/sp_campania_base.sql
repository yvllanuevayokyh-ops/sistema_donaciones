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
