# Cohabi — Guía de refactor progresivo

El objetivo es reducir duplicación sin cambiar el comportamiento funcional de Cohabi.

## Fase 1 — Base compartida ✅

Incluidos:

- `core/theme/app_spacing.dart`
- `core/theme/app_radius.dart`
- `core/theme/app_text_styles.dart`
- `core/widgets/cohabi_card.dart`
- `core/widgets/cohabi_primary_button.dart`
- `core/widgets/cohabi_text_field.dart`
- `core/widgets/cohabi_dropdown.dart`
- `core/widgets/cohabi_checkbox_card.dart`
- `core/widgets/cohabi_snackbar.dart`
- `core/widgets/cohabi_step_indicator.dart`
- `core/widgets/cohabi_section_header.dart`
- `core/widgets/cohabi_bottom_navigation.dart`
- `core/services/auth_service.dart`
- `core/services/profile_service.dart`
- `features/account/services/account_service.dart`
- componentes comunes de propiedades.

## Fase 2 — Sustitución segura 🚧

### Ya refactorizado en v2

1. `account_screen.dart` ✅
   - lógica Supabase movida a `AccountService`
   - tarjetas separadas en `features/account/widgets/`
   - bottom navigation reutilizable
   - snackbar compartido
   - aproximadamente 1780 líneas → ~314 líneas

2. `enable_owner_profile_screen.dart` ✅
   - usa `AccountService`
   - usa `CohabiTextField`, `CohabiDropdown`, `CohabiPrimaryButton`, `CohabiCard`
   - aproximadamente 713 líneas → ~271 líneas

3. `enable_tenant_profile_screen.dart` ✅
   - usa `AccountService`
   - usa widgets compartidos
   - aproximadamente 893 líneas → ~357 líneas

4. `login_screen.dart` ✅ corrección arquitectura multimodo
   - lee `profiles.active_mode`
   - ya no depende de `profiles.role`

### Siguiente bloque

5. `owner_register_screen.dart`
6. `tenant_register_screen.dart`
7. flujo de propiedades
8. dashboards y homes

Después de sustituir una pantalla, ejecutar localmente:

```bash
flutter format lib
flutter analyze
flutter test
```

> El entorno donde se generó esta versión no dispone del SDK de Flutter, así que el análisis de Flutter debe ejecutarse al abrir el proyecto en tu equipo/CI.

## Fase 3 — Mover por features

Cuando las pantallas ya dependan de widgets y servicios compartidos, moverlas a:

```text
features/auth/screens
features/tenant/screens
features/owner/screens
features/account/screens
features/properties/screens
```

Mover antes de reducir dependencias solo crea cambios masivos de imports y conflictos de Git.

## Regla práctica

No refactorizar una pantalla y cambiar su comportamiento funcional al mismo tiempo. Primero mantener comportamiento, luego mejorar lógica.
