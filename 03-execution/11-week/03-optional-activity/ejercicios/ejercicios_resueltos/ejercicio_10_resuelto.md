# Ejercicio 10 Resuelto - Identidad de pasajeros, documentos y medios de contacto

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
El área de servicio al cliente necesita consultar la identidad completa del pasajero, sus documentos y datos de contacto, y automatizar una acción posterior cuando se registre un nuevo documento.

---

## 6. Dominios involucrados
### IDENTITY
**Entidades:** `person`, `person_type`, `person_document`, `document_type`, `person_contact`, `contact_type`  
**Propósito en este ejercicio:** Gestionar identidad, documentos y medios de contacto.

### SALES, RESERVATION, TICKETING
**Entidades:** `reservation_passenger`, `reservation`  
**Propósito en este ejercicio:** Relacionar la identidad con la actividad comercial del pasajero.

---

## 7. Problema a resolver
La organización necesita una visión integrada de los pasajeros registrados y requiere automatizar un efecto posterior cuando cambie su información documental.

Por eso se plantea una solución en tres capas:
1. una consulta consolidada con `INNER JOIN`,
2. un procedimiento almacenado para registrar documentos de identidad,
3. un trigger `AFTER INSERT` sobre `person_document` que actualice la fecha de modificación de la persona.

---

## 8. Solución propuesta

### 8.1 Consulta resuelta con `INNER JOIN`
La consulta permite obtener una ficha completa del pasajero incluyendo su información documental y comercial.

```sql
SELECT
    p.first_name || ' ' || p.last_name AS persona,
    pt.type_name AS tipo_persona,
    dt.type_name AS tipo_documento,
    pd.document_number AS numero_documento,
    ct.type_name AS tipo_contacto,
    pc.contact_value AS valor_contacto,
    r.reservation_code AS reserva_relacionada,
    rp.passenger_sequence_no AS secuencia_pasajero
FROM person p
INNER JOIN person_type pt ON pt.person_type_id = p.person_type_id
INNER JOIN person_document pd ON pd.person_id = p.person_id
INNER JOIN document_type dt ON dt.document_type_id = pd.document_type_id
INNER JOIN person_contact pc ON pc.person_id = p.person_id
INNER JOIN contact_type ct ON ct.contact_type_id = pc.contact_type_id
INNER JOIN reservation_passenger rp ON rp.person_id = p.person_id
INNER JOIN reservation r ON r.reservation_id = rp.reservation_id
ORDER BY p.last_name, p.first_name;
```

---

## 9. Procedimiento almacenado resuelto

### 9.1 Objetivo
Encapsular el registro de documentos de identidad para asegurar la trazabilidad y consistencia de los datos.

### 9.2 Script del procedimiento
```sql
DROP PROCEDURE IF EXISTS sp_register_person_document;

CREATE OR REPLACE PROCEDURE sp_register_person_document(
    p_person_id uuid,
    p_document_type_id uuid,
    p_issuing_country_id uuid,
    p_document_number varchar(64),
    p_issued_on date,
    p_expires_on date
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar fechas
    IF p_expires_on IS NOT NULL AND p_issued_on IS NOT NULL AND p_expires_on < p_issued_on THEN
        RAISE EXCEPTION 'La fecha de vencimiento no puede ser anterior a la de emisión.';
    END IF;

    INSERT INTO person_document (
        person_id,
        document_type_id,
        issuing_country_id,
        document_number,
        issued_on,
        expires_on
    )
    VALUES (
        p_person_id,
        p_document_type_id,
        p_issuing_country_id,
        p_document_number,
        p_issued_on,
        p_expires_on
    );
END;
$$;
```

---

## 10. Trigger resuelto

### 10.1 Decisión técnica
Se configuró un trigger `AFTER INSERT ON person_document` que actualiza la fecha `updated_at` de la persona para indicar que su información de identidad ha sido actualizada.

### 10.2 Script del trigger
```sql
DROP TRIGGER IF EXISTS trg_ai_person_document_touch_person ON person_document;
DROP FUNCTION IF EXISTS fn_ai_person_document_touch_person();

CREATE OR REPLACE FUNCTION fn_ai_person_document_touch_person()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE person
    SET updated_at = now()
    WHERE person_id = NEW.person_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_person_document_touch_person
AFTER INSERT ON person_document
FOR EACH ROW
EXECUTE FUNCTION fn_ai_person_document_touch_person();
```

---

## 11. Script de demostración del funcionamiento

```sql
DO $$
DECLARE
    v_person_id uuid;
    v_doc_type_id uuid;
    v_country_id uuid;
    v_doc_num varchar(64);
BEGIN
    -- 1. Obtener datos necesarios
    SELECT person_id INTO v_person_id FROM person LIMIT 1;
    SELECT document_type_id INTO v_doc_type_id FROM document_type LIMIT 1;
    SELECT country_id INTO v_country_id FROM country LIMIT 1;

    IF v_person_id IS NULL OR v_doc_type_id IS NULL OR v_country_id IS NULL THEN
        RAISE NOTICE 'v_person_id: %, v_doc_type_id: %, v_country_id: %', v_person_id, v_doc_type_id, v_country_id;
        RAISE EXCEPTION 'No se encontraron datos base suficientes para la prueba de identidad.';
    END IF;

    v_doc_num := 'DOC-' || upper(replace(left(gen_random_uuid()::text, 12), '-', ''));
    RAISE NOTICE 'Registrando documento con número: %', v_doc_num;

    -- 2. Invocar procedimiento (dispara el trigger)
    CALL sp_register_person_document(
        v_person_id,
        v_doc_type_id,
        v_country_id,
        v_doc_num,
        (current_date - interval '1 year')::date,
        (current_date + interval '5 years')::date
    );

    RAISE NOTICE 'Documento % registrado para la persona %', v_doc_num, v_person_id;
END;
$$;

-- 3. Verificación
SELECT 
    p.first_name || ' ' || p.last_name AS person_name,
    p.updated_at AS person_last_update,
    pd.document_number,
    dt.type_name AS document_type,
    pd.expires_on
FROM person p
INNER JOIN person_document pd ON pd.person_id = p.person_id
INNER JOIN document_type dt ON dt.document_type_id = pd.document_type_id
WHERE pd.document_number LIKE 'DOC-%'
ORDER BY pd.created_at DESC
LIMIT 1;
```

---

## 12. Validación final
La solución es válida porque:
- Implementa una consulta de identidad completa vinculada a la actividad comercial.
- Garantiza la trazabilidad de los datos maestros de la persona mediante el trigger.
- Respeta estrictamente la estructura y nombres del modelo de 76 tablas.

---

## 13. Archivo SQL relacionado
- `scripts_sql/ejercicio_10_setup.sql`
- `scripts_sql/ejercicio_10_demo.sql`
