# Proyecto: Carrito de compras para el cafetín del SENA

---

## 1. Planteamiento del problema
Actualmente, el cafetín presenta dificultades en la gestión de pedidos debido a que el proceso se realiza de forma manual, lo que genera largas filas, demoras en la atención y posibles errores en la toma y entrega de pedidos. Esta situación afecta la experiencia del cliente o inconformidad en los usuarios.

Por esta razón, surge la necesidad de desarrollar un sistema que permita gestionar pedidos de forma rápida y eficiente, donde el usuario pueda seleccionar productos, armar un carrito y confirmar su pedido, mientras que el cafetín pueda recibir, preparar y entregar los pedidos manteniendo un control del pedido, reduciendo tiempos de espera, errores en el pedido y mejorando la calidad del servicio.

---

## 2. Objetivo general
Desarrollar un sistema que permita gestionar pedidos de forma rápida, reduciendo filas, tiempos de atención y errores en la toma de pedidos. El objetivo es que el usuario pueda seleccionar productos, armar un carrito, confirmar el pedido, y que el cafetín pueda recibir, preparar y entregar pedidos con control básico del proceso.

### Objetivos específicos
1. Diseñar un módulo que permita a los usuarios visualizar el menú, seleccionar productos y armar un carrito de compras.  
2. Implementar un sistema de confirmación de pedidos que reduzca errores en la toma de órdenes y optimice los tiempos de atención.  
3. Desarrollar un módulo de control para el cafetín que permita recibir, organizar, preparar y registrar la entrega de los pedidos.

---

## 3. Alcance
El sistema permitirá la gestión básica de pedidos dentro del cafetín, incluyendo la visualización de productos disponibles, selección de artículos, creación y confirmación de pedidos por parte del usuario. Además, permitirá al personal del cafetín recibir los pedidos y registrar su entrega.

El sistema no incluirá, integración con pagos en línea, control avanzado de inventarios, enfocándose únicamente en la gestión interna y rápida de pedidos.

---

## 4. Requerimientos Funcionales (RF)
- **RF1.** Permitir visualizar el menú de productos disponibles al usuario.  
- **RF2.** Permitir seleccionar los productos y agregarlos al carrito.  
- **RF3.** Modificar o eliminar productos del carrito.  
- **RF4.** Permitir confirmar el pedido antes de enviarlo.  
- **RF5.** Permitir al cafetín recibir los pedidos en tiempo real.  
- **RF6.** El sistema debe permitir cambiar el estado del pedido (recibido, en preparación, listo, entregado).

### Requerimientos No Funcionales (RNF)
- **RNF1.** El sistema debe ser fácil de usar.  
- **RNF2.** El sistema solo estará disponible durante el horario de atención.  
- **RNF3.** El sistema debe responder al registro de pedidos.  
- **RNF4.** El sistema debe garantizar la seguridad básica de la información.

### Reglas de negocio (RN)
- **RN1.** Un pedido solo se podrá hacer si tiene por lo menos un producto.  
- **RN2.** El pedido debe confirmarse antes de pasar a preparación.  
- **RN3.** Los pedidos se atenderán por orden de llegada.  
- **RN4.** Un pedido será finalizado solo cuando se le entregue al cliente.

---

## 5. Priorización MoSCoW (MVP)

### Must
- Visualización del menú de productos  
- Selección de productos y carrito de compras  
- Confirmación del pedido  
- Recepción del pedido en el cafetín  
- Cambio de estado del pedido  

### Should
- Ver total y subtotal  
- Confirmación del pedido  

### Could
- Personalización de productos  
- Historial de pedidos del usuario  

### Won’t
- Pagos en línea  
- Gestión de Inventarios  
- App nativa  

---

## 6. Mockup
![alt text](<Captura de pantalla 2026-02-10 113620.png>)


## 7. Backlog / Plan de trabajo  
### Historias de usuario

#### HU1 – Ver catálogo de productos
Como usuario del cafetín, quiero ver el catálogo de productos disponibles, para poder elegir lo que deseo comprar.

**Criterios de aceptación:**
- Se muestra una lista de productos con nombre y precio.
- Cada producto tiene la opción de agregar al carrito.

**Prioridad:** Must  
**Estimación:** Fácil  

---

#### HU2 – Agregar productos al carrito
Como usuario, quiero agregar productos al carrito de compras, para preparar mi pedido antes de enviarlo.

**Criterios de aceptación:**
- El usuario puede agregar uno o más productos.
- El carrito se actualiza automáticamente.

**Prioridad:** Must  
**Estimación:** Media  

---

#### HU3 – Ver y modificar carrito
Como usuario, quiero ver los productos del carrito y modificar cantidades, para ajustar mi pedido.

**Criterios de aceptación:**
- Se muestran los productos agregados.
- Se puede modificar o eliminar productos.
- Se muestra el total del pedido.

**Prioridad:** Must  
**Estimación:** Media  

---

#### HU4 – Confirmar pedido
Como usuario, quiero confirmar mi pedido antes de enviarlo, para evitar errores.

**Criterios de aceptación:**
- Se muestra un resumen del pedido.
- El pedido solo se envía si el usuario confirma.

**Prioridad:** Must  
**Estimación:** Fácil  

---

#### HU5 – Recibir pedidos en el cafetín
Como personal del cafetín, quiero recibir los pedidos en una pantalla de control, para organizarlos y prepararlos.

**Criterios de aceptación:**
- Los pedidos se muestran en orden de llegada.
- Cada pedido tiene un estado visible.

**Prioridad:** Must  
**Estimación:** Media  

---

#### HU6 – Cambiar estado del pedido
Como personal del cafetín, quiero cambiar el estado del pedido, para controlar su preparación y entrega.

**Criterios de aceptación:**
- El estado puede cambiar a recibido, en preparación, listo y entregado.

**Prioridad:** Must  
**Estimación:** Fácil  

---

### Tabla de priorización y estimación

| Historia | Descripción                         | Prioridad | Estimación |
|--------|-------------------------------------|-----------|------------|
| HU1    | Ver catálogo de productos           | Must      | 2 pts      |
| HU2    | Agregar productos al carrito        | Must      | 3 pts      |
| HU3    | Ver y modificar carrito             | Must      | 3 pts      |
| HU4    | Confirmar pedido                    | Must      | 2 pts      |
| HU5    | Recibir pedidos en el cafetín       | Must      | 3 pts      |
| HU6    | Cambiar estado del pedido           | Must      | 2 pts      |

---

## 8. Modelo de datos

### Entidades

**Producto**
- producto_id (PK)
- nombre
- precio
- disponible (bool)

**Pedido**
- pedido_id (PK)
- fecha_hora
- estado (Recibido / En preparación / Listo / Entregado)
- total

**DetallePedido**
- detalle_id (PK)
- pedido_id (FK → Pedido)
- producto_id (FK → Producto)
- cantidad
- precio_unitario
- subtotal

### Relaciones
- Pedido 1 a N DetallePedido  
- Producto 1 a N DetallePedido 
