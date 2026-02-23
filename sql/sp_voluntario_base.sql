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
        COALESCE(v.email, '') AS email,
        COALESCE(v.telefono, '') AS telefono,
        v.fecha_ingreso,
        v.estado,
        DATE_FORMAT(v.fecha_ingreso, '%Y-%m-%d') AS fecha_ingreso_fmt,
        COUNT(DISTINCT ave.id_entrega) AS total_entregas,
        SUM(CASE WHEN UPPER(COALESCE(ee.descripcion, '')) = 'ENTREGADO' THEN 1 ELSE 0 END) AS entregas_completadas
    FROM voluntario v
    LEFT JOIN asignacion_voluntario_entrega ave ON ave.id_voluntario = v.id_voluntario
    LEFT JOIN entrega_donacion ed ON ed.id_entrega = ave.id_entrega
    LEFT JOIN estado_entrega ee ON ee.id_estado_entrega = ed.id_estado_entrega
    WHERE
        (
            p_q IS NULL OR p_q = '' OR
            UPPER(v.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(v.email, '')) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(v.telefono, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND (p_estado IS NULL OR v.estado = p_estado)
    GROUP BY
        v.id_voluntario, v.nombre, v.email, v.telefono, v.fecha_ingreso, v.estado
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
        COALESCE(v.email, '') AS email,
        COALESCE(v.telefono, '') AS telefono,
        v.fecha_ingreso,
        v.estado,
        DATE_FORMAT(v.fecha_ingreso, '%Y-%m-%d') AS fecha_ingreso_fmt,
        COUNT(DISTINCT ave.id_entrega) AS total_entregas,
        SUM(CASE WHEN UPPER(COALESCE(ee.descripcion, '')) = 'ENTREGADO' THEN 1 ELSE 0 END) AS entregas_completadas
    FROM voluntario v
    LEFT JOIN asignacion_voluntario_entrega ave ON ave.id_voluntario = v.id_voluntario
    LEFT JOIN entrega_donacion ed ON ed.id_entrega = ave.id_entrega
    LEFT JOIN estado_entrega ee ON ee.id_estado_entrega = ed.id_estado_entrega
    WHERE v.id_voluntario = p_id_voluntario
    GROUP BY
        v.id_voluntario, v.nombre, v.email, v.telefono, v.fecha_ingreso, v.estado
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
