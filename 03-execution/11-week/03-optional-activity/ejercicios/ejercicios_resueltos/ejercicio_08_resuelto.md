# Ejercicio 08 Resuelto - Control de acceso y trazabilidad de roles de seguridad

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
El equipo de seguridad de la aerolínea requiere auditar los accesos al sistema, cruzando la identidad real del individuo con su cuenta, roles de seguridad y los permisos específicos otorgados, además de automatizar la trazabilidad cuando se asigne un nuevo rol.

---

## 6. Dominios involucrados
### SECURITY
**Entidades:** `user_account`, `user_role`, `security_role`, `role_permission`, `security_permission`  
**Propósito en este ejercicio:** Gestionar cuentas de usuario, sus roles y los niveles de autorización en el sistema.

### IDENTITY
**Entidades:** `person`  
**Propósito en este ejercicio:** Identificar a la persona real detrás de la cuenta de usuario.

---

## 7. Problema a resolver
Se necesita consolidar la matriz de accesos de la organización para auditorías externas. Al mismo tiempo, el proceso de otorgamiento de roles debe ser rastreado para que la cuenta matriz deje registro temporal cada vez que sus privilegios cambien.

Por eso se plantea una solución en tres capas:
1. una consulta consolidada con `INNER JOIN` de auditoría.
2. un procedimiento almacenado para asignar roles de manera controlada.
3. un trigger `AFTER INSERT` sobre `user_role` para impactar la tabla de usuarios de forma auditable.

---

## 8. Solución propuesta

### 8.1 Consulta resuelta con `INNER JOIN`
La consulta centraliza quién es la persona, cómo accede (cuenta), qué rol ostenta y hasta dónde puede llegar con sus permisos.

```sql
SELECT
    p.first_name || ' ' || p.last_name AS nombre_persona,
    ua.username AS cuenta_usuario,
    sr.role_name AS rol_seguridad,
    ur.assigned_at AS fecha_asignacion,
    sp.permission_name AS permiso,
    sp.permission_description AS descripcion_permiso
FROM person p
INNER JOIN user_account ua ON ua.person_id = p.person_id
INNER JOIN user_role ur ON ur.user_account_id = ua.user_account_id
INNER JOIN security_role sr ON sr.security_role_id = ur.security_role_id
INNER JOIN role_permission rp ON rp.security_role_id = sr.security_role_id
INNER JOIN security_permission sp ON sp.security_permission_id = rp.security_permission_id
ORDER BY p.last_name, sr.role_name;
```

### 8.2 Explicación paso a paso de la consulta
1. **`person`** proporciona la capa física y personal (la identidad biográfica).
2. **`user_account`** proporciona la abstracción tecnológica (el login).
3. **`user_role`** es el conector intermedio que une al usuario con uno o más roles.
4. **`security_role`** tipifica las grandes agrupaciones de funciones (ej. Admin, Agente).
5. **`role_permission`** disgrega ese gran rol en la cantidad N de acciones granulares permitidas.
6. **`security_permission`** muestra el detalle exacto de qué puede hacer la persona (ej. `CREATE_FLIGHT`).

---

## 9. Procedimiento almacenado resuelto

### 9.1 Objetivo
Garantizar que no existan inserciones manuales de roles sin fecha explícita y prevenir duplicaciones de permisos.

### 9.2 Decisión técnica
El procedimiento almacena la inserción del rol, asignándole automáticamente la fecha de hoy. Se incluye validación de prevención de duplicados (ya que el modelo tiene llave compuesta/restricción implícita).

### 9.3 Script del procedimiento
```sql
DROP PROCEDURE IF EXISTS sp_assign_user_role(uuid, uuid);

CREATE OR REPLACE PROCEDURE sp_assign_user_role(
    p_user_account_id uuid,
    p_security_role_id uuid
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM user_role 
        WHERE user_account_id = p_user_account_id 
          AND security_role_id = p_security_role_id
    ) THEN
        RAISE EXCEPTION 'El rol ya se encuentra asignado a este usuario.';
    END IF;

    INSERT INTO user_role (
        user_account_id,
        security_role_id,
        assigned_at
    )
    VALUES (
        p_user_account_id,
        p_security_role_id,
        now()
    );
END;
$$;
```

### 9.4 Por qué esta solución es correcta
- Al centralizarse, se obliga a que todo cambio en los privilegios pase por la validación anti-duplicado.

---

## 10. Trigger resuelto

### 10.1 Decisión técnica
Se configuró un trigger `AFTER INSERT ON user_role`. Cuando cambian los privilegios de un empleado, su perfil en la tabla padre debe quedar con huella digital modificada para alertar a los administradores de red.

### 10.2 Lógica implementada
- Evalúa el `NEW.user_account_id`.
- Modifica el `updated_at` de `user_account` a la hora actual.

### 10.3 Script del trigger
```sql
DROP TRIGGER IF EXISTS trg_ai_user_role_touch_account ON user_role;
DROP FUNCTION IF EXISTS fn_ai_user_role_touch_account();

CREATE OR REPLACE FUNCTION fn_ai_user_role_touch_account()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE user_account
    SET updated_at = now()
    WHERE user_account_id = NEW.user_account_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_user_role_touch_account
AFTER INSERT ON user_role
FOR EACH ROW
EXECUTE FUNCTION fn_ai_user_role_touch_account();
```

### 10.4 Por qué esta solución es correcta
- Modificar el `updated_at` de una cuenta es el paso estándar en ciberseguridad para revocar o expirar sesiones (tokens JWT) tras un cambio drástico de permisos, obligando al usuario a re-autenticarse con sus nuevos permisos.

---

## 11. Script de demostración del funcionamiento

```sql
DO $$
DECLARE
    v_user_account_id uuid;
    v_security_role_id uuid;
BEGIN
    -- 1. Buscar una cuenta de usuario
    SELECT user_account_id INTO v_user_account_id FROM user_account LIMIT 1;

    -- 2. Buscar un rol que NO tenga asignado aún
    SELECT sr.security_role_id 
    INTO v_security_role_id 
    FROM security_role sr
    LEFT JOIN user_role ur ON ur.security_role_id = sr.security_role_id AND ur.user_account_id = v_user_account_id
    WHERE ur.user_account_id IS NULL
    LIMIT 1;

    IF v_user_account_id IS NULL OR v_security_role_id IS NULL THEN
        RAISE EXCEPTION 'No se encontraron datos para asignar un nuevo rol.';
    END IF;

    -- 3. Invocar procedimiento (dispara el trigger)
    CALL sp_assign_user_role(
        v_user_account_id,
        v_security_role_id
    );

    RAISE NOTICE 'Rol asignado exitosamente a la cuenta %', v_user_account_id;
END;
$$;

-- 4. Verificación de la trazabilidad en la cuenta de usuario
SELECT 
    ua.username,
    ua.updated_at AS cuenta_actualizada,
    sr.role_name,
    ur.assigned_at
FROM user_account ua
INNER JOIN user_role ur ON ur.user_account_id = ua.user_account_id
INNER JOIN security_role sr ON sr.security_role_id = ur.security_role_id
ORDER BY ur.assigned_at DESC
LIMIT 1;
```

### 11.1 Qué demuestra este script
1. Busca al vuelo una cuenta y un rol que el usuario todavía no tenga en su poder.
2. Efectúa la asignación a través de la capa segura (el procedimiento almacenado).
3. La prueba de validación confirma que el rol se guardó con la fecha actual y que la cuenta padre recibió una actualización temporal por obra del trigger.

---

## 12. Validación final
La solución es válida porque:
- Expone la información de seguridad usando el modelo de seis tablas sin incurrir en subconsultas (`INNER JOIN`).
- Consolida las lógicas transaccionales y de validación de negocio en la capa de base de datos de manera atómica.

---

## 13. Archivo SQL relacionado
- `scripts_sql/ejercicio_08_setup.sql`
- `scripts_sql/ejercicio_08_demo.sql`
