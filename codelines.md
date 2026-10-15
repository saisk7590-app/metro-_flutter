# Code Lines Summary by Category

> **Note**: This file is maintained inside `metro_flutter/codelines.md` as the single source of truth for code line metrics and refactoring targets.

### Overview Metrics

- **Total Dart Files**: **166**
- **Screens (Rule: <= 300 lines)**: **19** files (19/19 passing, 0 warning)
- **Widgets (Rule: <= 700 lines)**: **81** files (81/81 passing, 0 warning)
- **Network, Services & Repositories (Services <= 500, Repos <= 200)**: **21** files (21/21 passing, 0 warning)
- **Providers & State Management (Rule: <= 500 lines)**: **13** files (13/13 passing, 0 warning)
- **Models & Data (Rule: <= 350 lines)**: **17** files (17/17 passing, 0 warning)
- **Architecture, Theme & Utilities (Rule: <= 250 lines)**: **15** files (15/15 passing, 0 warning)

---

## 1. Screens
*Target Rule: All screen files strictly <= 300 lines*

| # | File Name | Folder / Subfolder | Lines of Code | Status |
|---|---|---|---|---|
| 1 | `ams_update_screen.dart` | `screens/maintenance_bay` | **284** | Optimal Screen (<= 300) |
| 2 | `dashboard_screen.dart` | `screens/maintenance_bay` | **270** | Optimal Screen (<= 300) |
| 3 | `work_order_history_screen.dart` | `screens/checklist` | **269** | Optimal Screen (<= 300) |
| 4 | `login_screen.dart` | `screens/auth` | **266** | Optimal Screen (<= 300) |
| 5 | `checklist_screen.dart` | `screens/checklist` | **248** | Optimal Screen (<= 300) |
| 6 | `history_screen.dart` | `screens/maintenance_bay` | **245** | Optimal Screen (<= 300) |
| 7 | `forgot_password_screen.dart` | `screens/auth` | **233** | Optimal Screen (<= 300) |
| 8 | `wheel_measurement_form_screen.dart` | `screens/wheel_measurements` | **228** | Optimal Screen (<= 300) |
| 9 | `work_orders_screen.dart` | `screens/checklist` | **227** | Optimal Screen (<= 300) |
| 10 | `checksheet_detail_screen.dart` | `screens/checklist` | **227** | Optimal Screen (<= 300) |
| 11 | `profile_screen.dart` | `screens/profile` | **214** | Optimal Screen (<= 300) |
| 12 | `notification_screen.dart` | `screens/notifications` | **213** | Optimal Screen (<= 300) |
| 13 | `biometric_unlock_screen.dart` | `screens/auth` | **201** | Optimal Screen (<= 300) |
| 14 | `wheel_measurement_history_screen.dart` | `screens/wheel_measurements` | **168** | Optimal Screen (<= 300) |
| 15 | `mfa_verification_screen.dart` | `screens/auth` | **140** | Optimal Screen (<= 300) |
| 16 | `wheel_tolerances_screen.dart` | `screens/wheel_measurements` | **123** | Optimal Screen (<= 300) |
| 17 | `reset_password_screen.dart` | `screens/auth` | **122** | Optimal Screen (<= 300) |
| 18 | `role_selection_screen.dart` | `screens/auth` | **77** | Optimal Screen (<= 300) |
| 19 | `meter_dashboard_screen.dart` | `screens/meter` | **27** | Optimal Screen (<= 300) |

---

## 2. Widgets
*Target Rule: All widget files strictly <= 700 lines (target <= 500)*

| # | File Name | Folder / Subfolder | Lines of Code | Status |
|---|---|---|---|---|
| 1 | `ams_update_popup.dart` | `widgets/popups` | **624** | Optimal Widget (<= 700) |
| 2 | `trainset_table.dart` | `widgets/meter` | **470** | Widget (< 500) |
| 3 | `depot_map.dart` | `widgets/map` | **467** | Widget (< 500) |
| 4 | `allocation_popup.dart` | `widgets/popups` | **457** | Widget (< 500) |
| 5 | `meter_bottom_sheet.dart` | `widgets/meter` | **382** | Widget (< 500) |
| 6 | `ams_update_form_rows.dart` | `widgets/maintenance_bay` | **342** | Widget (< 500) |
| 7 | `ams_update_controller.dart` | `widgets/maintenance_bay` | **328** | Widget (< 500) |
| 8 | `config_checklist_table.dart` | `widgets/checklist` | **327** | Widget (< 500) |
| 9 | `website_date_picker.dart` | `widgets/meter` | **318** | Widget (< 500) |
| 10 | `trainset_row.dart` | `widgets/meter` | **312** | Widget (< 500) |
| 11 | `checklist_item_controls.dart` | `widgets/checklist` | **311** | Widget (< 500) |
| 12 | `wheel_form_widgets.dart` | `widgets/wheel_measurements` | **299** | Modular Widget (< 300) |
| 13 | `add_edit_checklist_dialog.dart` | `widgets/checklist/dialogs` | **289** | Modular Widget (< 300) |
| 14 | `pagination_bar.dart` | `widgets/meter` | **277** | Modular Widget (< 300) |
| 15 | `meter_details.dart` | `widgets/meter` | **271** | Modular Widget (< 300) |
| 16 | `config_checklist_card.dart` | `widgets/checklist` | **268** | Modular Widget (< 300) |
| 17 | `ams_update_history_widgets.dart` | `widgets/maintenance_bay` | **262** | Modular Widget (< 300) |
| 18 | `history_widgets.dart` | `widgets/maintenance_bay` | **261** | Modular Widget (< 300) |
| 19 | `wheel_history_widgets.dart` | `widgets/wheel_measurements` | **258** | Modular Widget (< 300) |
| 20 | `add_checklist_group_item_dialog.dart` | `widgets/checklist/dialogs` | **251** | Modular Widget (< 300) |
| 21 | `ams_update_details_rows.dart` | `widgets/maintenance_bay` | **248** | Modular Widget (< 300) |
| 22 | `profile_header_card.dart` | `widgets/profile` | **248** | Modular Widget (< 300) |
| 23 | `config_checklist_filters.dart` | `widgets/checklist` | **248** | Modular Widget (< 300) |
| 24 | `checklist_item_card.dart` | `widgets/checklist` | **238** | Modular Widget (< 300) |
| 25 | `wheel_tolerance_widgets.dart` | `widgets/wheel_measurements` | **231** | Modular Widget (< 300) |
| 26 | `work_order_card.dart` | `widgets/checklist` | **223** | Modular Widget (< 300) |
| 27 | `sidebar_header.dart` | `widgets/sidebar` | **216** | Modular Widget (< 300) |
| 28 | `edit_checklist_group_item_dialog.dart` | `widgets/checklist/dialogs` | **216** | Modular Widget (< 300) |
| 29 | `depot_bay_markers_layer.dart` | `widgets/map` | **215** | Modular Widget (< 300) |
| 30 | `edit_checklist_group_dialog.dart` | `widgets/checklist/dialogs` | **215** | Modular Widget (< 300) |
| 31 | `ams_update_popup_history.dart` | `widgets/popups` | **214** | Modular Widget (< 300) |
| 32 | `custom_dropdown.dart` | `widgets/common` | **214** | Modular Widget (< 300) |
| 33 | `bay_allocation_table.dart` | `widgets/map` | **210** | Modular Widget (< 300) |
| 34 | `meter_progress_card.dart` | `widgets/meter` | **202** | Modular Widget (< 300) |
| 35 | `add_checklist_group_dialog.dart` | `widgets/checklist/dialogs` | **200** | Modular Widget (< 300) |
| 36 | `wheel_entry_column.dart` | `widgets/wheel_measurements` | **195** | Modular Widget (< 300) |
| 37 | `biometric_widgets.dart` | `widgets/auth` | **193** | Modular Widget (< 300) |
| 38 | `add_edit_checklist_fields.dart` | `widgets/checklist/dialogs` | **183** | Modular Widget (< 300) |
| 39 | `checklist_group_header.dart` | `widgets/checklist` | **183** | Modular Widget (< 300) |
| 40 | `forgot_password_forms.dart` | `widgets/auth` | **175** | Modular Widget (< 300) |
| 41 | `wheel_axle_card.dart` | `widgets/wheel_measurements` | **169** | Modular Widget (< 300) |
| 42 | `ams_update_card.dart` | `widgets/maintenance_bay` | **167** | Modular Widget (< 300) |
| 43 | `ams_popup_form_fields.dart` | `widgets/popups` | **160** | Modular Widget (< 300) |
| 44 | `notification_item_card.dart` | `widgets/notifications` | **150** | Modular Widget (< 300) |
| 45 | `profile_info_tiles.dart` | `widgets/profile` | **145** | Modular Widget (< 300) |
| 46 | `checksheet_header_widgets.dart` | `widgets/checklist` | **140** | Modular Widget (< 300) |
| 47 | `edit_profile_dialog.dart` | `widgets/profile` | **136** | Modular Widget (< 300) |
| 48 | `notification_filter_bar.dart` | `widgets/notifications` | **136** | Modular Widget (< 300) |
| 49 | `section_buttons.dart` | `widgets/map` | **131** | Modular Widget (< 300) |
| 50 | `meter_validation.dart` | `widgets/meter` | **129** | Modular Widget (< 300) |
| 51 | `custom_header.dart` | `widgets/common` | **125** | Modular Widget (< 300) |
| 52 | `profile_detail_sections.dart` | `widgets/profile` | **123** | Modular Widget (< 300) |
| 53 | `edit_checklist_name_dialog.dart` | `widgets/checklist/dialogs` | **120** | Modular Widget (< 300) |
| 54 | `login_form.dart` | `widgets/auth/login` | **98** | Modular Widget (< 300) |
| 55 | `ams_update_popup_header.dart` | `widgets/popups` | **95** | Modular Widget (< 300) |
| 56 | `custom_input.dart` | `widgets/common` | **95** | Modular Widget (< 300) |
| 57 | `custom_button.dart` | `widgets/common` | **95** | Modular Widget (< 300) |
| 58 | `date_search_bar.dart` | `widgets/meter` | **93** | Modular Widget (< 300) |
| 59 | `save_cancel_bar.dart` | `widgets/meter` | **92** | Modular Widget (< 300) |
| 60 | `wheel_record_detail_sheet.dart` | `widgets/wheel_measurements` | **89** | Modular Widget (< 300) |
| 61 | `sidebar_module_tile.dart` | `widgets/sidebar` | **88** | Modular Widget (< 300) |
| 62 | `status_chip.dart` | `widgets/meter` | **86** | Modular Widget (< 300) |
| 63 | `checklist_empty_state.dart` | `widgets/checklist` | **76** | Modular Widget (< 300) |
| 64 | `map_zoom_controls.dart` | `widgets/map` | **76** | Modular Widget (< 300) |
| 65 | `depot_cad_background.dart` | `widgets/map` | **76** | Modular Widget (< 300) |
| 66 | `items_per_page_dropdown.dart` | `widgets/meter` | **74** | Modular Widget (< 300) |
| 67 | `depot_map_header.dart` | `widgets/map` | **73** | Modular Widget (< 300) |
| 68 | `ams_update_popup_footer.dart` | `widgets/popups` | **67** | Modular Widget (< 300) |
| 69 | `meter_expansion_tile.dart` | `widgets/meter` | **58** | Modular Widget (< 300) |
| 70 | `sidebar_logout.dart` | `widgets/sidebar` | **45** | Modular Widget (< 300) |
| 71 | `security_notice.dart` | `widgets/auth/login` | **44** | Modular Widget (< 300) |
| 72 | `login_logo.dart` | `widgets/auth/login` | **40** | Modular Widget (< 300) |
| 73 | `delete_checklist_dialog.dart` | `widgets/checklist` | **36** | Modular Widget (< 300) |
| 74 | `map_touch_hint.dart` | `widgets/map` | **33** | Modular Widget (< 300) |
| 75 | `login_header.dart` | `widgets/auth/login` | **33** | Modular Widget (< 300) |
| 76 | `header_icon.dart` | `widgets/sidebar` | **25** | Modular Widget (< 300) |
| 77 | `responsive_container.dart` | `widgets/common` | **24** | Modular Widget (< 300) |
| 78 | `developer_marker.dart` | `widgets/map` | **23** | Modular Widget (< 300) |
| 79 | `developer_panel.dart` | `widgets/map` | **22** | Modular Widget (< 300) |
| 80 | `forgot_password_link.dart` | `widgets/auth/login` | **20** | Modular Widget (< 300) |
| 81 | `checklist_forms.dart` | `widgets/checklist` | **9** | Modular Widget (< 300) |

---

## 3. Network, Services & Repositories
*Target Rule: Services <= 500 lines (target <= 400), Repositories <= 200 lines*

| # | File Name | Folder / Subfolder | Lines of Code | Status |
|---|---|---|---|---|
| 1 | `api_service.dart` | `services` | **493** | Acceptable Service (<= 500) |
| 2 | `checklist_config_api_service.dart` | `services/checklist` | **423** | Acceptable Service (<= 500) |
| 3 | `maintenance_bay_api_service.dart` | `services/maintenance_bay` | **367** | Optimal Service (<= 400) |
| 4 | `auth_api_service.dart` | `services/auth` | **237** | Optimal Service (<= 400) |
| 5 | `meter_reading_api_service.dart` | `services/meter` | **219** | Optimal Service (<= 400) |
| 6 | `base_api_service.dart` | `services` | **203** | Optimal Service (<= 400) |
| 7 | `checklist_api_service.dart` | `services/checklist` | **158** | Optimal Service (<= 400) |
| 8 | `lookups_api_service.dart` | `services/maintenance_bay` | **119** | Optimal Service (<= 400) |
| 9 | `wheel_measurement_api_service.dart` | `services/wheel` | **109** | Optimal Service (<= 400) |
| 10 | `maintenance_bay_repository.dart` | `repositories/maintenance_bay` | **109** | Optimal Repository (<= 200) |
| 11 | `notification_api_service.dart` | `services/notifications` | **99** | Optimal Service (<= 400) |
| 12 | `biometric_auth_service.dart` | `services/auth` | **72** | Optimal Service (<= 400) |
| 13 | `http_client_runner_io.dart` | `root` | **67** | HTTP Client Runner |
| 14 | `trainset_meter_reading_repository.dart` | `repositories/meter` | **67** | Optimal Repository (<= 200) |
| 15 | `staff_profile_api_service.dart` | `services/auth` | **52** | Optimal Service (<= 400) |
| 16 | `login_repository.dart` | `repositories/auth` | **37** | Optimal Repository (<= 200) |
| 17 | `train_repository.dart` | `repositories/maintenance_bay` | **18** | Optimal Repository (<= 200) |
| 18 | `http_client_runner.dart` | `root` | **17** | HTTP Client Runner |
| 19 | `http_client_runner_stub.dart` | `root` | **12** | HTTP Client Runner |
| 20 | `maintenance_purpose_repository.dart` | `repositories/maintenance_bay` | **10** | Optimal Repository (<= 200) |
| 21 | `status_repository.dart` | `repositories/maintenance_bay` | **10** | Optimal Repository (<= 200) |

---

## 4. Providers & State Management
*Target Rule: State management & ChangeNotifier strictly <= 500 lines (target <= 400)*

| # | File Name | Folder / Subfolder | Lines of Code | Status |
|---|---|---|---|---|
| 1 | `checklist_provider.dart` | `providers/checklist` | **380** | Optimal Provider (<= 400) |
| 2 | `maintenance_bay_provider.dart` | `providers/maintenance_bay` | **326** | Optimal Provider (<= 400) |
| 3 | `checklist_crud_mixin.dart` | `providers/checklist` | **315** | Optimal Provider (<= 400) |
| 4 | `login_provider.dart` | `providers/auth` | **221** | Optimal Provider (<= 400) |
| 5 | `checklist_config_mixin.dart` | `providers/checklist` | **175** | Optimal Provider (<= 400) |
| 6 | `trainset_meter_reading_provider.dart` | `providers/meter` | **102** | Optimal Provider (<= 400) |
| 7 | `notification_provider.dart` | `providers/notifications` | **88** | Optimal Provider (<= 400) |
| 8 | `profile_provider.dart` | `providers/auth` | **74** | Optimal Provider (<= 400) |
| 9 | `active_trains_provider.dart` | `providers/maintenance_bay` | **68** | Optimal Provider (<= 400) |
| 10 | `allocation_provider.dart` | `providers/maintenance_bay` | **44** | Optimal Provider (<= 400) |
| 11 | `train_provider.dart` | `providers/maintenance_bay` | **38** | Optimal Provider (<= 400) |
| 12 | `maintenance_purpose_provider.dart` | `providers/maintenance_bay` | **30** | Optimal Provider (<= 400) |
| 13 | `status_provider.dart` | `providers/maintenance_bay` | **29** | Optimal Provider (<= 400) |

---

## 5. Models & Data
*Target Rule: DTOs, models & static data schemas strictly <= 350 lines*

| # | File Name | Folder / Subfolder | Lines of Code | Status |
|---|---|---|---|---|
| 1 | `checklist_model.dart` | `models/checklist` | **321** | Optimal Model (<= 350) |
| 2 | `checklist_default_data.dart` | `data` | **320** | Static Data (<= 350) |
| 3 | `wheel_measurement_model.dart` | `models/wheel` | **309** | Optimal Model (<= 350) |
| 4 | `login_model.dart` | `models/auth` | **127** | Optimal Model (<= 350) |
| 5 | `trainset_meter_reading_model.dart` | `models/meter` | **109** | Optimal Model (<= 350) |
| 6 | `meter_reading.dart` | `models/meter` | **103** | Optimal Model (<= 350) |
| 7 | `maintenance_bay_model.dart` | `models/maintenance_bay` | **103** | Optimal Model (<= 350) |
| 8 | `profile_model.dart` | `models/auth` | **101** | Optimal Model (<= 350) |
| 9 | `wheel_tolerances.dart` | `models/wheel` | **94** | Optimal Model (<= 350) |
| 10 | `notification_model.dart` | `models/notifications` | **65** | Optimal Model (<= 350) |
| 11 | `wheel_measurement_default_data.dart` | `data` | **61** | Static Data (<= 350) |
| 12 | `train_model.dart` | `models/maintenance_bay` | **43** | Optimal Model (<= 350) |
| 13 | `sidebar_modules.dart` | `data` | **43** | Static Data (<= 350) |
| 14 | `maintenance_purpose_model.dart` | `models/maintenance_bay` | **42** | Optimal Model (<= 350) |
| 15 | `status_model.dart` | `models/maintenance_bay` | **37** | Optimal Model (<= 350) |
| 16 | `sidebar_module.dart` | `models/navigation` | **21** | Optimal Model (<= 350) |
| 17 | `allocation.dart` | `models/maintenance_bay` | **21** | Optimal Model (<= 350) |

---

## 6. Architecture, Theme & Utilities
*Target Rule: Theme, navigation, constants & helpers strictly <= 250 lines*

| # | File Name | Folder / Subfolder | Lines of Code | Status |
|---|---|---|---|---|
| 1 | `map_data.dart` | `constants` | **232** | Constants (<= 250) |
| 2 | `app_theme.dart` | `theme` | **195** | Theme System (<= 250) |
| 3 | `app_sidebar.dart` | `navigation` | **110** | Navigation (<= 250) |
| 4 | `maintenance_bay_navigation_screen.dart` | `navigation` | **96** | Navigation (<= 250) |
| 5 | `website_bay_markers.dart` | `constants` | **95** | Constants (<= 250) |
| 6 | `main.dart` | `root` | **74** | App Entrypoint (<= 250) |
| 7 | `checklist_navigation_screen.dart` | `navigation` | **60** | Navigation (<= 250) |
| 8 | `wheel_measurements_navigation_screen.dart` | `navigation` | **58** | Navigation (<= 250) |
| 9 | `colors.dart` | `theme/colors` | **57** | Theme System (<= 250) |
| 10 | `password_encryption.dart` | `utils` | **29** | Utility (<= 250) |
| 11 | `spacing.dart` | `theme/tokens` | **23** | Theme System (<= 250) |
| 12 | `token_diagnostics.dart` | `utils` | **18** | Utility (<= 250) |
| 13 | `theme_notifier.dart` | `theme` | **17** | Theme System (<= 250) |
| 14 | `meter_navigation_screen.dart` | `navigation` | **16** | Navigation (<= 250) |
| 15 | `typography.dart` | `theme/tokens` | **6** | Theme System (<= 250) |

---


