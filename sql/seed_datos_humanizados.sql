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
SELECT 'Fundacion Puentes del Norte', 'institucion@donaciones.org', '+51 944111221',
       'Av. Alfonso Ugarte 223, Chiclayo', 'Fundacion',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), '2026-01-08', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'institucion@donaciones.org');

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
SELECT 'Lucia Herrera', 'persona@email.com', '+51 987101221',
       'Urbanizacion Los Geranios 222, Piura', 'Persona Natural',
       (SELECT id_pais FROM pais WHERE UPPER(nombre) = 'PERU' LIMIT 1), '2026-01-17', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donante WHERE email = 'persona@email.com');

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
SELECT (SELECT id_donante FROM donante WHERE email = 'institucion@donaciones.org' LIMIT 1),
       (SELECT id_campania FROM campania WHERE UPPER(nombre) = 'SALUD COMUNITARIA PREVENTIVA' LIMIT 1),
       'Monetaria', 'En transito', '2026-02-03', 9500.00,
       'Fondo para compra de medicamentos de atencion primaria', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM donacion WHERE descripcion = 'Fondo para compra de medicamentos de atencion primaria');

INSERT INTO donacion (id_donante, id_campania, tipo_donacion, estado_donacion, fecha_donacion, monto, descripcion, activo)
SELECT (SELECT id_donante FROM donante WHERE email = 'persona@email.com' LIMIT 1),
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
SELECT (SELECT id_donante FROM donante WHERE email = 'institucion@donaciones.org' LIMIT 1),
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
SELECT (SELECT id_donante FROM donante WHERE email = 'persona@email.com' LIMIT 1),
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
