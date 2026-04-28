# Ejercicio 04 - Acumulación de millas y actualización del historial de nivel

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

## 4. Enfoque de los ejercicios
Los ejercicios planteados sobre este modelo tendrán como propósito que el estudiante analice relaciones reales entre entidades y construya soluciones en PostgreSQL sin alterar la estructura base del sistema.

Cada ejercicio se formulará para que el estudiante:
- interprete correctamente los dominios involucrados,
- construya consultas con múltiples relaciones,
- diseñe automatizaciones con triggers,
- implemente lógica reutilizable mediante procedimientos almacenados,
- y demuestre técnicamente el funcionamiento con scripts de prueba.

---

## 5. Restricción general para todos los ejercicios
Todos los ejercicios deben resolverse respetando estrictamente el modelo entregado.

No está permitido:
- cambiar atributos existentes,
- renombrar tablas o columnas,
- alterar relaciones,
- inventar entidades fuera del script base,
- ni modificar la estructura general del modelo.

La solución deberá construirse únicamente sobre las entidades y relaciones reales definidas en el script.

---

## 6. Contexto del ejercicio
El programa de fidelización de la aerolínea requiere consultar el comportamiento comercial del cliente y automatizar el registro de acumulación de millas o movimientos de nivel a partir de eventos definidos en la base de datos.

---

## 7. Dominios involucrados en este ejercicio
### CUSTOMER AND LOYALTY
**Entidades:** `customer`, `loyalty_account`, `loyalty_program`, `loyalty_tier`, `loyalty_account_tier`, `miles_transaction`, `customer_category`  
**Propósito:** Gestionar clientes, cuentas de fidelización, niveles y acumulación de millas.

### AIRLINE
**Entidades:** `airline`  
**Propósito:** Identificar la aerolínea propietaria del programa.

### IDENTITY
**Entidades:** `person`  
**Propósito:** Relacionar el cliente con la persona real.

### SALES, RESERVATION, TICKETING
**Entidades:** `reservation`, `sale`  
**Propósito:** Relacionar la actividad comercial con el cliente.

---

## 8. Planteamiento del problema
La aerolínea necesita analizar la relación entre clientes, ventas y cuentas de fidelización, y además automatizar un movimiento posterior en el programa de millas o en el historial de nivel.

---

## 9. Objetivo del ejercicio
Formular un ejercicio que conecte el flujo comercial con el programa de fidelización, mediante consulta multi-tabla, trigger posterior y procedimiento almacenado.

---

## 10. Requerimiento 1 - Consulta con `INNER JOIN` de al menos 5 tablas

### Enunciado
Construya una consulta SQL que relacione cliente, persona, cuenta de fidelización, programa, nivel actual o histórico y ventas asociadas.

### Restricciones obligatorias
- Debe usar **`INNER JOIN`**
- Debe involucrar **mínimo 5 tablas**
- Debe usar únicamente entidades y atributos existentes en el modelo base
- No se permite cambiar nombres de tablas ni columnas
- La consulta debe ser coherente con las relaciones reales del modelo

### Tablas mínimas sugeridas
El estudiante deberá incluir, como mínimo, una combinación válida de tablas como:
- `customer`
- `person`
- `loyalty_account`
- `loyalty_program`
- `loyalty_account_tier`
- `loyalty_tier`
- `sale`

### Resultado esperado a nivel funcional
La consulta debe permitir responder una necesidad como esta: “Mostrar qué clientes tienen cuenta de fidelización, a qué programa pertenecen, qué nivel registran y qué actividad comercial tienen asociada”.

### Campos esperados en el resultado
Como mínimo, el resultado debe exponer columnas equivalentes a:
- cliente
- persona asociada
- cuenta de fidelización
- programa
- nivel
- fecha de asignación del nivel
- venta relacionada o referencia comercial

> El estudiante define la consulta exacta, pero debe respetar estrictamente el modelo base.

---

## 11. Requerimiento 2 - Trigger `AFTER`

### Enunciado
Diseñe un trigger `AFTER INSERT` sobre `miles_transaction` o sobre otra tabla del dominio de fidelización que automatice una acción verificable en `loyalty_account_tier` o en la trazabilidad del programa.

### Condición funcional del trigger
Al registrarse un evento de acumulación o ajuste de millas, el trigger deberá ejecutar una acción posterior coherente con el comportamiento del programa definido por el estudiante.

### Restricciones del trigger
- Debe ser un trigger **`AFTER`**
- Debe operar sobre tablas reales del modelo
- No puede modificar atributos existentes del modelo base
- No puede cambiar la definición de las tablas originales
- La solución debe ser coherente con las relaciones reales entre las tablas involucradas

### Demostración obligatoria
El estudiante deberá entregar un **script de prueba** que dispare el trigger.

### Condición mínima de la demostración
El script de prueba debe:
1. Identificar o preparar los datos necesarios del modelo base
2. Ejecutar la operación que dispare el trigger
3. Verificar el efecto posterior generado por el trigger

> El estudiante deberá decidir cómo validar el resultado, siempre sobre entidades reales del modelo.

---

## 12. Requerimiento 3 - Procedimiento almacenado

### Enunciado
Diseñe un procedimiento almacenado que registre una transacción de millas para una cuenta de fidelización existente.

### Propósito del procedimiento
Encapsular la acumulación o ajuste de millas sobre una cuenta determinada y dejar el proceso listo para aplicar la lógica posterior del trigger.

### Alcance funcional mínimo
El procedimiento debe permitir trabajar con información relacionada con:
- cuenta de fidelización
- tipo de transacción
- cantidad de millas
- fecha del evento
- referencia o nota de soporte

### Restricciones obligatorias
- Debe implementarse como **procedimiento almacenado**
- Debe trabajar sobre tablas y atributos existentes
- No puede cambiar la estructura del modelo base
- Debe ser reutilizable
- Debe poder invocarse desde un script SQL independiente

### Integración esperada
La operación registrada por el procedimiento debe interactuar con el trigger y permitir verificar el efecto posterior sobre el historial de niveles o la lógica definida.

---

## 13. Script de uso del procedimiento

### Enunciado
El estudiante deberá entregar un script SQL que invoque el procedimiento almacenado desarrollado.

### Propósito del script
Demostrar que el procedimiento:
1. recibe los parámetros necesarios,
2. ejecuta la operación principal del ejercicio,
3. activa el trigger definido previamente o deja lista la evidencia para validarlo,
4. deja evidencia verificable del proceso.

### Contenido mínimo esperado
El script debe incluir:
- búsqueda o selección previa de identificadores necesarios
- invocación del procedimiento
- consulta posterior de validación

---

## 14. Entregables del estudiante
El estudiante deberá entregar:

1. **Consulta SQL** con `INNER JOIN` de mínimo 5 tablas  
2. **Trigger `AFTER`**  
3. **Función u objeto auxiliar necesario para el trigger**, si su diseño lo requiere  
4. **Procedimiento almacenado**  
5. **Script que dispare el trigger**  
6. **Script que invoque el procedimiento**  
7. **Consultas de validación** que demuestren el funcionamiento

---

## 15. Criterios de aceptación
La solución propuesta por el estudiante será válida si cumple con todo lo siguiente:

- La consulta utiliza `INNER JOIN`
- La consulta relaciona al menos 5 tablas reales del modelo
- El trigger es coherente con la necesidad del negocio
- El trigger produce un efecto verificable sobre tablas reales
- Existe un script que demuestra su ejecución
- El procedimiento almacenado encapsula una operación útil del negocio
- Existe un script que invoca el procedimiento
- La invocación del procedimiento permite evidenciar también el funcionamiento del trigger o del flujo solicitado
- No se alteró la estructura base del modelo

---

## 16. Observación final
Este ejercicio no solicita la solución final enunciada en el documento. El estudiante deberá diseñarla e implementarla respetando las restricciones técnicas del modelo base.

17. Solución propuesta
17.1 Consulta con INNER JOIN
Consulta
SELECT 
    c.customer_id,
    CONCAT(p.first_name, ' ', p.last_name) AS customer_name,
    la.loyalty_account_id,
    lp.program_name,
    lt.tier_name,
    lat.assigned_at,
    s.sale_id
FROM customer c
INNER JOIN person p 
    ON c.person_id = p.person_id
INNER JOIN loyalty_account la 
    ON c.customer_id = la.customer_id
INNER JOIN loyalty_program lp 
    ON la.loyalty_program_id = lp.loyalty_program_id
INNER JOIN loyalty_account_tier lat 
    ON la.loyalty_account_id = lat.loyalty_account_id
INNER JOIN loyalty_tier lt 
    ON lat.loyalty_tier_id = lt.loyalty_tier_id
INNER JOIN sale s 
    ON c.customer_id = s.customer_id;
Explicación
customer → cliente
person → datos personales
loyalty_account → cuenta de fidelización
loyalty_program → programa asociado
loyalty_account_tier → historial de niveles
loyalty_tier → nivel actual
sale → actividad comercial

✔ Más de 5 tablas
✔ INNER JOIN aplicado
✔ Trazabilidad cliente–fidelización–ventas

17.2 Trigger AFTER INSERT
Función
CREATE OR REPLACE FUNCTION fn_update_loyalty_tier()
RETURNS TRIGGER AS $$
DECLARE
    v_total_miles numeric;
BEGIN
    -- Calcular millas acumuladas
    SELECT COALESCE(SUM(miles_amount), 0)
    INTO v_total_miles
    FROM miles_transaction
    WHERE loyalty_account_id = NEW.loyalty_account_id;

    -- Regla simple de ejemplo de cambio de nivel
    IF v_total_miles > 50000 THEN
        INSERT INTO loyalty_account_tier (
            loyalty_account_id,
            loyalty_tier_id,
            assigned_at
        )
        VALUES (
            NEW.loyalty_account_id,
            (SELECT loyalty_tier_id FROM loyalty_tier LIMIT 1),
            now()
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
Trigger
CREATE TRIGGER trg_update_loyalty_tier
AFTER INSERT ON miles_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_update_loyalty_tier();
Explicación

Cuando se registra una transacción de millas:

Se recalcula el total acumulado
Si supera un umbral, se registra un nuevo nivel

✔ Automatiza evolución del cliente
✔ Evita cálculos manuales
✔ Mantiene historial de niveles

17.3 Procedimiento almacenado
CREATE OR REPLACE PROCEDURE sp_register_miles_transaction(
    p_loyalty_account_id uuid,
    p_transaction_type varchar,
    p_miles_amount numeric,
    p_description text
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO miles_transaction (
        loyalty_account_id,
        transaction_type,
        miles_amount,
        transaction_date,
        description
    )
    VALUES (
        p_loyalty_account_id,
        p_transaction_type,
        p_miles_amount,
        now(),
        p_description
    );
END;
$$;
Explicación
Registra acumulación o ajuste de millas
Centraliza la lógica
Dispara el trigger automáticamente
17.4 Script de prueba (Trigger)
INSERT INTO miles_transaction (
    loyalty_account_id,
    transaction_type,
    miles_amount,
    transaction_date
)
VALUES (
    (SELECT loyalty_account_id FROM loyalty_account LIMIT 1),
    'EARN',
    60000,
    now()
);
17.5 Uso del procedimiento
CALL sp_register_miles_transaction(
    (SELECT loyalty_account_id FROM loyalty_account LIMIT 1),
    'EARN',
    70000,
    'Acumulación por vuelo internacional'
);
17.6 Validación final
SELECT 
    la.loyalty_account_id,
    lt.tier_name,
    lat.assigned_at
FROM loyalty_account la
INNER JOIN loyalty_account_tier lat 
    ON la.loyalty_account_id = lat.loyalty_account_id
INNER JOIN loyalty_tier lt 
    ON lat.loyalty_tier_id = lt.loyalty_tier_id
ORDER BY lat.assigned_at DESC;
18. Resultado final

✔ Consulta con múltiples INNER JOIN
✔ Uso de más de 5 tablas
✔ Trigger AFTER INSERT funcional
✔ Procedimiento reutilizable
✔ Automatización de niveles de fidelización
✔ Validación comprobable

19. Archivos relacionados
setup.sql → trigger y procedimiento
demo.sql → pruebas
20. Conclusión

La solución permite:

Analizar la relación cliente–programa–ventas
Automatizar la acumulación de millas
Gestionar cambios de nivel automáticamente
Mantener trazabilidad del historial de fidelización