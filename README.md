<div align="center">

# 🏍️ Gestión de Cascos

**Base de datos relacional para administrar el stock, los clientes y las ventas de una tienda de cascos de moto.**

![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Script-CC2927?style=for-the-badge&logo=databricks&logoColor=white)
![Normalización](https://img.shields.io/badge/Normalizada-3FN%20%2F%20BCNF-2EA44F?style=for-the-badge)

[¿De qué trata?](#-de-qué-trata) •
[¿Qué resuelve?](#-qué-resuelve) •
[Inicio rápido](#-inicio-rápido) •
[Modelo de datos](#-modelo-de-datos) •
[Reportes](#-reportes-incluidos) •
[Decisiones de diseño](#-decisiones-de-diseño)

</div>

---

## 📖 ¿De qué trata?

Una tienda de cascos y accesorios llevaba todo en **anotaciones sueltas**, sin un sistema centralizado. En el día a día eso significaba:

| ❌ Antes | ✅ Con esta base de datos |
|---|---|
| No se sabía cuántos cascos quedaban de cada modelo | Stock al instante por marca, categoría, talle y color |
| Se perdía qué había comprado cada cliente | Historial completo de compras por cliente |
| Las ventas se anotaban sin detalle | Cada venta guarda qué cascos, cuántos y a qué precio |
| Reponer stock era a ojo | Alerta automática de cascos con menos de 5 unidades |
| No se sabía qué se vendía más | Rankings de cascos, clientes, marcas y categorías |

Este proyecto es la base de datos que reúne **stock, clientes y ventas en un solo lugar** y responde las preguntas que el negocio necesita para decidir.

## 🎯 ¿Qué resuelve?

- 📦 **Inventario** — catálogo de cascos con código, marca, categoría, talle, color, precio y stock.
- 👥 **Clientes** — datos de contacto y todo su historial de compras.
- 🧾 **Ventas** — comprobantes con estado (`pagada`, `pendiente`, `cancelada`) y el detalle de cada producto vendido.
- 🔔 **Reposición** — una vista lista los modelos que se están agotando.
- 📊 **Reportes** — mejores clientes, cascos más vendidos, ingresos por marca y por categoría (con porcentajes) y precios promedio.
- 🛡️ **Datos confiables** — validaciones, claves únicas y transacciones para que la información no se rompa.

## 🚀 Inicio rápido

**Requisitos:** MySQL 8.0 o superior (por ejemplo con MySQL Workbench).

```bash
git clone https://github.com/huertocostas/gestion-cascos.git
cd gestion-cascos
mysql -u root -p < sql/gestion_cascos.sql
```

O desde **MySQL Workbench**: abrir [`sql/gestion_cascos.sql`](sql/gestion_cascos.sql) y ejecutar todo el script (⚡).

El script, en orden:

1. Crea la base `gestion_cascos` desde cero.
2. Crea las 6 tablas con sus claves, restricciones e índices.
3. Carga datos de ejemplo: 7 marcas, 3 categorías, 14 cascos, 4 clientes y varias ventas.
4. Crea 4 vistas de reportes.
5. Corre las consultas de ejemplo y una venta dentro de una transacción.

> [!WARNING]
> El script empieza con `DROP DATABASE IF EXISTS gestion_cascos`: si ya tenías esa base, se borra.

Después probá, por ejemplo:

```sql
use gestion_cascos;
select * from vw_stock_bajo;           -- qué hay que reponer
select * from vw_clientes_frecuentes;  -- quiénes son los mejores clientes
```

## 🗂️ Modelo de datos

```
gestion-cascos/
├── README.md
└── sql/
    └── gestion_cascos.sql   ← tablas, datos de ejemplo, vistas y consultas
```

| Tabla | Qué guarda | Claves |
|---|---|---|
| `marcas` | Marcas y país de origen | `nombre` único |
| `categorias` | Tipos de casco: Integral, Modular, Cross | `nombre` único |
| `productos` | Cada casco: código, nombre, talle, color, precio y stock | `codigo` único · FK a marca y categoría |
| `clientes` | DNI, nombre, apellido, teléfono, email, ciudad y fecha de registro | `dni` y `email` únicos |
| `ventas` | Cliente, fecha, total y estado de cada compra | FK a cliente |
| `detalle_ventas` | Productos de cada venta, cantidad y precio unitario | FK a venta y producto |

Las relaciones:

- Una **marca** y una **categoría** tienen muchos productos.
- Un **cliente** hace muchas ventas.
- **Ventas ↔ productos** es N:M: una venta puede tener varios cascos y un casco puede aparecer en muchas ventas. Se resuelve con `detalle_ventas`, que además guarda la cantidad y el precio de ese momento.

El modelo está normalizado hasta **3FN / BCNF**: los datos de una marca o categoría viven en un solo lugar, así que si cambian se actualizan una sola vez.

## 📊 Reportes incluidos

### Vistas listas para usar

| Vista | Responde a |
|---|---|
| `vw_detalle_ventas` | ¿Qué compró cada cliente, de qué marca, cuántos y a qué precio? |
| `vw_stock_bajo` | ¿Qué cascos tienen menos de 5 unidades? |
| `vw_clientes_frecuentes` | ¿Quiénes gastaron más en compras pagadas? |
| `vw_top_cascos` | ¿Cuáles son los cascos más vendidos y cuánto facturaron? |

### Ejemplos de resultados

**🔔 Cascos que se están agotando** — `select * from vw_stock_bajo;`

| codigo | nombre | talle | stock | precio_venta |
|---|---|---|---|---|
| CAS-LS2-FUS | LS2 Integral Fusion | XL | 0 | 295000.00 |
| CAS-FXX-BR | FXX Integral BR | XL | 1 | 165000.00 |
| CAS-AXX-BL | AXXIS Integral Blanco | XL | 1 | 135000.00 |
| … | … | … | … | … |

**👑 Ranking de clientes** — `select * from vw_clientes_frecuentes;`

| dni | cliente | compras_realizadas | total_gastado |
|---|---|---|---|
| 12344567 | Benjamin Ruiz | 1 | 295000.00 |
| 23467899 | Sofia Ruiz | 1 | 289000.00 |
| 89556623 | Luana Guzman | 1 | 289000.00 |
| 89663511 | Lautaro Pereyra | 0 | 0.00 |

### Más consultas

<details>
<summary><b>💰 Categorías con precio promedio mayor a $200.000</b> (<code>GROUP BY</code> + <code>HAVING</code>)</summary>

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

</details>

<details>
<summary><b>📈 Porcentaje de ingresos por marca</b> (CTE con <code>WITH</code>)</summary>

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

</details>

<details>
<summary><b>🧩 Conceptos de SQL que se ven en el script</b></summary>


| Tema | Dónde se usa |
|---|---|
| `JOIN` de varias tablas | Detalle de ventas, ingresos por categoría |
| `GROUP BY` + `HAVING` | Categorías caras, clientes con más de una compra |
| `AVG`, `MIN`, `MAX`, `COUNT` | Precios por categoría |
| `IN` (con lista y con subconsulta) | Cascos de marcas italianas o españolas, clientes que compraron integrales |
| `EXISTS` / `NOT EXISTS` | Clientes que compraron y clientes que nunca compraron |
| CTE (`WITH`) | Porcentaje de ingresos por marca |
| Vistas (`CREATE VIEW`) | Los 4 reportes principales |
| Transacciones | Registrar una venta y descontar stock juntos |
| Funciones de fecha | Ventas del último mes |

</details>

## 🧠 Decisiones de diseño

- 🔑 **Sin duplicados** — no puede haber dos clientes con el mismo DNI o email, dos productos con el mismo código, ni dos marcas o categorías con el mismo nombre.
- 🛡️ **El historial no se pierde** — no se puede borrar una marca, categoría o producto que ya tenga ventas (`ON DELETE RESTRICT`). Si se borra una venta, su detalle se borra con ella (`ON DELETE CASCADE`).
- ✅ **Validaciones automáticas** — `CHECK` rechaza precios de cero o negativos, cantidades inválidas y stock negativo, así que no se puede vender más de lo que hay.
- 🔄 **Transacciones seguras** — la venta, su detalle, el total y el descuento de stock se hacen en un solo bloque (`START TRANSACTION … COMMIT`). Si algo falla, no queda nada a medias.
- 🏷️ **Precio histórico** — el precio se guarda en `detalle_ventas` al momento de vender. Si después sube el precio del casco, las ventas viejas no cambian.
- 🚫 **Ventas canceladas** — no descuentan stock.
- ⚡ **Índices** — sobre el nombre del producto y la fecha de venta, para que las búsquedas y los reportes por fecha sean más rápidos.

## 🛣️ Ideas para seguir

¿Te interesa el proyecto? Algunas mejoras posibles:

- [ ] Triggers que descuenten stock y recalculen el total automáticamente al registrar una venta.
- [ ] Procedimiento almacenado `registrar_venta` que valide el stock antes de vender.
- [ ] Tabla de proveedores y órdenes de compra para la reposición.
- [ ] Usuarios y permisos distintos para vendedor y administrador.
- [ ] Una app web o de escritorio que use esta base.

Los issues y pull requests son bienvenidos. 🙌
