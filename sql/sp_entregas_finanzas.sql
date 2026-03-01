-- ============================================================
-- TABLAS
-- ============================================================
CREATE TABLE IF NOT EXISTS estado_entrega (
    id_estado_entrega INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO estado_entrega (id_estado_entrega, descripcion) VALUES
(1, 'Programado'),
(2, 'En transito'),
(3, 'Entregado'),
(4, 'Cancelado');

CREATE TABLE IF NOT EXISTS comunidad_responsable (
    id_responsable INT AUTO_INCREMENT PRIMARY KEY,
    id_comunidad INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(20) NULL,
    email VARCHAR(100) NULL,
    cargo VARCHAR(100) NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    KEY idx_responsable_comunidad (id_comunidad),
    CONSTRAINT fk_responsable_comunidad
        FOREIGN KEY (id_comunidad) REFERENCES comunidad_vulnerable(id_comunidad)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS entrega_donacion (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_donacion INT NOT NULL,
    id_comunidad INT NOT NULL,
    id_responsable INT NULL,
    fecha_programada DATETIME,
    fecha_entrega DATETIME,
    id_estado_entrega INT NOT NULL DEFAULT 1,
    observaciones TEXT,
    FOREIGN KEY (id_donacion) REFERENCES donacion(id_donacion),
    FOREIGN KEY (id_comunidad) REFERENCES comunidad_vulnerable(id_comunidad),
    FOREIGN KEY (id_responsable) REFERENCES comunidad_responsable(id_responsable),
    FOREIGN KEY (id_estado_entrega) REFERENCES estado_entrega(id_estado_entrega)
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
        e.id_responsable,
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
        e.id_responsable,
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
    IN p_id_responsable INT,
    IN p_id_estado_entrega INT,
    IN p_fecha_programada DATETIME,
    IN p_fecha_entrega DATETIME,
    IN p_observaciones TEXT
)
BEGIN
    INSERT INTO entrega_donacion (
        id_donacion, id_comunidad, id_responsable, id_estado_entrega,
        fecha_programada, fecha_entrega, observaciones
    ) VALUES (
        p_id_donacion, p_id_comunidad, p_id_responsable, p_id_estado_entrega,
        p_fecha_programada, p_fecha_entrega, p_observaciones
    );
    SELECT LAST_INSERT_ID() AS new_id;
END$$

CREATE PROCEDURE sp_entrega_editar(
    IN p_id_entrega INT,
    IN p_id_donacion INT,
    IN p_id_comunidad INT,
    IN p_id_responsable INT,
    IN p_id_estado_entrega INT,
    IN p_fecha_programada DATETIME,
    IN p_fecha_entrega DATETIME,
    IN p_observaciones TEXT
)
BEGIN
    UPDATE entrega_donacion
    SET id_donacion = p_id_donacion,
        id_comunidad = p_id_comunidad,
        id_responsable = p_id_responsable,
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
