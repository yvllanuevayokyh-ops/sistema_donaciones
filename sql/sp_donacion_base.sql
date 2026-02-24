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
