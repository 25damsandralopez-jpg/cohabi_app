# Archivos generados para el refactor

## Theme
- `lib/core/theme/app_spacing.dart`
- `lib/core/theme/app_radius.dart`
- `lib/core/theme/app_text_styles.dart`
- `lib/core/theme/theme.dart`

## Widgets compartidos
- `lib/core/widgets/cohabi_card.dart`
- `lib/core/widgets/cohabi_primary_button.dart`
- `lib/core/widgets/cohabi_text_field.dart`
- `lib/core/widgets/cohabi_dropdown.dart`
- `lib/core/widgets/cohabi_checkbox_card.dart`
- `lib/core/widgets/cohabi_snackbar.dart`
- `lib/core/widgets/cohabi_step_indicator.dart`
- `lib/core/widgets/cohabi_section_header.dart`
- `lib/core/widgets/cohabi_bottom_navigation.dart`
- `lib/core/widgets/widgets.dart`

## Servicios
- `lib/core/services/auth_service.dart`
- `lib/core/services/profile_service.dart`
- `lib/features/account/models/account_state.dart`
- `lib/features/account/services/account_service.dart`

## Propiedades
- `lib/features/properties/widgets/property_step_indicator.dart`
- `lib/features/properties/widgets/property_continue_button.dart`
- `lib/features/properties/widgets/photo_upload_card.dart`
- `lib/features/properties/widgets/tips_card.dart`

## Supabase
- `supabase/migrations/20260821_multimode_accounts.sql`

## Documentación
- `docs/ARCHITECTURE.md` actualizado a cuenta multimodo.
- `docs/REFACTOR_GUIDE.md` con el orden recomendado.

## Corrección aplicada
- Corregido el import de `app_colors.dart` en `tenant_home_screen.dart`.

Este paquete corresponde a la base segura del refactor. Las pantallas funcionales actuales se mantienen para no cambiar comportamiento y pueden migrarse progresivamente a estos componentes compartidos.
