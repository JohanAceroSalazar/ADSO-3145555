# ADR-001: Diseño de Base de Datos para Sistema Aerolínea

## Estado

Aprobado

---

## Contexto

Se requiere diseñar una base de datos robusta para un sistema de aerolínea que gestione:

* Ubicación geográfica (países, ciudades, direcciones)
* Usuarios y seguridad
* Clientes y programas de lealtad
* Aeropuertos, aeronaves y mantenimiento
* Operaciones de vuelo
* Reservas, tickets y ventas
* Pagos y facturación

El sistema debe ser:

* Escalable
* Normalizado
* Seguro
* Flexible para múltiples aerolíneas

---

## Decisiones de Arquitectura

### 1. Uso de UUID como clave primaria

**Decisión:**
Se usan `uuid` con `gen_random_uuid()` en todas las tablas.

**Justificación:**

* Evita colisiones en sistemas distribuidos
* Mayor seguridad (no predecibles)
* Facilita integración entre servicios

**Consecuencias:**

* Escalable en microservicios
* Difícil de adivinar IDs

- Menor legibilidad
- Más costoso en rendimiento que INT

---

### 2. Separación por dominios (modularización)

**Decisión:**
La base de datos está dividida en módulos:

* Geography
* Identity
* Security
* Airline
* Flight Operations
* Sales
* Payment
* Billing

**Justificación:**

* Mejora organización
* Facilita mantenimiento
* Permite crecimiento por módulos

**Consecuencias:**

* Alta mantenibilidad
* Claridad del modelo
* Mayor complejidad inicial

---

### 3. Normalización (3FN)

**Decisión:**
Se aplica **Tercera Forma Normal (3FN)**.

Ejemplos:

* `loyalty_account_tier` evita dependencia transitiva
* `invoice_line` no guarda totales

**Justificación:**

* Evita duplicidad de datos
* Mejora consistencia

**Consecuencias:**

* Datos limpios
* Menos redundancia

- Más joins en consultas

---

### 4. Uso de tablas de referencia (catálogos)

**Decisión:**
Se crean tablas como:

* `person_type`
* `document_type`
* `flight_status`
* `payment_status`

**Justificación:**

* Evita valores hardcodeados
* Facilita cambios sin afectar código

**Consecuencias:**

* Flexibilidad
* Escalabilidad

- Más joins

---

### 5. Integridad referencial (FK)

**Decisión:**
Uso intensivo de **FOREIGN KEYS**

**Justificación:**

* Garantiza consistencia de datos
* Evita registros huérfanos

**Consecuencias:**

* Alta integridad
* Impacto en rendimiento si no se indexa bien

---

### 6. Uso de constraints (CHECK, UNIQUE)

**Decisión:**
Se usan múltiples restricciones:

* CHECK (validaciones)
* UNIQUE (unicidad)
* FK (relaciones)

**Ejemplos:**

* `gender_code IN ('F','M','X')`
* `amount > 0`

**Justificación:**

* Validación a nivel de BD
* Evita errores del lado del backend

**Consecuencias:**

* Mayor seguridad de datos

- Más complejidad al insertar datos

---

### 7. Manejo de fechas con timestamptz

**Decisión:**
Uso de `timestamptz`

**Justificación:**

* Soporte de zonas horarias
* Necesario en vuelos internacionales

**Consecuencias:**

* Precisión global

- Mayor complejidad

---

### 8. Índices para optimización

**Decisión:**
Se crean índices en:

* Foreign keys
* Campos de búsqueda frecuente

**Justificación:**

* Mejora rendimiento en consultas

**Consecuencias:**

* Consultas rápidas

- Mayor uso de almacenamiento

---

### 9. Separación de identidad y usuario

**Decisión:**

* `person` ≠ `user_account`

**Justificación:**

* Una persona puede no tener usuario
* Permite reutilizar datos personales

**Consecuencias:**

* Flexibilidad
* Modelo realista

- Más joins

---

### 10. Modelo de roles y permisos

**Decisión:**
Sistema RBAC:

* `user_role`
* `role_permission`

**Justificación:**

* Control de acceso escalable

**Consecuencias:**

* Seguridad
* Escalabilidad

- Complejidad

---

## Problemas / Errores Detectados

### ❌ 1. Redundancia potencial en seat_assignment

```sql
(ticket_segment_id, flight_segment_id)
```

Problema:

* `flight_segment_id` ya está en `ticket_segment`

👉 Puede generar inconsistencias

---

### ❌ 2. Uso excesivo de VARCHAR sin control

Ejemplo:

```sql
transaction_type varchar(20)
```

Problema:

* Mejor usar ENUM o tabla catálogo

---

### ❌ 3. Falta de índices en campos críticos

Ejemplo:

* `username` (aunque tiene UNIQUE, podría optimizarse más según uso)

---

### ❌ 4. Campos nullable sin justificación clara

Ejemplo:

* `middle_name`
* `address_line_2`

👉 Puede generar datos incompletos si no se controla desde backend

---

### ❌ 5. Falta de auditoría avanzada

Solo existe:

* `created_at`
* `updated_at`

Falta:

* `deleted_at` (soft delete)
* `created_by`, `updated_by`

---

### ❌ 6. No uso de ENUM nativo en PostgreSQL

Ejemplo:

```sql
status_code IN ('PLANNED', 'COMPLETED')
```

Problema:

* ENUM sería más eficiente

---

### ❌ 7. Complejidad excesiva

* Muchas tablas
* Alto número de relaciones

👉 Puede dificultar:

* Desarrollo inicial
* Debugging

---

### ❌ 8. Dependencia fuerte entre módulos

Ejemplo:

* `flight` depende de `aircraft`, `airline`, etc.

👉 Dificulta desacoplar servicios en microservicios

---

## Consecuencias Generales

### Positivas

* Modelo altamente escalable
* Cumple buenas prácticas (3FN)
* Alta integridad de datos
* Preparado para sistemas grandes

### Negativas

* Complejidad alta
* Curva de aprendizaje elevada
* Muchas joins
* Difícil para proyectos pequeños

---

## Conclusión

El diseño es:

✅ Robusto
✅ Escalable
✅ Bien normalizado

Pero:

⚠️ Complejo
⚠️ Puede optimizarse en simplicidad
⚠️ Requiere buen backend para manejarlo correctamente

---

## Recomendaciones

* Evaluar uso de ENUM
* Simplificar algunas relaciones
* Agregar auditoría completa
* Validar redundancias
* Documentar cada módulo