# Ejercicio 07 Resuelto - Asignación de asientos y registro de equipaje por segmento ticketed

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
El área de aeropuerto necesita auditar qué asientos y equipajes están asociados a cada segmento ticketed y automatizar una acción posterior cuando se registre un equipaje o una asignación operativa.

---

## 6. Dominios involucrados
### SALES, RESERVATION, TICKETING
**Entidades:** `ticket`, `ticket_segment`, `seat_assignment`, `baggage`  
**Propósito en este ejercicio:** Gestionar el tiquete, su segmento, la asignación de asiento y el equipaje asociado.

### AIRCRAFT
**Entidades:** `aircraft`, `aircraft_cabin`, `aircraft_seat`, `cabin_class`  
**Propósito en este ejercicio:** Relacionar el asiento con la configuración real de la aeronave.

### FLIGHT OPERATIONS
**Entidades:** `flight`, `flight_segment`  
**Propósito en este ejercicio:** Relacionar el segmento ticketed con el segmento operativo del vuelo.

---

## 7. Problema a resolver
Se requiere consultar de manera integrada la asignación de asientos y el registro de equipaje por pasajero y segmento, y además automatizar una reacción posterior cuando ocurra un evento sobre equipaje o asiento.

Por eso se plantea una solución en tres capas:
1. una consulta consolidada con `INNER JOIN`,
2. un procedimiento almacenado para registrar de manera unificada el equipaje.
3. un trigger `AFTER INSERT` sobre `baggage` que actualice el segmento del tiquete.

---

## 8. Solución propuesta

### 8.1 Consulta resuelta con `INNER JOIN`
Se estructuró una consulta que vincula el tiquete comercial con el equipaje y la ubicación física del pasajero en el avión.

```sql
SELECT
    t.ticket_number AS numero_tiquete,
    ts.segment_sequence_no AS secuencia_segmento_ticketed,
    f.flight_number AS numero_vuelo_segmento,
    cc.class_name AS cabina,
    aseat.seat_row_number AS fila_asiento,
    aseat.seat_column_code AS columna_asiento,
    b.baggage_tag AS etiqueta_equipaje,
    b.baggage_type AS tipo_equipaje,
    b.baggage_status AS estado_equipaje
FROM ticket t
INNER JOIN ticket_segment ts ON ts.ticket_id = t.ticket_id
INNER JOIN flight_segment fs ON fs.flight_segment_id = ts.flight_segment_id
INNER JOIN flight f ON f.flight_id = fs.flight_id
LEFT JOIN seat_assignment sa ON sa.ticket_segment_id = ts.ticket_segment_id
LEFT JOIN aircraft_seat aseat ON aseat.aircraft_seat_id = sa.aircraft_seat_id
LEFT JOIN aircraft_cabin ac ON ac.aircraft_cabin_id = aseat.aircraft_cabin_id
LEFT JOIN cabin_class cc ON cc.cabin_class_id = ac.cabin_class_id
LEFT JOIN baggage b ON b.ticket_segment_id = ts.ticket_segment_id
ORDER BY t.ticket_number, ts.segment_sequence_no;
```

### 8.2 Explicación paso a paso de la consulta
1. **`ticket`** y **`ticket_segment`** son la base comercial del viaje.
2. **`flight_segment`** y **`flight`** dan la trazabilidad hacia la operación real.
3. **`seat_assignment`** conecta el trayecto con el asiento físico reservado.
4. **`aircraft_seat`**, **`aircraft_cabin`** y **`cabin_class`** dan el detalle de ubicación y confort.
5. **`baggage`** vincula el equipaje documentado específicamente a ese trayecto del pasajero.

---

## 9. Procedimiento almacenado resuelto

### 9.1 Objetivo
Encapsular el registro de equipaje asegurando que se cumplan las validaciones de tipo y estado.

### 9.2 Decisión técnica
El procedimiento `sp_register_baggage` valida que el tipo y estado del equipaje correspondan a los permitidos por el modelo de negocio antes de la inserción.

### 9.3 Script del procedimiento
```sql
DROP PROCEDURE IF EXISTS sp_register_baggage(uuid, varchar, varchar, varchar, numeric);

CREATE OR REPLACE PROCEDURE sp_register_baggage(
    p_ticket_segment_id uuid,
    p_baggage_tag varchar(30),
    p_baggage_type varchar(20),
    p_baggage_status varchar(20),
    p_weight_kg numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validaciones de tipo y estado
    IF p_baggage_type NOT IN ('CHECKED', 'CARRY_ON', 'SPECIAL') THEN
        RAISE EXCEPTION 'Tipo de equipaje inválido: %', p_baggage_type;
    END IF;

    IF p_baggage_status NOT IN ('REGISTERED', 'LOADED', 'CLAIMED', 'LOST') THEN
        RAISE EXCEPTION 'Estado de equipaje inválido: %', p_baggage_status;
    END IF;

    INSERT INTO baggage (
        ticket_segment_id,
        baggage_tag,
        baggage_type,
        baggage_status,
        weight_kg,
        checked_at
    )
    VALUES (
        p_ticket_segment_id,
        p_baggage_tag,
        p_baggage_type,
        p_baggage_status,
        p_weight_kg,
        now()
    );
END;
$$;
```

---

## 10. Trigger resuelto

### 10.1 Decisión técnica
Se configuró un trigger `AFTER INSERT ON baggage` para actualizar la marca de tiempo del segmento del tiquete (`ticket_segment`). Esto permite que otros sistemas detecten que hubo actividad en el mostrador para ese pasajero.

### 10.2 Lógica implementada
- Al insertar un equipaje, el trigger busca el `ticket_segment_id` afectado.
- Actualiza el campo `updated_at` del segmento para trazabilidad operativa.

### 10.3 Script del trigger
```sql
DROP TRIGGER IF EXISTS trg_ai_baggage_touch_segment ON baggage;
DROP FUNCTION IF EXISTS fn_ai_baggage_touch_segment();

CREATE OR REPLACE FUNCTION fn_ai_baggage_touch_segment()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ticket_segment
    SET updated_at = now()
    WHERE ticket_segment_id = NEW.ticket_segment_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_baggage_touch_segment
AFTER INSERT ON baggage
FOR EACH ROW
EXECUTE FUNCTION fn_ai_baggage_touch_segment();
```

---

## 11. Script de demostración del funcionamiento

```sql
DO $$
DECLARE
    v_ticket_segment_id uuid;
    v_tag varchar(30);
BEGIN
    -- 1. Buscar un segmento de tiquete que no tenga equipaje
    SELECT ts.ticket_segment_id 
    INTO v_ticket_segment_id 
    FROM ticket_segment ts
    LEFT JOIN baggage b ON b.ticket_segment_id = ts.ticket_segment_id
    WHERE b.baggage_id IS NULL
    LIMIT 1;

    IF v_ticket_segment_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró un segmento de tiquete disponible para la prueba.';
    END IF;

    v_tag := 'TAG-' || upper(replace(left(gen_random_uuid()::text, 8), '-', ''));

    -- 2. Invocar procedimiento (dispara el trigger)
    CALL sp_register_baggage(
        v_ticket_segment_id,
        v_tag,
        'CHECKED',
        'REGISTERED',
        23.5 -- 23.5 kg
    );

    RAISE NOTICE 'Equipaje registrado con etiqueta % para el segmento %', v_tag, v_ticket_segment_id;
END;
$$;

-- 3. Verificación
SELECT 
    ts.segment_sequence_no,
    ts.updated_at AS segment_last_update,
    b.baggage_tag,
    b.baggage_type,
    b.weight_kg,
    b.checked_at
FROM ticket_segment ts
INNER JOIN baggage b ON b.ticket_segment_id = ts.ticket_segment_id
WHERE b.baggage_tag LIKE 'TAG-%'
ORDER BY b.created_at DESC
LIMIT 1;
```

### 11.1 Qué demuestra este script
1. Busca un trayecto que aún no tenga maletas registradas.
2. Genera una etiqueta única y llama al procedimiento.
3. El resultado final confirma que el equipaje se guardó y que el segmento del tiquete fue "tocado" por el trigger, evidenciando actividad.

---

## 12. Validación final
La solución es válida porque:
- Implementa una consulta multi-tabla coherente con la operación aeroportuaria.
- Encapsula la lógica de negocio en el procedimiento y automatiza la trazabilidad con el trigger.
- Respeta estrictamente los nombres de columnas y tablas del modelo de 76 tablas.

---

## 13. Archivo SQL relacionado
- `scripts_sql/ejercicio_07_setup.sql`
- `scripts_sql/ejercicio_07_demo.sql`
