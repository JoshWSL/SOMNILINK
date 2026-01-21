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
|app.dart|Root-Datei|
| main.dart    | Startet die Anwendung  |
| root_navigation.dart        | Menüleiste zum wechseln der Pages   |
|theme_provider.dart|Stellt dark/light mode bereit     |
|firely_service.dart       | API zum Firely-Server       |
|fhire_service.dart       | GETs für die Fragebögen         |
|api_service_dio.dart       |API zum Django-Backend       |
|auth_service_dio.dart       |Service für Login und Registrierung       |
|settings_page.dart     |Page mit Einstellungen       |
|profile_page.dart        | Page mit Profil(-Einstellungen)      |
|home_page.dart        |Landing page / Wahl von Daten eingeben und Daten anzeigen       |
|data_selection_page.dart       |  Page zur Auswahl der gewünschten Datendarstellung|
|calendar_page.dart|Kalender um den Tag zu wählen an dem neue Daten eingetragen werden sollen|
|info_page.dart| Page mit Information über RLS, verweis auf RLS e.V. und Hintergrund zu Fragebögen|
|questionnaire_list_page.dart       |Button-Liste mit verfügbaren Fragebögen (einschl. Tagebuch)|
|questionnaire_IRLS_page.dart       |Page mit IRLS-Fragebogen       |
|questionnaire_MHI5_page.dart       |Page mit MHI5-Fragebogen       |
|questionnaire_RLS6_page.dart       |Page mit RLS6-Fragebogen       |
|questionnaire_tagebuch_page.dart       |Page mit Tagebuch       |
|calendar_tagebuch_page.dart|Kalender um das Datum des geünschten Tagebuchs zur Visualisierung anzuzeigen|
|visualize_tagebuch_page.dart|Page bildet Daten von ausgwähltem Tagebucheintrag ab|
|visualize_RLS6_page.dart|Page bildet Daten der letzten 7 RLS-6-Fragebögen ab|
|visualize_MHI5_page.dart|Page bildet Scores der letzten 7 MHI-5-Fragebögen ab|
|visualize_IRLS_page.dart|Page bildet Scores der letzten 7 IRLS-Fragebögen ab|
|login_page.dart|Page für Login mit Benutzer und Passwort|
|register_page.dart|Page für Registrierung eines Accounts|

### Anleitung zum Starten der App
Die SOMNILINK User-App kann wiefolgt gestartet werden:
1. Repository klonen
2. Django-Backend starten
3. Firely-Server starten
4. Projekt in VSC öffnen: flutter run -d chrome (chrome ggf. durch anderen Emulgator öffnen)

Vorraussetzung ist die installation von Flutter, Dart und einigen SDKs. Letzteres sollte allerdings automatisch von VSC zur installation vorgeschlagen werden.
