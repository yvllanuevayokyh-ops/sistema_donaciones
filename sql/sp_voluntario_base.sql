ALTER TABLE voluntario
    ADD COLUMN IF NOT EXISTS estado TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE voluntario
    ADD COLUMN IF NOT EXISTS id_campania INT NULL;

SET @fk_voluntario_campania_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'voluntario'
      AND CONSTRAINT_NAME = 'fk_voluntario_campania'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_add_fk_voluntario_campania := IF(
    @fk_voluntario_campania_exists = 0,
    'ALTER TABLE voluntario ADD CONSTRAINT fk_voluntario_campania FOREIGN KEY (id_campania) REFERENCES campania(id_campania) ON UPDATE CASCADE ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE stmt_fk_voluntario_campania FROM @sql_add_fk_voluntario_campania;
EXECUTE stmt_fk_voluntario_campania;
DEALLOCATE PREPARE stmt_fk_voluntario_campania;

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
        v.id_campania,
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
        v.id_campania,
        v.estado
    FROM voluntario v
    WHERE v.id_voluntario = p_id_voluntario
    LIMIT 1;
END$$

CREATE PROCEDURE sp_voluntario_crear(
    IN p_nombre VARCHAR(150),
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_fecha_ingreso DATE,
    IN p_id_campania INT
)
BEGIN
    INSERT INTO voluntario (nombre, telefono, email, fecha_ingreso, id_campania, estado)
    VALUES (p_nombre, p_telefono, p_email, p_fecha_ingreso, p_id_campania, 1);

    SELECT LAST_INSERT_ID() AS new_id;
END$$

CREATE PROCEDURE sp_voluntario_editar(
    IN p_id_voluntario INT,
    IN p_nombre VARCHAR(150),
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_fecha_ingreso DATE,
    IN p_id_campania INT
)
BEGIN
    UPDATE voluntario
    SET
        nombre = p_nombre,
        telefono = p_telefono,
        email = p_email,
        fecha_ingreso = p_fecha_ingreso,
        id_campania = p_id_campania
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
