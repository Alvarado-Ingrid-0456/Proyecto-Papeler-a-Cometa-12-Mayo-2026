-- ============================================================
--  Base de datos: Papelería Cometa
--  Versión: 1.0
--  Motor: MySQL 8.0+
--  Descripción: Gestión de inventario, ventas y compras
-- ============================================================

DROP DATABASE IF EXISTS bdpapeleriacometa;
CREATE DATABASE bdpapeleriacometa
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bdpapeleriacometa;

-- ============================================================
--  1. CATEGORIA
-- ============================================================
CREATE TABLE CATEGORIA (
  id_categoria  INT            NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(80)    NOT NULL,
  descripcion   TEXT,
  CONSTRAINT PK_categoria  PRIMARY KEY (id_categoria),
  CONSTRAINT UQ_cat_nombre UNIQUE (nombre)
) ENGINE=InnoDB;


-- ============================================================
--  2. PROVEEDOR
-- ============================================================
CREATE TABLE PROVEEDOR (
  id_proveedor  INT            NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(120)   NOT NULL,
  rfc           VARCHAR(13),
  telefono      VARCHAR(15),
  correo        VARCHAR(100),
  direccion     VARCHAR(200),
  activo        TINYINT(1)     NOT NULL DEFAULT 1,
  CONSTRAINT PK_proveedor  PRIMARY KEY (id_proveedor),
  CONSTRAINT UQ_prov_rfc   UNIQUE (rfc)
) ENGINE=InnoDB;


-- ============================================================
--  3. PRODUCTO
-- ============================================================
CREATE TABLE PRODUCTO (
  id_producto   INT            NOT NULL AUTO_INCREMENT,
  codigo_barras VARCHAR(50),
  nombre        VARCHAR(120)   NOT NULL,
  descripcion   TEXT,
  id_categoria  INT            NOT NULL,
  id_proveedor  INT            NOT NULL,
  precio_compra DECIMAL(10,2)  NOT NULL,
  precio_venta  DECIMAL(10,2)  NOT NULL,
  stock_actual  INT            NOT NULL DEFAULT 0,
  stock_minimo  INT            NOT NULL DEFAULT 5,
  activo        TINYINT(1)     NOT NULL DEFAULT 1,
  CONSTRAINT PK_producto       PRIMARY KEY (id_producto),
  CONSTRAINT UQ_prod_barras    UNIQUE (codigo_barras),
  CONSTRAINT FK_prod_categoria FOREIGN KEY (id_categoria)
    REFERENCES CATEGORIA (id_categoria)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT FK_prod_proveedor FOREIGN KEY (id_proveedor)
    REFERENCES PROVEEDOR (id_proveedor)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT CHK_prod_precios  CHECK (precio_venta >= precio_compra),
  CONSTRAINT CHK_prod_stock    CHECK (stock_actual >= 0)
) ENGINE=InnoDB;

CREATE INDEX IDX_prod_categoria ON PRODUCTO (id_categoria);
CREATE INDEX IDX_prod_proveedor ON PRODUCTO (id_proveedor);
CREATE INDEX IDX_prod_nombre    ON PRODUCTO (nombre);


-- ============================================================
--  4. CLIENTE
-- ============================================================
CREATE TABLE CLIENTE (
  id_cliente      INT           NOT NULL AUTO_INCREMENT,
  nombre          VARCHAR(120)  NOT NULL,
  telefono        VARCHAR(15),
  correo          VARCHAR(100),
  fecha_registro  DATE          NOT NULL,
  tipo            ENUM('general','frecuente','escuela') NOT NULL DEFAULT 'general',
  CONSTRAINT PK_cliente PRIMARY KEY (id_cliente)
) ENGINE=InnoDB;


-- ============================================================
--  5. EMPLEADO
-- ============================================================
CREATE TABLE EMPLEADO (
  id_empleado   INT           NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(120)  NOT NULL,
  puesto        ENUM('cajero','almacen','admin') NOT NULL,
  turno         ENUM('matutino','vespertino')    NOT NULL,
  telefono      VARCHAR(15),
  fecha_ingreso DATE          NOT NULL,
  activo        TINYINT(1)    NOT NULL DEFAULT 1,
  CONSTRAINT PK_empleado PRIMARY KEY (id_empleado)
) ENGINE=InnoDB;


-- ============================================================
--  6. VENTA
-- ============================================================
CREATE TABLE VENTA (
  id_venta     INT           NOT NULL AUTO_INCREMENT,
  id_cliente   INT,
  id_empleado  INT           NOT NULL,
  fecha        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  subtotal     DECIMAL(10,2) NOT NULL,
  iva          DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total        DECIMAL(10,2) NOT NULL,
  metodo_pago  ENUM('efectivo','tarjeta','transferencia') NOT NULL DEFAULT 'efectivo',
  estado       ENUM('pagada','cancelada') NOT NULL DEFAULT 'pagada',
  CONSTRAINT PK_venta       PRIMARY KEY (id_venta),
  CONSTRAINT FK_vta_cliente FOREIGN KEY (id_cliente)
    REFERENCES CLIENTE (id_cliente)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT FK_vta_empleado FOREIGN KEY (id_empleado)
    REFERENCES EMPLEADO (id_empleado)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT CHK_vta_total CHECK (total >= 0)
) ENGINE=InnoDB;

CREATE INDEX IDX_venta_fecha    ON VENTA (fecha);
CREATE INDEX IDX_venta_cliente  ON VENTA (id_cliente);
CREATE INDEX IDX_venta_empleado ON VENTA (id_empleado);


-- ============================================================
--  7. DETALLE_VENTA
-- ============================================================
CREATE TABLE DETALLE_VENTA (
  id_detalle      INT           NOT NULL AUTO_INCREMENT,
  id_venta        INT           NOT NULL,
  id_producto     INT           NOT NULL,
  cantidad        INT           NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  descuento       DECIMAL(5,2)  NOT NULL DEFAULT 0.00,
  subtotal        DECIMAL(10,2) NOT NULL,
  CONSTRAINT PK_det_venta      PRIMARY KEY (id_detalle),
  CONSTRAINT FK_dv_venta       FOREIGN KEY (id_venta)
    REFERENCES VENTA (id_venta)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT FK_dv_producto    FOREIGN KEY (id_producto)
    REFERENCES PRODUCTO (id_producto)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT CHK_dv_cantidad   CHECK (cantidad > 0),
  CONSTRAINT CHK_dv_descuento  CHECK (descuento BETWEEN 0 AND 100)
) ENGINE=InnoDB;

CREATE INDEX IDX_dv_venta    ON DETALLE_VENTA (id_venta);
CREATE INDEX IDX_dv_producto ON DETALLE_VENTA (id_producto);


-- ============================================================
--  8. COMPRA
-- ============================================================
CREATE TABLE COMPRA (
  id_compra      INT           NOT NULL AUTO_INCREMENT,
  id_proveedor   INT           NOT NULL,
  id_empleado    INT           NOT NULL,
  fecha          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  folio_factura  VARCHAR(40),
  total          DECIMAL(10,2) NOT NULL,
  estado         ENUM('recibida','parcial','cancelada') NOT NULL DEFAULT 'recibida',
  CONSTRAINT PK_compra        PRIMARY KEY (id_compra),
  CONSTRAINT FK_cmp_proveedor FOREIGN KEY (id_proveedor)
    REFERENCES PROVEEDOR (id_proveedor)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT FK_cmp_empleado  FOREIGN KEY (id_empleado)
    REFERENCES EMPLEADO (id_empleado)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT CHK_cmp_total    CHECK (total >= 0)
) ENGINE=InnoDB;

CREATE INDEX IDX_compra_fecha      ON COMPRA (fecha);
CREATE INDEX IDX_compra_proveedor  ON COMPRA (id_proveedor);


-- ============================================================
--  9. DETALLE_COMPRA
-- ============================================================
CREATE TABLE DETALLE_COMPRA (
  id_detalle      INT           NOT NULL AUTO_INCREMENT,
  id_compra       INT           NOT NULL,
  id_producto     INT           NOT NULL,
  cantidad        INT           NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal        DECIMAL(10,2) NOT NULL,
  CONSTRAINT PK_det_compra     PRIMARY KEY (id_detalle),
  CONSTRAINT FK_dc_compra      FOREIGN KEY (id_compra)
    REFERENCES COMPRA (id_compra)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT FK_dc_producto    FOREIGN KEY (id_producto)
    REFERENCES PRODUCTO (id_producto)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT CHK_dc_cantidad   CHECK (cantidad > 0)
) ENGINE=InnoDB;

CREATE INDEX IDX_dc_compra   ON DETALLE_COMPRA (id_compra);
CREATE INDEX IDX_dc_producto ON DETALLE_COMPRA (id_producto);


-- ============================================================
--  TRIGGERS
-- ============================================================

DELIMITER $$

-- Descuenta stock al confirmar una venta
CREATE TRIGGER trg_descontar_stock
AFTER INSERT ON DETALLE_VENTA
FOR EACH ROW
BEGIN
  UPDATE PRODUCTO
  SET    stock_actual = stock_actual - NEW.cantidad
  WHERE  id_producto  = NEW.id_producto;
END$$

-- Repone stock al recibir una compra
CREATE TRIGGER trg_reponer_stock
AFTER INSERT ON DETALLE_COMPRA
FOR EACH ROW
BEGIN
  UPDATE PRODUCTO
  SET    stock_actual  = stock_actual  + NEW.cantidad,
         precio_compra = NEW.precio_unitario
  WHERE  id_producto   = NEW.id_producto;
END$$

-- Restaura stock si se cancela una venta
CREATE TRIGGER trg_restaurar_stock_cancelacion
AFTER UPDATE ON VENTA
FOR EACH ROW
BEGIN
  IF NEW.estado = 'cancelada' AND OLD.estado = 'pagada' THEN
    UPDATE PRODUCTO p
    JOIN   DETALLE_VENTA dv ON dv.id_venta = NEW.id_venta
                           AND dv.id_producto = p.id_producto
    SET    p.stock_actual = p.stock_actual + dv.cantidad;
  END IF;
END$$

DELIMITER ;


-- ============================================================
--  DATOS DE PRUEBA
-- ============================================================

INSERT INTO CATEGORIA (nombre, descripcion) VALUES
  ('Útiles escolares',  'Cuadernos, lápices, colores y materiales para estudiantes'),
  ('Papelería fina',    'Agendas, plumas ejecutivas y artículos de escritorio premium'),
  ('Impresión y copias','Papel bond, tóner, cartuchos y suministros de impresión'),
  ('Arte y manualidades','Pinturas, pinceles, cartulinas y materiales creativos'),
  ('Tecnología',        'USB, cables, pilas y accesorios electrónicos básicos');

INSERT INTO PROVEEDOR (nombre, rfc, telefono, correo, direccion) VALUES
  ('Distribuidora Norteña S.A. de C.V.', 'DNO850312AB1', '6561234567', 'ventas@disnortena.com.mx', 'Av. Tecnológico 450, Cd. Juárez, Chih.'),
  ('Papeles y Más S. de R.L.',           'PMA920615CD3', '6569876543', 'pedidos@papelesymas.mx',   'Blvd. Independencia 1200, Cd. Juárez, Chih.'),
  ('Suministros Escolares del Norte',    'SEN001120EF5', '6561112233', 'contacto@sumesc.mx',       'Calle Fresno 88, Cd. Juárez, Chih.');

INSERT INTO EMPLEADO (nombre, puesto, turno, telefono, fecha_ingreso) VALUES
  ('María López Ramos',    'admin',   'matutino',   '6561110001', '2020-03-15'),
  ('Carlos Herrera Vega',  'cajero',  'matutino',   '6561110002', '2021-06-01'),
  ('Ana Flores Díaz',      'cajero',  'vespertino', '6561110003', '2022-01-10'),
  ('Luis Torres Méndez',   'almacen', 'matutino',   '6561110004', '2021-09-20');

INSERT INTO PRODUCTO (codigo_barras, nombre, descripcion, id_categoria, id_proveedor, precio_compra, precio_venta, stock_actual, stock_minimo) VALUES
  ('7501000001001', 'Cuaderno profesional 100 hojas',  'Pasta dura, cuadros 5mm',           1, 1,  18.00,  32.00, 120, 20),
  ('7501000001002', 'Lápiz No. 2 HB (caja 12 pzas)',  'Grafito suave, hexagonal',           1, 1,  22.00,  40.00,  85, 15),
  ('7501000001003', 'Colores Prismacolor 24 pzas',     'Mina gruesa, colores vivos',         1, 3,  95.00, 165.00,  30, 10),
  ('7501000002001', 'Agenda ejecutiva 2025',           'Pasta dura, semanal, 14x21 cm',     2, 2, 120.00, 220.00,  18,  5),
  ('7501000002002', 'Pluma gel 0.7 negra',             'Tinta negra de secado rápido',       2, 2,   8.00,  18.00, 200, 30),
  ('7501000003001', 'Papel bond carta 500 hojas',      'Blancura 95%, 75 g/m²',             3, 2,  65.00, 110.00,  60, 10),
  ('7501000003002', 'Cartucho tinta negra HP 664',     'Compatible HP Deskjet 2300/3700',   3, 1, 155.00, 260.00,  22,  8),
  ('7501000004001', 'Pintura vinílica 6 colores',      'No tóxica, lavable, 30 ml c/u',     4, 3,  45.00,  85.00,  40, 10),
  ('7501000004002', 'Cartulina de colores (paq 10)',   'Colores surtidos, 50x70 cm',        4, 3,  28.00,  52.00,  55, 15),
  ('7501000005001', 'Memoria USB 32 GB',               'USB 3.0, velocidad 80 MB/s',        5, 1,  90.00, 160.00,  35,  8),
  ('7501000005002', 'Pilas AA alcalinas (paq 4)',      'Duración extendida 1.5 V',          5, 2,  28.00,  52.00,  70, 20);

INSERT INTO CLIENTE (nombre, telefono, correo, fecha_registro, tipo) VALUES
  ('Escuela Primaria Benito Juárez', '6560001111', 'compras@primariabj.edu.mx', '2023-01-10', 'escuela'),
  ('Roberto Sánchez Olvera',         '6560002222', 'rsanchez@gmail.com',        '2023-04-22', 'frecuente'),
  ('Patricia Gutiérrez Luna',        '6560003333', NULL,                        '2024-02-14', 'general');

INSERT INTO VENTA (id_cliente, id_empleado, fecha, subtotal, iva, total, metodo_pago, estado) VALUES
  (1, 2, '2025-03-10 10:15:00', 1200.00, 192.00, 1392.00, 'transferencia', 'pagada'),
  (2, 2, '2025-03-11 11:30:00',  286.00,   0.00,  286.00, 'efectivo',      'pagada'),
  (3, 3, '2025-03-12 17:05:00',  162.00,   0.00,  162.00, 'tarjeta',       'pagada');

INSERT INTO DETALLE_VENTA (id_venta, id_producto, cantidad, precio_unitario, descuento, subtotal) VALUES
  (1, 1, 20,  32.00, 5.00,  608.00),
  (1, 6, 10, 110.00, 8.00, 1012.00),
  (2, 5, 10,  18.00, 0.00,  180.00),
  (2, 9,  2,  52.00, 0.00,  104.00),
  (3, 8,  1,  85.00, 0.00,   85.00),
  (3, 9,  1,  52.00, 0.00,   52.00),
  (3, 2,  1,  40.00, 0.00,   40.00);

INSERT INTO COMPRA (id_proveedor, id_empleado, fecha, folio_factura, total, estado) VALUES
  (1, 4, '2025-03-05 09:00:00', 'FAC-2025-0312', 3560.00, 'recibida'),
  (2, 4, '2025-03-07 10:30:00', 'FAC-NOR-0088',  2415.00, 'recibida');

INSERT INTO DETALLE_COMPRA (id_compra, id_producto, cantidad, precio_unitario, subtotal) VALUES
  (1, 1, 100, 18.00, 1800.00),
  (1, 7,  10,155.00, 1550.00),
  (1, 10, 23, 90.00, 2070.00),
  (2, 6,  15, 65.00,  975.00),
  (2, 5, 180,  8.00, 1440.00);


-- ============================================================
--  VISTAS ÚTILES
-- ============================================================

CREATE VIEW vista_stock_bajo AS
SELECT  p.id_producto,
        p.codigo_barras,
        p.nombre,
        c.nombre          AS categoria,
        p.stock_actual,
        p.stock_minimo,
        (p.stock_minimo - p.stock_actual) AS unidades_faltantes
FROM    PRODUCTO  p
JOIN    CATEGORIA c ON c.id_categoria = p.id_categoria
WHERE   p.stock_actual <= p.stock_minimo
  AND   p.activo = 1
ORDER BY unidades_faltantes DESC;

CREATE VIEW vista_ventas_resumen AS
SELECT  v.id_venta,
        v.fecha,
        COALESCE(cl.nombre, 'Venta mostrador') AS cliente,
        e.nombre     AS empleado,
        v.total,
        v.metodo_pago,
        v.estado,
        COUNT(dv.id_detalle)                   AS num_articulos
FROM    VENTA         v
LEFT  JOIN CLIENTE    cl ON cl.id_cliente  = v.id_cliente
JOIN       EMPLEADO   e  ON e.id_empleado  = v.id_empleado
JOIN       DETALLE_VENTA dv ON dv.id_venta = v.id_venta
GROUP BY v.id_venta;

CREATE VIEW vista_utilidad_producto AS
SELECT  p.id_producto,
        p.nombre,
        p.precio_compra,
        p.precio_venta,
        ROUND(p.precio_venta - p.precio_compra, 2)                         AS utilidad_unitaria,
        ROUND((p.precio_venta - p.precio_compra) / p.precio_venta * 100, 2) AS margen_pct
FROM    PRODUCTO p
WHERE   p.activo = 1
ORDER BY margen_pct DESC;
