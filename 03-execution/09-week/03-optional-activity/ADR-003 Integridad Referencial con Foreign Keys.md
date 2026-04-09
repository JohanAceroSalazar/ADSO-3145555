# ADR-003: Integridad Referencial con Foreign Keys

## Estado

Aprobado

## Contexto

Se necesita garantizar relaciones consistentes entre entidades.

## Decisión

Uso intensivo de claves foráneas (FK).

## Alternativas

* Sin FK (validación en backend)

## Justificación

* Evita datos huérfanos
* Garantiza consistencia

## Consecuencias

### Positivas

* Integridad de datos

### Negativas

* Impacto en rendimiento si no se indexa