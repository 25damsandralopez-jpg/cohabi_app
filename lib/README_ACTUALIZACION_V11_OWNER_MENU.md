# Cohabi v11 — Menú y dashboard del propietario

Esta actualización reorganiza la navegación owner para seguir la estructura del diseño de referencia.

## Menú principal

1. Inicio
2. Pisos
3. Selección
4. Inquilinos
5. Incidencias
6. Rentabilidad
7. Cuenta

`Solicitudes` y `Visitas` dejan de ser pestañas separadas. El flujo de candidatos, validación y visitas queda agrupado dentro de **Selección**.

## Cambios funcionales

- Nuevo `OwnerHomeScreen` con métricas reales de Supabase: pisos, habitaciones, disponibles, ingresos mensuales de habitaciones ocupadas, candidatos activos y visitas confirmadas.
- `Pisos` mantiene el dashboard/listado actual de propiedades.
- `Selección` abre el módulo de candidatos ya creado en v10: perfil completo, validación y propuesta de visita con calendario.
- Nuevo `Inquilinos`: muestra solicitudes aceptadas como inquilinos actuales/futuros.
- Nuevo `Incidencias`: queda como módulo preparado para el siguiente desarrollo.
- Nuevo `Rentabilidad`: primera vista real con ingresos mensuales y ocupación calculados desde `rooms`.
- `Cuenta` pasa a índice 6.
- Login owner y activación del modo owner entran ahora en `OwnerHomeScreen`.

## No requiere SQL nuevo

Esta versión reutiliza el esquema v9/v10. No ejecutes migraciones adicionales para instalar este parche.

## Instalación

Copia las carpetas del parche sobre tu `lib/` respetando la estructura. Si utilizas el ZIP de proyecto completo, sustituye los archivos equivalentes del proyecto actual.

Después ejecuta:

```bash
flutter clean
flutter pub get
flutter run
```

## Flujo esperado

Owner inicia sesión → Inicio → Pisos / Selección / Inquilinos / Incidencias / Rentabilidad / Cuenta.

En Selección: candidato → perfil completo → validar → proponer visita → calendario → fechas/horas.
