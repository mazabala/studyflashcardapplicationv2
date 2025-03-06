# Reorganization Plan

This document outlines the plan for reorganizing the project structure to improve readability and maintainability.

## Completed Changes

1. ✅ Created `data/` directory for JSON flashcard data files
2. ✅ Moved JSON files to the `data/` directory:
   - `cardiology_flashcards.json`
   - `pharmacology_flashcards.json`
   - `example_deck_import.json`
   - `example_deck_import_with_collection.json`
3. ✅ Created `docs/` directory for documentation
4. ✅ Moved `pharmacology_study_guide.md` to the `docs/` directory
5. ✅ Created `docs/data_format.md` to document the data format
6. ✅ Updated `pubspec.yaml` to include the `data/` directory in assets
7. ✅ Created `lib/core/utils/data_import_helper.dart` to help with importing data
8. ✅ Created run scripts: `run_app.bat` and `run_app.sh`
9. ✅ Updated `README.md` with project structure information
10. ✅ Reorganized presentation layer structure:
    - Created `lib/presentation/screens/`
    - Created `lib/presentation/widgets/`
    - Created `lib/presentation/pages/`
    - Moved admin screens to `lib/presentation/screens/admin/`

11. ✅ Moved UI components from `lib/core/ui/` to the presentation layer:

#### Screens Moved

1. ✅ Moved `lib/core/ui/login_screen.dart` to `lib/presentation/screens/auth/login_screen.dart`
2. ✅ Moved `lib/core/ui/authenthication_screen.dart` to `lib/presentation/screens/auth/authentication_screen.dart`
3. ✅ Moved `lib/core/ui/home_screen.dart` to `lib/presentation/screens/home_screen.dart`
4. ✅ Moved `lib/core/ui/study_screen.dart` to `lib/presentation/screens/study/study_screen.dart`
5. ✅ Moved `lib/core/ui/collection_study_screen.dart` to `lib/presentation/screens/study/collection_study_screen.dart`
6. ✅ Moved `lib/core/ui/study_screen_controller.dart` to `lib/presentation/screens/study/study_screen_controller.dart`
7. ✅ Moved `lib/core/ui/collections_screen.dart` to `lib/presentation/screens/deck/collections_screen.dart`
8. ✅ Moved `lib/core/ui/deck_screen.dart` to `lib/presentation/screens/deck/deck_screen.dart`
9. ✅ Moved `lib/core/ui/my_deck_screen.dart` to `lib/presentation/screens/deck/my_deck_screen.dart`
10. ✅ Moved `lib/core/ui/systemDeck_Screen.dart` to `lib/presentation/screens/deck/system_deck_screen.dart`
11. ✅ Moved `lib/core/ui/user_profile_screen.dart` to `lib/presentation/screens/user/user_profile_screen.dart`
12. ✅ Moved `lib/core/ui/admin_management_screen.dart` to `lib/presentation/screens/admin/admin_management_screen.dart`
13. ✅ Moved `lib/core/ui/pricing_screen.dart` to `lib/presentation/screens/user/pricing_screen.dart`
14. ✅ Moved `lib/core/ui/about_us.dart` to `lib/presentation/screens/about_us_screen.dart`

#### Widgets Moved

1. ✅ Moved `lib/core/ui/profile_card.dart` to `lib/presentation/widgets/user/profile_card.dart`
2. ✅ Moved themed widgets to `lib/presentation/widgets/common/`:
   - `lib/core/ui/widgets/themed_button.dart`
   - `lib/core/ui/widgets/themed_card.dart`
   - `lib/core/ui/widgets/themed_input.dart`
   - `lib/core/ui/widgets/theme_toggle.dart`
3. ✅ Moved other common widgets to `lib/presentation/widgets/common/`:
   - `lib/core/ui/widgets/CustomScaffold.dart`
   - `lib/core/ui/widgets/responsive_widget.dart`
   - `lib/core/ui/widgets/navigation_button.dart`
   - `lib/core/ui/widgets/CustomButton.dart`
   - `lib/core/ui/widgets/progress_indicator.dart`
   - `lib/core/ui/widgets/CustomTextField.dart`
   - `lib/core/ui/widgets/CategoryMultiSelect.dart`
   - `lib/core/ui/widgets/CustomDialog.dart`
   - `lib/core/ui/widgets/ErrorMessage.dart`
4. ✅ Moved study-related widgets to `lib/presentation/widgets/study/`:
   - `lib/core/ui/widgets/flashcard_display.dart`
   - `lib/core/ui/widgets/progress_button.dart`
5. ✅ Moved deck-related widgets to `lib/presentation/widgets/deck/`:
   - `lib/core/ui/widgets/myDeckToolBar.dart`
   - `lib/core/ui/widgets/CardCountSlider.dart`
   - `lib/core/ui/widgets/progress_dashboard_widget.dart`
   - All files in `lib/core/ui/widgets/deck/`
   - All files in `lib/core/ui/widgets/collection/`
6. ✅ Moved management-related widgets to `lib/presentation/widgets/common/`:
   - All files in `lib/core/ui/widgets/management/`

## Pending Changes

### Import Updates

After moving files, all import statements in the codebase will need to be updated to reflect the new file locations. This should be done carefully to avoid breaking the application.

## Implementation Strategy

1. Create a backup of the project before making changes
2. Move files one by one, updating imports as you go
3. Test the application after each major change to ensure it still works
4. Update the README.md with the final project structure once all changes are complete 