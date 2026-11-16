drop database if exists gestion_cascos;
create database if not exists gestion_cascos;
use gestion_cascos;
-- Tabla marcas: las marcas y su pais de orig
CREATE TABLE marcas (
	id_marca INT auto_increment primary KEY,
    nombre varchar(80) not null unique,
    pais_origen varchar(60)
);
-- Tabla categorias: tipo de cascos
create table categorias (
	id_categoria int auto_increment primary key,
    nombre varchar(60) not null unique,
    descripcion varchar(255)
);
-- Tabla productos: los cascos que se venden
create table productos (
	id_producto int auto_increment primary key,
    codigo varchar(30) not null unique,
    nombre varchar(100) not null,
    id_marca int not null,
    id_categoria int not null,
    talle varchar(10) not null,
    color varchar(40),
    precio_venta decimal(10,2) not null check (precio_venta > 0),
    stock int not null default 0 check (stock >= 0),
	
    foreign key (id_marca) references marcas(id_marca)
		on update cascade
        on delete restrict,
	foreign key (id_categoria) references categorias(id_categoria)
		on update cascade
        on delete restrict
);
-- Tabla clientes: personas que compran cascos
create table clientes (
	id_cliente int auto_increment primary key,
    dni varchar(15) not null unique,
    nombre varchar(80) not null,
    apellido varchar(80) not null,
    telefono varchar(20),
    email varchar(120) unique, 
    ciudad varchar (80),
    fecha_registro date not null default (current_date())
);
-- Tabla ventas: cada compra realizada
create table ventas(
	id_venta int auto_increment primary key,
    fecha_venta datetime not null default current_timestamp,
    id_cliente int not null,
    total decimal(12,2) not null default 0,
    estado enum('pendiente','pagada','cancelada') not null default 'pagada',
    foreign key (id_cliente) references clientes(id_cliente)
		on update cascade
        on delete restrict
);
-- Tabla detalle_ventas: que cascos, cuantos y a que precio
create table detalle_ventas (
	id_detalle int auto_increment primary key,
    id_venta int not null,
    id_producto int not null,
    cantidad int not null check (cantidad > 0),
    precio_unitario decimal(10,2) not null,
    foreign key(id_venta) references ventas(id_venta)
		on update cascade
        on delete cascade,
	foreign key (id_producto) references productos(id_producto)
		on update cascade
        on delete restrict
);
create index idx_producto_nombre ON productos(nombre);
create index idx_venta_fecha ON ventas(fecha_venta);
-- Marcas
insert into marcas (nombre, pais_origen) values
('HRO', 'Colombia'),
('LS2', 'España'),
('AXOR', 'Italia'),
('FXX', 'Argentina'),
('AXXIS', 'España'),
('SHAFT', 'Colombia'),
('PROTORK', 'Brasil');
-- Categorias
insert into categorias (nombre, descripcion) values
('Integral', 'cobertura completa, maxima proteccion y aerodinamica'),
('Modular', 'barbilla abatible, versatil para ciudad y viaje'),
('Cross', 'diseño para motocross, uso con gafas');
-- Productos (Cascos)
insert into productos (codigo, nombre, id_marca, id_categoria, talle, color, precio_venta, stock) values
('CAS-HRO-112', 'HRO Modular 112', 1, 2,'M', 'Fucsia', 181000.00, 5),
('CAS-HRO-196', 'HRO Integral 196', 1, 1,'S', 'Negro', 199000.00, 3),
('CAS-LS2-FUS', 'LS2 Integral Fusion', 2, 1, 'XL', 'Negro/gris', 295000.00, 1),
('CAS-LS2-COS', 'LS2 Integral Cosmos', 2, 1, 'M', 'Rosa', 289000.00, 10),
('CAS-AXOR-IN', 'AXOR Integral Aleron', 3, 1, 'XL', 'Rojo', 270400.00, 2),
('CAS-FXX-BR', 'FXX Integral BR', 4, 1, 'XL', 'Verde', 165000.00, 1),
('CAS-FXX-JK', 'FXX Integral Joker', 4, 1, 'L', 'Blanco', 165000.00, 2),
('CAS-FXX-AZ', 'FXX Cross', 4, 3, 'XL', 'Azul', 215000.00, 2),
('CAS-AXX-BL', 'AXXIS Integral Blanco', 5, 1, 'XL', 'Blanco', 135000.00, 1),
('CAS-AXX-GR', 'AXXIS Integral Gris', 5, 1, 'L', 'Gris', 135000.00, 1),
('CAS-SHFT-PRO', 'SHAFT Integral Pro', 6, 1, 'S', 'Negro Mate', 215000.00, 1),
('CAS-SHFT-134', 'SHAFT Integral Dientes', 6, 1, 'M', 'Lila', 198000.00, 1),
('CAS-PRT-BR', 'PROTORK Modular Brasil', 7, 2, 'S', 'Verde', 95000.00, 3),
('CAS-PRT-RS', 'PROTORK Modular Rosas', 7, 2, 'S', 'Rosa', 95000.00, 2);
-- Clientes
insert into clientes (dni, nombre, apellido, telefono, email, ciudad) values
(12344567, 'Benjamin', 'Ruiz', 3855967790, 'benja123@email.com', 'Santiago del Estero'),
(23467899, 'Sofia', 'Ruiz', 3854906980, 'sofy0909@email.com', 'Santiago del Estero'),
(89556623, 'Luana', 'Guzman', 3855967085, 'luana080@email.com', 'Santiago del Estero'),
(89663511, 'Lautaro', 'Pereyra', 3854875632, 'lp0203@email.com', 'La Banda');
-- Ventas
insert into ventas (id_cliente, total, estado) values
(1, 0, 'pagada'),
(2, 0, 'pagada'),
(1, 0, 'pendiente');
-- Detalle de las ventas
insert into detalle_ventas (id_venta, id_producto, cantidad, precio_unitario) values
(1, 3, 1, 295000.00),
(2, 4, 1, 289000.00),
(3, 1, 1, 181000.00);
-- crear una venta cancelada para poder borrarla
insert into ventas(id_cliente, total, estado) values
(4, 0, 'cancelada');
-- recalcular totales de todas las ventas
update ventas v
set total = (
	select ifnull(sum(cantidad * precio_unitario), 0)
    from detalle_ventas d
    where d.id_venta = v.id_venta
) 
where v.id_venta > 0;

update productos p 
set p.stock = p.stock - (
	select ifnull(sum(d.cantidad), 0)
    from detalle_ventas d
    join ventas v on v.id_venta = d.id_venta
    where d.id_producto = p.id_producto
    and v.estado = 'pagada'
)
where p.id_producto > 0;
-- vista 1: detalle completo de cada venta
create view vw_detalle_ventas as
select 
    v.id_venta,
    v.fecha_venta,
    concat(c.nombre, ' ', c.apellido) as cliente,
    p.nombre as casco,
    m.nombre as marca,
    d.cantidad,
    d.precio_unitario,
    (d.cantidad * d.precio_unitario) as subtotal,
    v.estado
from ventas v
join clientes c       on c.id_cliente   = v.id_cliente
join detalle_ventas d on d.id_venta     = v.id_venta
join productos p      on p.id_producto  = d.id_producto
join marcas m         on m.id_marca     = p.id_marca;
-- vista 2: cascos con stock bajo (menos de 5 unidades)
create view vw_stock_bajo as
select codigo, nombre, talle, stock, precio_venta
from productos
where stock < 5
order by stock asc;
-- vista 3: total gastado por cada cliente
create view vw_clientes_frecuentes as
select 
    c.dni,
    concat(c.nombre, ' ', c.apellido) as cliente,
    count(v.id_venta) as compras_realizadas,
    coalesce(sum(v.total), 0) as total_gastado
from clientes c
left join ventas v on v.id_cliente = c.id_cliente and v.estado = 'pagada'
group by c.id_cliente, c.dni, c.nombre, c.apellido
order by total_gastado desc;
-- vista 4: cascos más vendidos
create view vw_top_cascos as
select 
    p.codigo,
    p.nombre as casco,
    m.nombre as marca,
    sum(d.cantidad) as unidades_vendidas,
    sum(d.cantidad * d.precio_unitario) as ingresos
from detalle_ventas d
join productos p on p.id_producto = d.id_producto
join marcas m    on m.id_marca    = p.id_marca
group by p.id_producto, p.codigo, p.nombre, m.nombre
order by unidades_vendidas desc;
-- que compro cada cliente
select * from vw_detalle_ventas;
-- que cascos necesitan reposicion
select * from vw_stock_bajo;
-- quienes son nuestros mejores clientes
select * from vw_clientes_frecuentes;
-- cual es el casco mas vendido
select * from vw_top_cascos limit 5;
-- ventas realizadas en el ultimo mes
select
	v.id_venta,
    v.fecha_venta,
    concat(c.nombre, ' ', c.apellido) as cliente,
    v.total,
    v.estado
from ventas v
join clientes c on c.id_cliente = v.id_cliente
where v.fecha_venta >= date_sub(current_date, interval 1 month)
order by v.fecha_venta desc;
-- ingresos totales por categoria de casco
select
	cat.nombre as categoria,
    sum(d.cantidad * d.precio_unitario) as ingresos_totales
from detalle_ventas d
join productos p on p.id_producto = d.id_producto
join categorias cat on cat.id_categoria = p.id_categoria
group by cat.nombre
order by ingresos_totales desc;
-- registrar una venta nueva (ejemplo de insert con transaccion)
-- una transaction agrupa varios pasos: o se aplican todos o ninguno
start transaction;
insert into ventas (id_cliente, total, estado) values (3, 0, 'pagada');
-- supongamos que el id de la venta anterior es el siguiente disponible:
set @nueva_venta = last_insert_id(); -- guarda el id recien creado
insert into detalle_ventas (id_venta, id_producto, cantidad, precio_unitario)
values (@nueva_venta, 4, 1, 289000.00);
update ventas
set total = (select sum(cantidad * precio_unitario) from detalle_ventas where id_venta = @nueva_venta)
where id_venta = @nueva_venta;

update productos
set stock = stock - 1
where id_producto = 4;

commit; -- confirma los cambios. si algo fallara, seria rollback;

-- funciones de agregacion: avg, min, max y count
-- promedio precio de los cascos segun la categoria
select
	cat.nombre as categoria,
    round(avg(p.precio_venta), 2) as precio_promedio,
    min(p.precio_venta) as precio_minimo,
    max(p.precio_venta) as precio_maximo,
    count(*) as modelos_disponibles
from productos p
join categorias cat on cat.id_categoria = p.id_categoria
group by cat.id_categoria, cat.nombre
order by precio_promedio desc;

-- having filtra despues de agrupar
-- where filtra antes de agrupar
-- que categoria tiene precio promedio mayor a 200000
select
	cat.nombre as categoria,
    round(avg(p.precio_venta), 2) as precio_promedio
from productos p
join categorias cat on cat.id_categoria = p.id_categoria
group by cat.id_categoria, cat.nombre
having avg(p.precio_venta) > 200000;

-- having mas count, clientes con mas de una compra pagada
select 
	concat(c.nombre, ' ', c.apellido) as cliente,
    count(v.id_venta) as compras_realizadas
from clientes c 
join ventas v on v.id_cliente = c.id_cliente
where v.estado = 'pagada'
group by c.id_cliente, c.nombre, c.apellido
having count(v.id_venta) > 1;

-- in filtra perteneciento a un conjunto
-- que cascos son de marcas de origen italiano o español
select
	p.nombre as casco,
    m.nombre as marca,
    m.pais_origen,
    p.precio_venta
from productos p 
join marcas m on m.id_marca = p.id_marca
where m.pais_origen in ('Italia', 'España')
order by p.precio_venta desc;

-- in con subconsulta de clientes que compraron cascos integrales
select
	concat(c.nombre, ' ', c.apellido) as cliente
from clientes c 
where c.id_cliente in (
	select distinct v.id_cliente
    from ventas v
    join detalle_ventas d on d.id_venta = v.id_venta
    join productos p on p.id_producto = d.id_producto
    join categorias cat on cat.id_categoria = p.id_categoria
    where cat.nombre = 'Integral'
	and v.estado = 'pagada'
);

-- que clientes compraron al menos un casco
select
	concat(c.nombre, ' ', c.apellido) as cliente
from clientes c
where exists (
	select 1
    from ventas v
    where v.id_cliente = c.id_cliente
    and v.estado = 'pagada'
);

-- clientes que estan registrados pero que nunca compraron
select
	concat(c.nombre, ' ', c.apellido) as cliente,
    c.ciudad
from clientes c
where not exists(
	select 1
    from ventas v
    where v.id_cliente = c.id_cliente
    and v.estado = 'pagada'
);

-- que porcentaje de los ingresos representa cada marca
with ingresos_por_marca as(
	select
		m.nombre as marca,
        sum(d.cantidad * d.precio_unitario) as ingresos
	from detalle_ventas d
    join ventas v on v.id_venta = d.id_venta
    join productos p on p.id_producto = d.id_producto
    join marcas m on m.id_marca = p.id_marca
    where v.estado = 'pagada'
    group by m.nombre
)
select
	marca,
    ingresos,
    round(ingresos * 100 / (select sum(ingresos) from ingresos_por_marca), 2) as porcentaje_del_total
from ingresos_por_marca
order by ingresos desc;

-- borramos la venta cancelada
delete from ventas
where estado = 'cancelada'
and id_venta > 0;

