# Ejercicio 09 Resuelto - Publicación de tarifas y análisis de reservas comercializadas

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
El área comercial necesita analizar las tarifas disponibles por ruta y validar cómo esas tarifas se relacionan con reservas, ventas y tiquetes emitidos. Además, se busca automatizar una acción posterior cuando se registre una tarifa o cuando se concrete una venta asociada a una tarifa.

---

## 6. Dominios involucrados
### SALES, RESERVATION, TICKETING
**Entidades:** `reservation`, `sale`, `ticket`, `fare`, `fare_class`  
**Propósito en este ejercicio:** Relacionar reservas, ventas y tiquetes con la estructura tarifaria.

### AIRPORT
**Entidades:** `airport`  
**Propósito en este ejercicio:** Representar origen y destino tarifario.

### AIRLINE
**Entidades:** `airline`  
**Propósito en este ejercicio:** Identificar la aerolínea propietaria de la tarifa.

---

## 7. Problema a resolver
La organización desea analizar qué tarifas se ofrecen por ruta y cómo terminan siendo utilizadas dentro del flujo de venta y emisión de tiquetes.

Por eso se plantea una solución en tres capas:
1. una consulta consolidada con `INNER JOIN`,
2. un procedimiento almacenado para publicar tarifas de forma controlada,
3. un trigger `AFTER INSERT` sobre `fare` que actualice la fecha de modificación de la aerolínea.

---

## 8. Solución propuesta

### 8.1 Consulta resuelta con `INNER JOIN`
La consulta integra el catálogo de tarifas con la actividad comercial real.

```sql
SELECT
    al.airline_name AS aerolinea,
    f.fare_code AS codigo_tarifa,
    fc.fare_class_name AS clase_tarifaria,
    ao.iata_code AS aeropuerto_origen,
    ad.iata_code AS aeropuerto_destino,
    curr.iso_currency_code AS moneda,
    r.reservation_code AS reserva,
    s.sale_code AS venta,
    t.ticket_number AS tiquete
FROM fare f
INNER JOIN airline al ON al.airline_id = f.airline_id
INNER JOIN fare_class fc ON fc.fare_class_id = f.fare_class_id
INNER JOIN airport ao ON ao.airport_id = f.origin_airport_id
INNER JOIN airport ad ON ad.airport_id = f.destination_airport_id
INNER JOIN currency curr ON curr.currency_id = f.currency_id
INNER JOIN ticket t ON t.fare_id = f.fare_id
INNER JOIN sale s ON s.sale_id = t.sale_id
INNER JOIN reservation r ON r.reservation_id = s.reservation_id
ORDER BY al.airline_name, f.fare_code;
```

---

## 9. Procedimiento almacenado resuelto

### 9.1 Objetivo
Encapsular la publicación de nuevas tarifas para asegurar que los montos sean válidos y los aeropuertos de origen y destino sean distintos.

### 9.2 Script del procedimiento
```sql
DROP PROCEDURE IF EXISTS sp_publish_fare;

CREATE OR REPLACE PROCEDURE sp_publish_fare(
    p_airline_id uuid,
    p_origin_airport_id uuid,
    p_destination_airport_id uuid,
    p_fare_class_id uuid,
    p_currency_id uuid,
    p_fare_code varchar(30),
    p_base_amount numeric,
    p_valid_from date,
    p_valid_to date
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar que aeropuertos sean diferentes
    IF p_origin_airport_id = p_destination_airport_id THEN
        RAISE EXCEPTION 'El aeropuerto de origen y destino no pueden ser el mismo.';
    END IF;

    -- Validar monto
    IF p_base_amount < 0 THEN
        RAISE EXCEPTION 'El monto base no puede ser negativo.';
    END IF;

    INSERT INTO fare (
        airline_id,
        origin_airport_id,
        destination_airport_id,
        fare_class_id,
        currency_id,
        fare_code,
        base_amount,
        valid_from,
        valid_to
    )
    VALUES (
        p_airline_id,
        p_origin_airport_id,
        p_destination_airport_id,
        p_fare_class_id,
        p_currency_id,
        p_fare_code,
        p_base_amount,
        p_valid_from,
        p_valid_to
    );
END;
$$;
```

---

## 10. Trigger resuelto

### 10.1 Decisión técnica
Se configuró un trigger `AFTER INSERT ON fare` que actualiza la fecha `updated_at` de la aerolínea para indicar que su catálogo comercial ha sido actualizado.

### 10.2 Script del trigger
```sql
DROP TRIGGER IF EXISTS trg_ai_fare_touch_airline ON fare;
DROP FUNCTION IF EXISTS fn_ai_fare_touch_airline();

CREATE OR REPLACE FUNCTION fn_ai_fare_touch_airline()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE airline
    SET updated_at = now()
    WHERE airline_id = NEW.airline_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_fare_touch_airline
AFTER INSERT ON fare
FOR EACH ROW
EXECUTE FUNCTION fn_ai_fare_touch_airline();
```

---

## 11. Script de demostración del funcionamiento

```sql
DO $$
DECLARE
    v_airline_id uuid;
    v_origin_id uuid;
    v_dest_id uuid;
    v_fare_class_id uuid;
    v_currency_id uuid;
    v_fare_code varchar(30);
BEGIN
    -- 1. Obtener datos necesarios
    SELECT airline_id INTO v_airline_id FROM airline LIMIT 1;
    SELECT airport_id INTO v_origin_id FROM airport LIMIT 1;
    SELECT airport_id INTO v_dest_id FROM airport OFFSET 1 LIMIT 1;
    SELECT fare_class_id INTO v_fare_class_id FROM fare_class LIMIT 1;
    SELECT currency_id INTO v_currency_id FROM currency LIMIT 1;

    IF v_airline_id IS NULL OR v_origin_id IS NULL OR v_dest_id IS NULL THEN
        RAISE NOTICE 'v_airline_id: %, v_origin_id: %, v_dest_id: %', v_airline_id, v_origin_id, v_dest_id;
        RAISE EXCEPTION 'No se encontraron datos base suficientes para la prueba de tarifas.';
    END IF;

    v_fare_code := 'FARE-DEMO-' || upper(replace(left(gen_random_uuid()::text, 8), '-', ''));
    RAISE NOTICE 'Generando tarifa con código: %', v_fare_code;

    -- 2. Invocar procedimiento (dispara el trigger)
    CALL sp_publish_fare(
        v_airline_id,
        v_origin_id,
        v_dest_id,
        v_fare_class_id,
        v_currency_id,
        v_fare_code,
        299.99,
        current_date,
        (current_date + interval '1 year')::date
    );

    RAISE NOTICE 'Tarifa % publicada exitosamente.', v_fare_code;
END;
$$;

-- 3. Verificación
SELECT 
    al.airline_name,
    al.updated_at AS airline_last_update,
    f.fare_code,
    f.base_amount,
    f.valid_from
FROM airline al
INNER JOIN fare f ON f.airline_id = al.airline_id
WHERE f.fare_code LIKE 'FARE-DEMO-%'
ORDER BY f.created_at DESC
LIMIT 1;
```

---

## 12. Validación final
La solución es válida porque:
- Implementa una consulta comercial que vincula la estrategia tarifaria con la facturación real.
- Asegura la integridad mediante validaciones en el procedimiento y automatiza la trazabilidad con el trigger.
- Respeta estrictamente los nombres de columnas y tablas del modelo base.

---

## 13. Archivo SQL relacionado
- `scripts_sql/ejercicio_09_setup.sql`
- `scripts_sql/ejercicio_09_demo.sql`
