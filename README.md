# Gestión de Cascos 🏍️

Base de datos MySQL para una tienda de venta de cascos de moto. Junta en un solo lugar el **stock**, los **clientes** y las **ventas**, y permite sacar reportes para saber qué reponer y quiénes son los mejores clientes.

## ¿De qué trata?

La tienda venía trabajando con anotaciones sueltas y sin un sistema centralizado. Eso traía problemas todos los días:

- No se sabía con exactitud cuántos cascos quedaban de cada modelo.
- Se perdía el registro de qué compraba cada cliente.
- No había forma rápida de saber qué marcas o modelos se vendían más para volver a pedirlos a los proveedores.

Este proyecto es la base de datos que resuelve eso.

## ¿Qué resuelve?

- **Stock al instante:** se puede consultar el stock disponible por marca, categoría, talle y color.
- **Historial de clientes:** guarda los datos de cada cliente y todas sus compras.
- **Registro detallado de ventas:** cada venta guarda qué cascos se llevaron, cuántas unidades y a qué precio.
- **Alertas de reposición:** muestra los cascos con menos de 5 unidades en stock.
- **Reportes:** ranking de mejores clientes, cascos más vendidos, ingresos por marca y por categoría (con porcentajes) y precios promedio por categoría.

## Estructura de la base

| Tabla | Qué guarda |
|---|---|
| `marcas` | Marcas de cascos y su país de origen |
| `categorias` | Tipos de casco (Integral, Modular, Cross) |
| `productos` | Cada casco: código, nombre, marca, categoría, talle, color, precio y stock |
| `clientes` | DNI, nombre, apellido, teléfono, email, ciudad y fecha de registro |
| `ventas` | Cada compra: cliente, fecha, total y estado (`pagada`, `pendiente`, `cancelada`) |
| `detalle_ventas` | Qué productos tiene cada venta, la cantidad y el precio unitario |

`detalle_ventas` resuelve la relación N:M entre ventas y productos: una venta puede tener varios cascos y un casco puede estar en varias ventas.

El modelo está normalizado hasta **3FN/BCNF**: los datos de una marca o categoría están en un solo lugar, así que si cambian se modifican una sola vez.

## Reglas y decisiones de diseño

- **Sin duplicados:** no puede haber dos clientes con el mismo DNI o email, dos productos con el mismo código, ni dos marcas o categorías con el mismo nombre.
- **Protección del historial:** no se puede borrar una marca, categoría o producto que ya tenga ventas (`ON DELETE RESTRICT`).
- **Validaciones automáticas:** la base rechaza precios negativos o en cero, cantidades inválidas y stock negativo (`CHECK`), así que no se puede vender más de lo que hay.
- **Transacciones seguras:** registrar una venta y descontar el stock se hace en una sola transacción. Si algo falla, se deshace todo.
- **Precio histórico:** el precio se guarda en `detalle_ventas` al momento de vender. Si después sube el precio del casco, las ventas viejas no cambian.
- **Ventas canceladas:** no descuentan stock.

## Vistas

| Vista | Para qué sirve |
|---|---|
| `vw_detalle_ventas` | Qué compró cada cliente: casco, marca, cantidad, precio y subtotal |
| `vw_stock_bajo` | Cascos con menos de 5 unidades (qué hay que reponer) |
| `vw_clientes_frecuentes` | Ranking de clientes por total gastado en compras pagadas |
| `vw_top_cascos` | Cascos más vendidos e ingresos que generaron |

## Consultas destacadas

**Historial completo de compras**
```sql
select * from vw_detalle_ventas;
```

**Cascos que se están agotando**
```sql
select * from vw_stock_bajo;
```

**Ranking de mejores clientes**
```sql
select * from vw_clientes_frecuentes;
```

**Categorías con precio promedio mayor a $200.000 (HAVING)**
```sql
select
    cat.nombre as categoria,
    round(avg(p.precio_venta), 2) as precio_promedio
from productos p
join categorias cat on cat.id_categoria = p.id_categoria
group by cat.id_categoria, cat.nombre
having avg(p.precio_venta) > 200000;
```

| categoria | precio_promedio |
|---|---|
| Cross | 215000.00 |
| Integral | 206640.00 |

**Porcentaje de ingresos por marca (CTE)**
```sql
with ingresos_por_marca as (
    select
        m.nombre as marca,
        sum(d.cantidad * d.precio_unitario) as ingresos
    from detalle_ventas d
    join ventas v    on v.id_venta    = d.id_venta
    join productos p on p.id_producto = d.id_producto
    join marcas m    on m.id_marca    = p.id_marca
    where v.estado = 'pagada'
    group by m.nombre
)
select
    marca,
    ingresos,
    round(ingresos * 100 / (select sum(ingresos) from ingresos_por_marca), 2) as porcentaje_del_total
from ingresos_por_marca
order by ingresos desc;
```

El script también incluye consultas con `AVG`, `MIN`, `MAX`, `COUNT`, `IN`, `EXISTS` / `NOT EXISTS`, ventas del último mes e ingresos por categoría.

## Cómo usarla

1. Abrir MySQL Workbench (o cualquier cliente MySQL 8+).
2. Ejecutar el script [`sql/gestion_cascos.sql`](sql/gestion_cascos.sql).

El script crea la base `gestion_cascos` desde cero, carga datos de ejemplo (marcas, categorías, cascos, clientes y ventas), crea las vistas y corre las consultas de ejemplo.

> ⚠️ El script empieza con `drop database if exists gestion_cascos`, así que borra la base si ya existía.
