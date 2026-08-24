# Cohabi Selección - resultados v5

## Flujo
- Tenant abre Selección.
- Si su perfil de Selección no está completo, continúa el cuestionario.
- Si está completo, entra directamente en `TenantBestMatchesScreen`.
- La pantalla carga propiedades `published` y habitaciones `Disponible`.
- El ranking actual usa ciudad, presupuesto, fecha, WiFi y amueblado.
- El porcentaje mostrado representa encaje con la búsqueda disponible hoy, no compatibilidad real con compañeros todavía.

## Nuevos datos
- `tenant_favorites`: favoritos tenant por habitación.
- `applications`: solicitudes de interés por habitación.

## Siguiente evolución
Cuando exista información de ocupantes/tenancies, el score puede incorporar compatibilidad de convivencia real (horarios, limpieza, hobbies, ambiente, etc.).
