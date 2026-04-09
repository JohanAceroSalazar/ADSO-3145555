# ADR-001: Uso de UUID como Clave Primaria

## Estado

Aprobado

## Contexto

Se requiere un identificador único para todas las entidades del sistema distribuido de aerolínea.

## Decisión

Se utilizarán UUID generados con `gen_random_uuid()` como clave primaria en todas las tablas.

## Alternativas

* INT autoincremental
* BIGINT

## Justificación

* Evita colisiones en entornos distribuidos
* No expone información sensible (IDs no predecibles)
* Facilita integración entre sistemas

## Consecuencias

### Positivas

* Escalabilidad
* Seguridad

### Negativas

* Menor rendimiento en índices
* Menor legibilidad