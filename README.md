## SOMNILINK - User App
### Anwendung zur Dokumentation eines RLS-Syndroms

Diese App entstand im Rahmen eines Semesterprojektes and der Technischen Hochschule Ulm.
Sie ist Teil einer Sammlung an Anwendungen, bestehend aus einer Web-Applikation für Ärzte, einem Django-Backend zur Datenverwaltung, einem Firely-Server zur Datenspeicherung und dieser Patienten-App.

Die Patienten-App beinhaltet folgende Features:
- Anlegen eines Benutzerprofils
- Selbstständige Dokumetation des Krankheitsverlaufes der Patienten über Fragebögen und ein Tagebuch
- Visualisieren des Krankheitsverlaufes anhand berechntet Scores der Fragebögen

Die Dokumentation des Krankheitsverlaufes beinhaltet das Ausfüllen folgender Fragebögen:
- IRLS
- MHI-5
- RLS-6

### Dateikatalog
Folgende Dateien sind Teil der SOMNILINK - User App:
 | Datei | Inhalt |
|----------|----------|
| main.dart    | Startet die Anwendung  |
| app.dart     |  -                     |
| root_navigation.dart        | Menüleiste zum wechseln der Pages   |
|theme_provider.dart|stellt ein durchgehendes theme bereit    |
|firely_service.dart       | API zum Firely-Server       |
|fhire_service.dart       | GETs für die Fragebögen         |
|api_service_dio.dart       |API zum Django-Backend       |
|settings_page.dart     |Page mit Einstellungen       |
|profile_page.dart        | Page mit Profil(-Einstellungen)      |
|home_page.dart        |Landing page       |
|data_selection_page.dart       |  Page zur Auswahl der gewünschten Datendarstellung|
|calendar_page.dart|Kalender um den Tag zu wählen an dem neue Daten eingetragen werden sollen|
|questionnaire_list_page.dart       |Button-Liste mit verfügbaren Fragebögen       |
|questionnaire_IRLS_page.dart       |Page mit IRLS-Fragebogen       |
|questionnaire_MHI5_page.dart       |Page mit MHI5-Fragebogen       |
|questionnaire_RLS6_page.dart       |Page mit RLS6-Fragebogen       |
|questionnaire_tagebuch_page.dart       |Page mit Tagebuch       |

...
