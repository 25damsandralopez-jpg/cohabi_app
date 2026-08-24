# Cohabi v6 · Flujo tenant desde Selección

## Flujo implementado

Selección → Todos los pisos/habitaciones disponibles → Ver piso → Me interesa → Interés enviado → Solicitudes.

## Estados de application

- `pending`: interés enviado.
- `under_review`: el propietario está revisando el perfil.
- `visit_proposed`: el propietario propone uno o varios horarios.
- `visit_confirmed`: el tenant seleccionó un horario.
- `visit_declined`: el tenant rechazó la propuesta de visita.
- `accepted`: habitación conseguida.
- `rejected`: propietario continúa con otro candidato.
- `withdrawn`: tenant retira la solicitud.

## Importante

La compatibilidad porcentual sigue desactivada. La pantalla de Selección muestra todas las habitaciones `Disponible` pertenecientes a propiedades `published`.
