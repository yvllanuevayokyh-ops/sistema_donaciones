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
