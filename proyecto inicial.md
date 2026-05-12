Actúa como un administrador de base de datos: proyecto Papelería Cometa, que entidades se necesitan para su gestión.

Para la **Papelería Cometa** necesitamos modelar las entidades que reflejen el ciclo completo del negocio: compras, inventario, ventas y gestión interna. Aquí están las entidades principales y sus relaciones:
<img width="1440" height="568" alt="image" src="https://github.com/user-attachments/assets/1d726412-67ad-4c80-a0f5-489858214021" />

Las **10 entidades** del modelo son:

**Núcleo del inventario**
- `PRODUCTO` — corazón del sistema; guarda código de barras, precios y los dos niveles de stock (actual y mínimo para alertas de reabastecimiento)
- `CATEGORIA` — agrupa productos: útiles escolares, papelería fina, impresión, tecnología, etc.
- `PROVEEDOR` — datos fiscales y de contacto de cada distribuidor

**Ciclo de ventas**
- `CLIENTE` — registro opcional; permite historial y crédito a clientes frecuentes
- `EMPLEADO` — controla quién realizó cada venta o compra (trazabilidad y comisiones)
- `VENTA` — encabezado con fecha, total y método de pago
- `DETALLE_VENTA` — línea por producto vendido; guarda el precio en el momento exacto de la venta

**Ciclo de compras**
- `COMPRA` — orden de entrada de mercancía desde un proveedor
- `DETALLE_COMPRA` — línea por producto recibido con el precio pactado

**Relaciones clave a destacar:**

| Relación | Cardinalidad | Motivo |
|---|---|---|
| Producto → Detalle venta | 1 a muchos | Un producto puede venderse en múltiples ventas |
| Venta → Detalle venta | 1 a muchos | Una venta puede tener varios productos |
| Producto → Proveedor | muchos a 1 | Proveedor principal por producto |
| Empleado → Venta / Compra | 1 a muchos | Auditoría de quién operó |

¿Quieres que avancemos al siguiente paso: definir las reglas de negocio (triggers de stock mínimo, cálculo de utilidad, etc.) o prefieres que genere el script DDL para MySQL/PostgreSQL?

Las entidades con sus atributos y tipo en forma de tabla para cada una de las entidades

<img width="732" height="480" alt="image" src="https://github.com/user-attachments/assets/5aef0697-4985-41d4-ad1f-8e7da4035c84" />
<img width="736" height="545" alt="image" src="https://github.com/user-attachments/assets/70310c70-c816-4400-bc64-5881b0e2c949" />
<img width="741" height="658" alt="image" src="https://github.com/user-attachments/assets/abc025c9-47d0-4568-97bb-34948d8a7f2a" />
<img width="677" height="698" alt="image" src="https://github.com/user-attachments/assets/03754ec1-f6bd-46ae-85fb-e7a1e6b695f1" />
<img width="747" height="656" alt="image" src="https://github.com/user-attachments/assets/aaccf5cb-9b3f-44cc-888f-5b40424384f2" />

Algunas decisiones de diseño que vale la pena destacar:

`id_cliente` en VENTA acepta `NULL` para permitir ventas de mostrador sin registrar al cliente, algo muy común en papelerías.

`precio_unitario` se guarda en `DETALLE_VENTA` independientemente del precio actual del producto — así el historial no se altera si el precio cambia después.

`DECIMAL(10,2)` en todos los montos evita errores de redondeo que ocurren con `FLOAT`.

`ENUM` en `metodo_pago`, `estado` y `puesto` restringe los valores válidos directamente en la base de datos, sin depender solo de la aplicación.

¿Quieres que continuemos con el script DDL en MySQL, las reglas de negocio (triggers de stock mínimo, cálculo de utilidad) o el diseño de vistas y reportes?

De acuerdo a tu respuesta anterior puedes generar un script SQL para descargar con el nombre de bdpapeleriacometa.sql para las entidades con sus relaciones

Script SQL completo para Papelería Cometa con todas las entidades, relaciones, índices y datos de prueba
