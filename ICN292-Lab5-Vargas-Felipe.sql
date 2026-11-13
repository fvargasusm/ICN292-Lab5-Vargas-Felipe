DROP DATABASE IF EXISTS andesbike;
CREATE DATABASE andesbike;
USE andesbike;

CREATE TABLE tiendas (
    id_tienda INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    comuna VARCHAR(50) NOT NULL
);

CREATE TABLE bicicletas (
    id_bicicleta INT PRIMARY KEY AUTO_INCREMENT,
    modelo VARCHAR(60) UNIQUE NOT NULL,
    categoria ENUM('Eléctrica', 'Infantil', 'Montaña', 'Ruta', 'Urbana') NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    CHECK (precio > 0)
);

CREATE TABLE vendedores (
    id_vendedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    id_tienda INT,
    fecha_ingreso DATE NOT NULL,
    FOREIGN KEY (id_tienda) REFERENCES tiendas(id_tienda)
);

CREATE TABLE ventas (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_vendedor INT NOT NULL,
    id_bicicleta INT NOT NULL,
    fecha DATE NOT NULL,
    unidades INT NOT NULL, 
    FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor),
    FOREIGN KEY (id_bicicleta) REFERENCES bicicletas(id_bicicleta),
    CHECK (unidades > 0)
);

INSERT INTO tiendas (id_tienda, nombre, comuna) VALUES
(1, 'Andes Providencia', 'Providencia'),
(2, 'Andes Maipú', 'Maipú'),
(3, 'Andes Concepción', 'Concepción'),
(4, 'Andes La Serena', 'La Serena');

INSERT INTO vendedores (id_vendedor, nombre, id_tienda, fecha_ingreso) VALUES
(1, 'Camila Ortiz', 1, '2024-06-20'),
(2, 'Diego Fuentes', 1, '2024-01-15'),
(3, 'Javiera Soto', 2, '2023-07-24'),
(4, 'Matías Herrera', 2, '2024-01-15'),
(5, 'Paula Riquelme', 3, '2022-11-02'),
(6, 'Ignacio Vera', 3, '2024-08-19'),
(7, 'Fernanda Lillo', 1, '2025-02-03'),
(8, 'Rubén Castro', NULL, '2025-06-10');

INSERT INTO bicicletas (id_bicicleta, modelo, categoria, precio) VALUES
(1, 'Cordillera 29', 'Montaña', 549990.00),
(2, 'Ruta Austral', 'Ruta', 899990.00),
(3, 'Urbana Pro', 'Urbana', 329990.00),
(4, 'Pequeño Andes', 'Infantil', 149990.00),
(5, 'Volt City', 'Eléctrica', 1249990.00),
(6, 'Trail Master', 'Montaña', 749990.00),
(7, 'Urbana Lite', 'Urbana', 229990.00),
(8, 'Sprint R7', 'Ruta', 1099990.00);

INSERT INTO ventas (id_vendedor, id_bicicleta, fecha, unidades) VALUES
(1, 1, '2025-03-04', 2),
(1, 3, '2025-03-18', 1),
(1,	5,	'2025-04-02', 1),
(2,	2,	'2025-03-04', 1),
(2,	1,	'2025-04-11', 3),
(2,	7,	'2025-05-06', 2),
(3,	4,	'2025-03-21', 4),
(3,	3,	'2025-04-15', 2),
(3,	6,	'2025-05-20', 1),
(4,	1,	'2025-03-27', 1),
(4,	5,	'2025-05-09', 2),
(5,	2,	'2025-04-08', 1),
(5,	6,	'2025-04-23', 2),
(5,	4,	'2025-06-02', 5),
(6,	3,	'2025-05-13', 3),
(6,	7,	'2025-06-17', 1),
(6,	1,	'2025-06-24', 2),
(1,	6,	'2025-06-30', 1);

-- Consulta 1

SELECT nombre, COUNT(ventas.id_venta) AS cantidad_ventas FROM vendedores
LEFT JOIN ventas ON vendedores.id_vendedor = ventas.id_vendedor 
GROUP BY nombre, vendedores.id_vendedor 
ORDER BY cantidad_ventas DESC,
nombre ASC;

-- Consulta 2 

SELECT tiendas.nombre, COUNT(ventas.id_venta) AS cantidad_ventas, IFNULL(SUM(unidades),0) AS total_unidades FROM tiendas
LEFT JOIN vendedores ON tiendas.id_tienda = vendedores.id_tienda 
LEFT JOIN ventas ON vendedores.id_vendedor = ventas.id_vendedor
GROUP BY tiendas.id_tienda, tiendas.nombre
ORDER BY total_unidades DESC;

-- Consulta 3

SELECT tiendas.nombre, tiendas.comuna FROM tiendas
LEFT JOIN vendedores ON tiendas.id_tienda = vendedores.id_tienda 
WHERE vendedores.id_vendedor IS NULL; 

-- Consulta 4

SELECT bicicletas.modelo FROM bicicletas
LEFT JOIN ventas ON bicicletas.id_bicicleta = ventas.id_bicicleta AND ventas.fecha BETWEEN '2025-06-01' AND '2025-06-30'
WHERE ventas.id_venta IS NULL; 

-- Consulta 5

SELECT tiendas.nombre AS nombre_tienda, vendedores.nombre AS nombre_vendedor FROM vendedores
LEFT JOIN tiendas ON vendedores.id_tienda = tiendas.id_tienda 
LEFT JOIN ventas ON vendedores.id_vendedor = ventas.id_vendedor
WHERE ventas.id_venta IS NULL ;

-- Consulta 6 

SELECT tiendas.nombre AS tienda, v1.nombre AS vendedor_1, v1.fecha_ingreso AS fecha_ingreso_1, v2.nombre AS vendedor_2, v2.fecha_ingreso AS fecha_ingreso_2 FROM vendedores v1
JOIN vendedores v2 ON v1.id_tienda = v2.id_tienda
JOIN tiendas ON tiendas.id_tienda = v1.id_tienda
WHERE v1.fecha_ingreso < v2.fecha_ingreso;

-- Consulta 7

SELECT tiendas.nombre AS tienda, SUM(ventas.unidades * bicicletas.precio) AS monto_total FROM tiendas
JOIN vendedores ON tiendas.id_tienda = vendedores.id_tienda
JOIN ventas ON vendedores.id_vendedor = ventas.id_vendedor
JOIN bicicletas ON ventas.id_bicicleta = bicicletas.id_bicicleta
WHERE bicicletas.categoria IN ('Montaña', 'Ruta')
GROUP BY tiendas.id_tienda, tiendas.nombre
HAVING monto_total > 2000000
ORDER BY monto_total DESC;

-- Consulta 8 

SELECT modelo, precio FROM bicicletas
WHERE precio > (SELECT AVG(precio) FROM bicicletas)
ORDER BY precio DESC;


-- Consulta 9 

SELECT vendedores.nombre, AVG(ventas.unidades) AS promedio_unidades FROM vendedores
JOIN ventas ON vendedores.id_vendedor = ventas.id_vendedor
GROUP BY vendedores.id_vendedor, vendedores.nombre
HAVING promedio_unidades > (SELECT AVG(unidades) FROM ventas)
ORDER BY promedio_unidades DESC, vendedores.nombre ASC;

-- Consulta 10 

SELECT vendedores.nombre, SUM(ventas.unidades * bicicletas.precio) AS monto_total FROM vendedores
LEFT JOIN ventas ON vendedores.id_vendedor = ventas.id_vendedor
LEFT JOIN bicicletas ON ventas.id_bicicleta = bicicletas.id_bicicleta
GROUP BY vendedores.id_vendedor, vendedores.nombre
ORDER BY monto_total DESC, vendedores.nombre ASC;


















