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
        COALESCE(d.email, '') AS email,
        COALESCE(d.telefono, '') AS telefono,
        COALESCE(d.direccion, '') AS direccion,
        COALESCE(d.tipo_donante, 'Institucion') AS tipo_donante,
        d.id_pais,
        d.fecha_registro,
        d.activo,
        p.nombre AS pais,
        COUNT(DISTINCT dn.id_donacion) AS total_donaciones
    FROM donante d
    INNER JOIN pais p ON p.id_pais = d.id_pais
    LEFT JOIN donacion dn ON dn.id_donante = d.id_donante
    WHERE
        UPPER(d.tipo_donante) NOT LIKE 'PERSONA%'
        AND (
            p_q IS NULL OR p_q = '' OR
            UPPER(d.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(p.nombre) LIKE CONCAT('%', UPPER(p_q), '%') OR
            UPPER(COALESCE(d.direccion, '')) LIKE CONCAT('%', UPPER(p_q), '%')
        )
        AND (p_activo IS NULL OR d.activo = p_activo)
    GROUP BY
        d.id_donante, d.nombre, d.email, d.telefono, d.direccion,
        d.tipo_donante, d.id_pais, p.nombre, d.activo
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
        COALESCE(d.email, '') AS email,
        COALESCE(d.telefono, '') AS telefono,
        COALESCE(d.direccion, '') AS direccion,
        COALESCE(d.tipo_donante, 'Institucion') AS tipo_donante,
        d.id_pais,
        d.fecha_registro,
        d.activo,
        p.nombre AS pais,
        DATE_FORMAT(d.fecha_registro, '%Y-%m-%d') AS fecha_registro_fmt,
        COUNT(DISTINCT dn.id_donacion) AS total_donaciones
    FROM donante d
    INNER JOIN pais p ON p.id_pais = d.id_pais
    LEFT JOIN donacion dn ON dn.id_donante = d.id_donante
    WHERE d.id_donante = p_id_donante
      AND UPPER(d.tipo_donante) NOT LIKE 'PERSONA%'
    GROUP BY
        d.id_donante, d.nombre, d.email, d.telefono, d.direccion,
        d.tipo_donante, d.id_pais, d.fecha_registro, d.activo, p.nombre
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
