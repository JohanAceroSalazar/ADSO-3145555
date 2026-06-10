# Módulo de Parametrización – Catálogos Base

## Introducción

El módulo de Parametrización y Catálogos Base es el núcleo de configuración del Sistema de Horarios SENA. Su función principal es centralizar y administrar todos los datos maestros y configuraciones utilizadas por los demás módulos del sistema.

Este módulo permite que la información institucional, académica y operativa pueda ser administrada sin necesidad de modificar el código fuente de la aplicación, garantizando flexibilidad, escalabilidad, reutilización y estandarización de la información.

Gracias a este módulo es posible configurar elementos como:

- Modalidades de formación.
- Jornadas académicas.
- Estados del sistema.
- Líneas tecnológicas.
- Redes de conocimiento.
- Tipos de ambientes.
- Parámetros globales.
- Límites de capacidad.
- Mensajes de error.
- Integraciones entre módulos.
- Auditoría de cambios.

---

# 1. Tabla CATALOGO

## Descripción

La tabla `CATALOGO` almacena los diferentes tipos de catálogos que serán utilizados por el sistema.

Un catálogo funciona como un contenedor de información.

Por ejemplo:

### Catálogo Modalidades

```text
Presencial
Virtual
Mixta
A Distancia
```

### Catálogo Jornadas

```text
Mañana
Tarde
Noche
Fin de Semana
```

### Catálogo Estados

```text
Activo
Inactivo
Suspendido
Finalizado
```

---

## Atributos

| Atributo            | Descripción                                     |
| ------------------- | ------------------------------------------------ |
| id_catalogo         | Identificador único del catálogo               |
| codigo              | Código interno del catálogo                    |
| nombre              | Nombre del catálogo                             |
| descripcion         | Explicación del propósito del catálogo        |
| activo              | Indica si el catálogo está disponible para uso |
| fecha_creacion      | Fecha en que fue creado                          |
| fecha_actualizacion | Fecha de la última modificación                |

---

## Ejemplos

```text
MOD → Modalidades de Formación
JOR → Jornadas Académicas
LIN → Líneas Tecnológicas
RED → Redes de Conocimiento
```

---

# 2. Tabla CATALOGO_DETALLE

## Descripción

Almacena los valores específicos pertenecientes a un catálogo.

Es la tabla donde realmente se guardan los datos que serán utilizados por otros módulos.

---

## Ejemplo

Catálogo:

```text
Modalidades de Formación
```

Detalles:

```text
Presencial
Virtual
Mixta
```

---

## Atributos

| Atributo            | Descripción                      |
| ------------------- | --------------------------------- |
| id_detalle          | Identificador único del detalle  |
| id_catalogo         | Catálogo al que pertenece        |
| id_estado           | Estado actual del registro        |
| codigo              | Código único del valor          |
| nombre              | Nombre visible                    |
| descripcion         | Descripción detallada            |
| orden_visualizacion | Orden en que aparecerá en listas |
| vigencia_inicio     | Fecha desde la cual es válido    |
| vigencia_fin        | Fecha hasta la cual será válido |
| fecha_creacion      | Fecha de creación                |
| fecha_actualizacion | Fecha de modificación            |

---

## Atributos importantes

### orden_visualizacion

Permite definir el orden en el que se mostrarán los valores.

Ejemplo:

```text
1 → Presencial
2 → Virtual
3 → Mixta
```

---

### vigencia_inicio y vigencia_fin

Permiten controlar si un valor puede utilizarse durante un período específico.

Ejemplo:

```text
Programa vigente:
01/01/2026 - 31/12/2026
```

---

# 3. Tabla ESTADO

## Descripción

Permite centralizar los estados utilizados por todo el sistema.

En lugar de crear estados diferentes para cada módulo, todos reutilizan esta tabla.

---

## Ejemplos

### Aprendices

```text
Activo
Deserción
Retiro Voluntario
Egresado
```

### Instructores

```text
Activo
Licencia
Vacaciones
Retirado
```

### Horarios

```text
Planeado
Asignado
Finalizado
```

---

## Atributos

| Atributo       | Descripción                         |
| -------------- | ------------------------------------ |
| id_estado      | Identificador único                 |
| codigo         | Código del estado                   |
| nombre         | Nombre del estado                    |
| descripcion    | Explicación del estado              |
| color_visual   | Color utilizado en interfaces        |
| activo         | Indica si el estado puede utilizarse |
| fecha_creacion | Fecha de creación                   |

---

## Atributo importante

### color_visual

Permite representar visualmente cada estado.

Ejemplo:

```text
Activo → Verde
Inactivo → Gris
Suspendido → Rojo
```

---

# 4. Tabla MODULO

## Descripción

Representa cada módulo existente dentro del sistema.

Sirve para relacionar configuraciones específicas con cada área funcional.

---

## Ejemplos

```text
Aprendices
Instructores
Horarios
Ambientes
Programas
Proyectos Formativos
```

---

## Atributos

| Atributo       | Descripción         |
| -------------- | -------------------- |
| id_modulo      | Identificador único |
| codigo         | Código del módulo  |
| nombre         | Nombre del módulo   |
| descripcion    | Función del módulo |
| version        | Versión actual      |
| activo         | Estado del módulo   |
| fecha_creacion | Fecha de registro    |

---

# 5. Tabla MODULO_CATALOGO

## Descripción

Permite asociar qué catálogos utiliza cada módulo.

Funciona como una tabla puente.

---

## Ejemplo

```text
Módulo Aprendices
    |
    ├── Estados
    ├── Tipo Documento
    ├── Jornada
```

---

## Atributos

| Atributo           | Descripción                  |
| ------------------ | ----------------------------- |
| id_modulo_catalogo | Identificador                 |
| id_modulo          | Módulo relacionado           |
| id_catalogo        | Catálogo asignado            |
| fecha_asignacion   | Fecha de asignación          |
| observacion        | Comentarios de la asignación |

---

# 6. Tabla PARAMETRO

## Descripción

Es una de las tablas más importantes del sistema.

Permite almacenar configuraciones globales utilizadas por todos los módulos.

---

## Ejemplos

```text
MAX_APRENDICES_FICHA = 35

MAX_HORAS_INSTRUCTOR = 40

MAX_MB_ARCHIVO = 100

AUTOGUARDADO_CANVAS = TRUE
```

---

## Atributos

| Atributo            | Descripción                |
| ------------------- | --------------------------- |
| id_parametro        | Identificador               |
| id_modulo           | Módulo propietario         |
| id_estado           | Estado del parámetro       |
| codigo              | Código único              |
| nombre              | Nombre                      |
| valor               | Valor configurado           |
| tipo_dato           | Tipo del valor              |
| valor_minimo        | Límite inferior permitido  |
| valor_maximo        | Límite superior permitido  |
| editable            | Indica si puede modificarse |
| descripcion         | Explicación                |
| fecha_creacion      | Fecha creación             |
| fecha_actualizacion | Fecha actualización        |

---

## Atributos importantes

### tipo_dato

Permite validar el valor.

Ejemplo:

```text
NUMERO
BOOLEAN
TEXTO
FECHA
```

---

### editable

Permite controlar si un parámetro puede ser modificado por los administradores.

---

# 7. Tabla ERROR_SISTEMA

## Descripción

Permite parametrizar los mensajes de error del sistema.

Evita que los errores estén escritos directamente en el código.

---

## Ejemplos

```text
ERR001
Capacidad máxima alcanzada

ERR002
Archivo excede tamaño permitido

ERR003
Instructor no disponible
```

---

## Atributos

| Atributo          | Descripción          |
| ----------------- | --------------------- |
| id_error          | Identificador         |
| id_modulo         | Módulo relacionado   |
| id_estado         | Estado del error      |
| codigo_error      | Código único        |
| mensaje           | Mensaje mostrado      |
| descripcion       | Explicación técnica |
| criticidad        | Nivel de gravedad     |
| solucion_sugerida | Acción recomendada   |
| fecha_creacion    | Fecha creación       |

---

## criticidad

Puede tomar valores como:

```text
BAJA
MEDIA
ALTA
CRITICA
```

---

# 8. Tabla SERVICIO_API

## Descripción

Permite registrar y administrar los servicios que utilizarán los módulos para intercambiar información.

Es la base para la comunicación entre módulos.

---

## Ejemplos

```text
API Aprendices

API Horarios

API Instructores
```

---

## Atributos

| Atributo         | Descripción             |
| ---------------- | ------------------------ |
| id_servicio      | Identificador            |
| id_modulo        | Módulo propietario      |
| nombre           | Nombre del servicio      |
| url_base         | Dirección principal     |
| metodo_http      | Método HTTP             |
| descripcion      | Explicación             |
| timeout_segundos | Tiempo máximo de espera |
| activo           | Estado                   |
| fecha_creacion   | Fecha creación          |

---

## metodo_http

Ejemplos:

```text
GET
POST
PUT
DELETE
```

---

# 9. Tabla AUDITORIA

## Descripción

Permite registrar todos los cambios realizados en el sistema.

Es fundamental para la trazabilidad y control institucional.

---

## Ejemplos

```text
Usuario:
Administrador

Acción:
Actualizar Modalidad

Valor anterior:
Virtual

Valor nuevo:
Virtual Sincrónica
```

---

## Atributos

| Atributo         | Descripción                   |
| ---------------- | ------------------------------ |
| id_auditoria     | Identificador                  |
| id_usuario       | Usuario que realizó el cambio |
| entidad_afectada | Tabla modificada               |
| id_registro      | Registro afectado              |
| accion           | Acción realizada              |
| valor_anterior   | Información previa            |
| valor_nuevo      | Información nueva             |
| fecha_evento     | Fecha del evento               |
| ip_origen        | Dirección IP del usuario      |

---

# Integración con los demás módulos

La parametrización es un módulo transversal que suministra información a todos los demás componentes del sistema.

## Módulo Aprendices

Consume:

- Estados
- Tipos de documento
- Parámetros de matrícula
- Deserción
- Retiro voluntario

---

## Módulo Instructores

Consume:

- Estados
- Roles
- Disponibilidad
- Carga horaria máxima

---

## Módulo Horarios

Consume:

- Jornadas
- Bloques horarios
- Restricciones
- Estados

---

## Módulo Ambientes

Consume:

- Tipos de ambiente
- Capacidad máxima
- Estados

---

## Módulo Programas de Formación

Consume:

- Modalidades
- Tipos de formación
- Líneas tecnológicas
- Redes de conocimiento

---

## Módulo Gestión Documental

Consume:

- Tamaño máximo de archivos
- Cantidad máxima de archivos
- Tipos de archivos permitidos

---

## Módulo Canvas

Consume:

- Configuración de autoguardado
- Tiempo de sesión
- Límites de elementos

---

## Módulo Proyectos Formativos

Consume:

- Estados
- Parámetros de seguimiento
- Configuración de entregables

---

# Conclusión

El módulo de Parametrización y Catálogos Base constituye la base de funcionamiento del Sistema de Horarios SENA. Su objetivo es centralizar la configuración institucional, académica y operativa, permitiendo que los demás módulos trabajen de forma estandarizada, flexible y escalable, garantizando además la trazabilidad y el control de todos los cambios realizados en el sistema.
