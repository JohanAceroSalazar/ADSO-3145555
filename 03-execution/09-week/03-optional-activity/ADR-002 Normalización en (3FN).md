# ADR-002: Normalización en Tercera Forma Normal (3FN)

## Estado

Aprobado

## Contexto

Se requiere evitar redundancia y mantener consistencia de datos.

## Decisión

Se implementa normalización hasta 3FN en todo el modelo.

## Alternativas

* Modelo desnormalizado
* 2FN

## Justificación

* Reduce duplicidad
* Mejora integridad de datos

## Consecuencias

### Positivas

* Datos consistentes
* Menos redundancia

### Negativas

* Mayor número de joins
* Consultas más complejas