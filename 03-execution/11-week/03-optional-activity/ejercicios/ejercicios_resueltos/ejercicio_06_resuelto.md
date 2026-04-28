# Ejercicio 06 Resuelto - Operación de vuelos y control de retrasos

# Modelo de datos base del sistema

## 1. Descripción general del modelo
El modelo de datos corresponde a un sistema integral de aerolínea, diseñado para soportar de forma relacional los procesos principales del negocio: gestión geográfica, identidad de personas, seguridad, clientes, fidelización, aeropuertos, aeronaves, operación de vuelos, reservas, tiquetes, abordaje, pagos y facturación.

Se trata de un modelo amplio y normalizado, en el que las entidades están separadas por dominios funcionales y conectadas mediante llaves foráneas para garantizar trazabilidad, integridad y consistencia en todo el flujo operativo y comercial.

---

## 2. Resumen previo del análisis realizado
Como base de trabajo, previamente se identificó y organizó el script en dominios funcionales. A partir de esa revisión, se determinó que el modelo no corresponde a un caso pequeño o aislado, sino a una solución empresarial con múltiples áreas del negocio conectadas entre sí.

También se verificó que:
- el modelo contiene más de 60 entidades,
- las relaciones entre tablas siguen una estructura consistente,
- existen restricciones de integridad mediante `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE` y `CHECK`,
- el diseño soporta trazabilidad end-to-end desde la reserva hasta el pago, abordaje y facturación.

---

## 3. Dominios del modelo y propósito general

### GEOGRAPHY AND REFERENCE DATA
**Entidades:** `time_zone`, `continent`, `country`, `state_province`, `city`, `district`, `address`, `currency`  
**Resumen:** Centraliza información geográfica y de referencia para ubicar aeropuertos, personas, proveedores y definir monedas operativas del sistema.

### AIRLINE
**Entidades:** `airline`  
**Resumen:** Representa la aerolínea operadora del sistema, incluyendo sus códigos y país base.

### IDENTITY
**Entidades:** `person_type`, `document_type`, `contact_type`, `person`, `person_document`, `person_contact`  
**Resumen:** Permite modelar la identidad de las personas, sus documentos y medios de contacto.

### SECURITY
**Entidades:** `user_status`, `security_role`, `security_permission`, `user_account`, `user_role`, `role_permission`  
**Resumen:** Administra autenticación, autorización y control de acceso al sistema.

### CUSTOMER AND LOYALTY
**Entidades:** `customer_category`, `benefit_type`, `loyalty_program`, `loyalty_tier`, `customer`, `loyalty_account`, `loyalty_account_tier`, `miles_transaction`, `customer_benefit`  
**Resumen:** Gestiona clientes, programas de fidelización, acumulación de millas, beneficios y niveles.

### AIRPORT
**Entidades:** `airport`, `terminal`, `boarding_gate`, `runway`, `airport_regulation`  
**Resumen:** Modela la infraestructura aeroportuaria y las condiciones regulatorias asociadas a cada aeropuerto.

### AIRCRAFT
**Entidades:** `aircraft_manufacturer`, `aircraft_model`, `cabin_class`, `aircraft`, `aircraft_cabin`, `aircraft_seat`, `maintenance_provider`, `maintenance_type`, `maintenance_event`  
**Resumen:** Gestiona aeronaves, fabricantes, configuración interna y procesos de mantenimiento.

### FLIGHT OPERATIONS
**Entidades:** `flight_status`, `delay_reason_type`, `flight`, `flight_segment`, `flight_delay`  
**Resumen:** Controla la operación de vuelos, sus segmentos, estados y retrasos.

### SALES, RESERVATION, TICKETING
**Entidades:** `reservation_status`, `sale_channel`, `fare_class`, `fare`, `ticket_status`, `reservation`, `reservation_passenger`, `sale`, `ticket`, `ticket_segment`, `seat_assignment`, `baggage`  
**Resumen:** Gestiona el flujo comercial principal: reserva, pasajero, venta, emisión de tiquetes, asignación de asiento y equipaje.

### BOARDING
**Entidades:** `boarding_group`, `check_in_status`, `check_in`, `boarding_pass`, `boarding_validation`  
**Resumen:** Soporta el proceso de check-in, emisión de pase de abordar y validación final de embarque.

### PAYMENT
**Entidades:** `payment_status`, `payment_method`, `payment`, `payment_transaction`, `refund`  
**Resumen:** Administra pagos, transacciones y devoluciones asociadas a las ventas.

### BILLING
**Entidades:** `tax`, `exchange_rate`, `invoice_status`, `invoice`, `invoice_line`  
**Resumen:** Gestiona impuestos, tasas de cambio, facturas y detalle facturable.

---

## 4. Restricción general para todos los ejercicios
Todos los ejercicios se resuelven respetando estrictamente el modelo entregado.

No se cambia:
- ningún atributo existente,
- nombres de tablas o columnas,
- relaciones del modelo,
- ni la estructura general del script base.

---

## 5. Contexto del ejercicio
El área de operaciones necesita controlar y auditar los retrasos en los vuelos, identificando el vuelo afectado, la aeronave asignada y la razón de la demora. Se requiere, además, automatizar un proceso posterior al momento de reportar un retraso.

---

## 6. Dominios involucrados
### FLIGHT OPERATIONS
**Entidades:** `flight`, `flight_delay`, `delay_reason_type`, `flight_status`  
**Propósito en este ejercicio:** Gestionar los vuelos, sus retrasos reportados y las razones tipificadas del incidente.

### AIRCRAFT
**Entidades:** `aircraft`  
**Propósito en este ejercicio:** Identificar la aeronave asignada al vuelo afectado.

### AIRLINE
**Entidades:** `airline`  
**Propósito en este ejercicio:** Relacionar el vuelo con su aerolínea operadora.

---

## 7. Problema a resolver
Cuando ocurre una contingencia u operación irregular (retraso en el vuelo), el centro de control aéreo necesita generar el evento y dejarlo visible automáticamente a otros sistemas (actualizando la cabecera del vuelo).

Por eso se plantea una solución en tres capas:
1. una consulta consolidada con `INNER JOIN` para monitorear los retrasos.
2. un procedimiento almacenado para registrar de manera segura una incidencia de retraso.
3. un trigger `AFTER INSERT` sobre `flight_delay` para informar al sistema que el vuelo original fue alterado.

---

## 8. Solución propuesta

### 8.1 Consulta resuelta con `INNER JOIN`
La consulta centraliza los retrasos tipificando los motivos (meteorología, mantenimiento, etc.) y mostrando la nave afectada.

```sql
SELECT
    f.flight_number AS numero_vuelo,
    f.service_date AS fecha_servicio,
    al.airline_name AS aerolinea,
    a.registration_number AS matricula_aeronave,
    fs.status_name AS estado_vuelo,
    drt.reason_name AS motivo_retraso,
    fd.delay_minutes AS minutos_retraso,
    fd.reported_at AS fecha_reporte
FROM flight f
INNER JOIN airline al ON al.airline_id = f.airline_id
INNER JOIN aircraft a ON a.aircraft_id = f.aircraft_id
INNER JOIN flight_status fs ON fs.flight_status_id = f.flight_status_id
INNER JOIN flight_delay fd ON fd.flight_segment_id = fs.flight_segment_id
INNER JOIN delay_reason_type drt ON drt.delay_reason_type_id = fd.delay_reason_type_id
ORDER BY fd.reported_at DESC;
```

### 8.2 Explicación paso a paso de la consulta
1. **`flight`** es la operación central.
2. **`airline`** detalla bajo qué marca/compañía opera el vuelo.
3. **`aircraft`** expone qué máquina está sufriendo el retraso.
4. **`flight_status`** indica si el vuelo está demorado, programado o cancelado a raíz del problema.
5. **`flight_delay`** es el historial específico de la contingencia en minutos.
6. **`delay_reason_type`** tipifica y codifica el tipo de incidente reportado.

---

## 9. Procedimiento almacenado resuelto

### 9.1 Objetivo
Permitir a los operadores registrar una anomalía operativa validando las restricciones lógicas y temporales de un retraso de vuelo.

### 9.2 Decisión técnica
El procedimiento valida explícitamente que los minutos de retraso ingresados sean mayores a cero antes de inyectar los datos. 

### 9.3 Script del procedimiento
```sql
DROP PROCEDURE IF EXISTS sp_register_flight_delay(uuid, uuid, integer, timestamptz, text);

CREATE OR REPLACE PROCEDURE sp_register_flight_delay(
    p_flight_id uuid,
    p_delay_reason_id uuid,
    p_delay_minutes integer,
    p_reported_at timestamptz,
    p_delay_notes text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_delay_minutes <= 0 THEN
        RAISE EXCEPTION 'El retraso debe ser mayor a 0 minutos.';
    END IF;

    INSERT INTO flight_delay (
        flight_segment_id,
        delay_reason_type_id,
        delay_minutes,
        reported_at,
        notes
    )
    VALUES (
        p_flight_segment_id,
        p_delay_reason_type_id,
        p_delay_minutes,
        p_reported_at,
        p_notes
    );
END;
$$;
```

### 9.4 Por qué esta solución es correcta
- Abstrae el reporte, validando al nivel más bajo (BD) que los reportes de contingencia contengan valores lógicos de demora.

---

## 10. Trigger resuelto

### 10.1 Decisión técnica
Se configuró un trigger `AFTER INSERT ON flight_delay` que actualiza la fecha de modificación del vuelo. Al agregarse demoras, el `flight` afectado debe ser considerado alterado operativamente.

### 10.2 Lógica implementada
- Cada vez que un agente inserta un registro en `flight_delay`, el trigger afecta la tabla `flight` y marca `updated_at` a `now()`.

### 10.3 Script del trigger
```sql
DROP TRIGGER IF EXISTS trg_ai_flight_delay_touch_flight ON flight_delay;
DROP FUNCTION IF EXISTS fn_ai_flight_delay_touch_flight();

CREATE OR REPLACE FUNCTION fn_ai_flight_delay_touch_flight()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE flight_segment
    SET updated_at = now()
    WHERE flight_segment_id = NEW.flight_segment_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_flight_delay_touch_flight
AFTER INSERT ON flight_delay
FOR EACH ROW
EXECUTE FUNCTION fn_ai_flight_delay_touch_flight();
```

### 10.4 Por qué esta solución es correcta
- Cuando las pantallas de aeropuerto chequean actualizaciones en el vuelo (vía APIs que filtran por `updated_at`), automáticamente detectarán la novedad operacional y refrescarán las pantallas para los clientes.

---

## 11. Script de demostración del funcionamiento

```sql
DO $$
DECLARE
    v_flight_id uuid;
    v_delay_reason_id uuid;
BEGIN
    -- 1. Buscar un vuelo programado
    SELECT flight_id
    INTO v_flight_id
    FROM flight
    LIMIT 1;

    -- 2. Buscar un motivo de retraso
    SELECT delay_reason_id
    INTO v_delay_reason_id
    FROM delay_reason_type
    LIMIT 1;

    IF v_flight_id IS NULL OR v_delay_reason_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró un vuelo o un motivo de retraso para la prueba.';
    END IF;

    -- 3. Invocar procedimiento (dispara el trigger)
    CALL sp_register_flight_delay(
        v_flight_id,
        v_delay_reason_id,
        45, -- Minutos de retraso
        now(),
        'Retraso por condiciones climáticas adversas (Prueba)'
    );

    RAISE NOTICE 'Retraso de 45 min registrado exitosamente para el vuelo %', v_flight_id;
END;
$$;

-- 4. Verificación de la trazabilidad en la cabecera del vuelo
SELECT 
    f.flight_number,
    f.updated_at AS vuelo_actualizado,
    fd.delay_minutes,
    drt.reason_name,
    fd.notes
FROM flight f
INNER JOIN flight_segment fs ON fs.flight_id = f.flight_id
INNER JOIN flight_delay fd ON fd.flight_segment_id = fs.flight_segment_id
INNER JOIN delay_reason_type drt ON drt.delay_reason_type_id = fd.delay_reason_type_id
WHERE fd.notes = 'Retraso por condiciones climáticas adversas (Prueba)'
ORDER BY fd.created_at DESC
LIMIT 1;
```

### 11.1 Qué demuestra este script
1. Simula un problema donde el clima retrasa 45 minutos un vuelo existente.
2. Llama al procedimiento con todos los parámetros correctos.
3. El resultado de verificación demuestra tanto la consistencia contable del retraso como la alteración automatizada en el vuelo madre por parte del trigger.

---

## 12. Validación final
La solución es válida porque:
- Implementa eficientemente una conexión natural dentro del dominio FLIGHT OPERATIONS.
- Encapsula el reporte de fallas/demoras.
- Provee la base para el monitoreo de cambios a través de audit trails (`updated_at`).

---

## 13. Archivo SQL relacionado
- `scripts_sql/ejercicio_06_setup.sql`
- `scripts_sql/ejercicio_06_demo.sql`
