# Cohabi Selección — Tenant

## Flujo

1. Entrada e ingresos
2. Experiencia compartiendo piso
3. Rutina diaria
4. Forma de convivir
5. Convivencia deseada, visitas y mascotas
6. Aficiones
7. Estilo de vida
8. Preferencias de compañeros

La pantalla `TenantSelectionScreen` guarda el progreso en Supabase al pulsar Continuar. Si el usuario abandona el flujo, vuelve al último paso guardado.

## Persistencia

Tabla: `public.tenant_selection_profiles`.

- Una fila por usuario tenant.
- `current_step` mantiene el progreso.
- `completed` indica si terminó el cuestionario.
- `completed_at` registra cuándo se completó.
- Arrays para hobbies, rasgos y valores de convivencia.

## Navegación

El botón `Selección` del menú tenant abre `TenantSelectionScreen`.

Cuando el perfil está completo, la misma pantalla muestra el estado final. La pantalla futura de resultados/matching se conectará al botón `Ver mis mejores opciones`.
