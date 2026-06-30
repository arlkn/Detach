import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"
    case french = "fr"
    case german = "de"
    case spanish = "es"

    var id: Self { self }

    var shortTitle: String {
        switch self {
        case .english: return "EN"
        case .turkish: return "TR"
        case .french: return "FR"
        case .german: return "DE"
        case .spanish: return "ES"
        }
    }

    var title: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Turkish"
        case .french: return "French"
        case .german: return "German"
        case .spanish: return "Spanish"
        }
    }
}

struct LocalizedText {
    let language: AppLanguage

    private func value(en: String, tr: String, fr: String, de: String, es: String) -> String {
        switch language {
        case .english: return en
        case .turkish: return tr
        case .french: return fr
        case .german: return de
        case .spanish: return es
        }
    }

    var thisApp: String {
        value(en: "this app", tr: "bu uygulama", fr: "cette app", de: "diese App", es: "esta app")
    }
    var moveToTrash: String {
        value(en: "Move to Trash", tr: "Çöp Sepeti'ne Taşı", fr: "Mettre à la corbeille", de: "In den Papierkorb", es: "Mover a la papelera")
    }
    var cancel: String {
        value(en: "Cancel", tr: "Vazgeç", fr: "Annuler", de: "Abbrechen", es: "Cancelar")
    }
    var close: String {
        value(en: "Close", tr: "Kapat", fr: "Fermer", de: "Schließen", es: "Cerrar")
    }
    var confirmationMessage: String {
        "This uses the selected uninstall mode and writes an undo manifest. Nothing is permanently deleted."
    }
    func moveAppTitle(_ appName: String?) -> String {
        let name = appName ?? thisApp
        return value(
            en: "Move \(name) to Trash?",
            tr: "\(name) Çöp Sepeti'ne taşınsın mı?",
            fr: "Mettre \(name) à la corbeille ?",
            de: "\(name) in den Papierkorb legen?",
            es: "¿Mover \(name) a la papelera?"
        )
    }

    var showAppNames: String {
        value(en: "Show app names", tr: "Uygulama adlarını göster", fr: "Afficher les noms", de: "App-Namen anzeigen", es: "Mostrar nombres")
    }
    var showIconsOnly: String {
        value(en: "Show icons only", tr: "Sadece ikonları göster", fr: "Afficher seulement les icônes", de: "Nur Symbole anzeigen", es: "Mostrar solo iconos")
    }
    var searchApps: String {
        value(en: "Search apps", tr: "Uygulamalarda ara", fr: "Rechercher des apps", de: "Apps suchen", es: "Buscar apps")
    }
    var noAppSelected: String {
        value(en: "No app selected", tr: "Uygulama seçilmedi", fr: "Aucune app sélectionnée", de: "Keine App ausgewählt", es: "Ninguna app seleccionada")
    }
    var version: String {
        value(en: "Version", tr: "Sürüm", fr: "Version", de: "Version", es: "Versión")
    }
    var checkingRelatedFiles: String {
        value(en: "Checking related files", tr: "İlişkili dosyalar kontrol ediliyor", fr: "Vérification des fichiers associés", de: "Zugehörige Dateien werden geprüft", es: "Comprobando archivos relacionados")
    }

    var protectedAppBanner: String {
        "Protected Apple or system app. Uninstall is disabled for this app."
    }
    var runningAppBanner: String {
        "This app is currently running. Quit it before uninstalling."
    }
    func skippedBanner(_ count: Int) -> String {
        "\(count) risky related item(s) will be left untouched."
    }
    func adminOnlyBanner(_ count: Int) -> String {
        "\(count) admin-only related item(s) can be reviewed separately. They are not selected by default."
    }

    var removalSummary: String {
        value(en: "Removal summary", tr: "Kaldırma özeti", fr: "Résumé de suppression", de: "Entfernungsübersicht", es: "Resumen de eliminación")
    }
    var appDescription: String {
        value(en: "App description", tr: "Uygulama açıklaması", fr: "Description de l'app", de: "App-Beschreibung", es: "Descripción de la app")
    }
    var appDetails: String {
        value(en: "App Details", tr: "Uygulama detayları", fr: "Détails de l'app", de: "App-Details", es: "Detalles de la app")
    }
    var aboutThisApp: String {
        value(en: "About this app", tr: "Bu uygulama hakkında", fr: "À propos de cette app", de: "Über diese App", es: "Acerca de esta app")
    }
    var appName: String {
        value(en: "Name", tr: "Ad", fr: "Nom", de: "Name", es: "Nombre")
    }
    var appDescriptionIntro: String {
        "Detach reads the app bundle and nearby user-space data to explain what will happen before anything is moved to Trash."
    }
    var appType: String {
        value(en: "Type", tr: "Tür", fr: "Type", de: "Typ", es: "Tipo")
    }
    var userApplication: String {
        value(en: "User application", tr: "Kullanıcı uygulaması", fr: "Application utilisateur", de: "Benutzer-App", es: "Aplicación de usuario")
    }
    var protectedSystemApplication: String {
        value(en: "Protected system application", tr: "Korumalı sistem uygulaması", fr: "Application système protégée", de: "Geschützte System-App", es: "Aplicación protegida del sistema")
    }
    var appLocation: String {
        value(en: "Location", tr: "Konum", fr: "Emplacement", de: "Ort", es: "Ubicación")
    }
    var bundleIdentifier: String {
        value(en: "Bundle ID", tr: "Paket ID", fr: "ID du paquet", de: "Bundle-ID", es: "ID del paquete")
    }
    var currentStatus: String {
        value(en: "Status", tr: "Durum", fr: "État", de: "Status", es: "Estado")
    }
    var readyToRemove: String {
        value(en: "Ready to remove", tr: "Kaldırmaya hazır", fr: "Prête à supprimer", de: "Bereit zum Entfernen", es: "Lista para eliminar")
    }
    var currentlyRunning: String {
        value(en: "Currently running", tr: "Şu anda çalışıyor", fr: "En cours d'exécution", de: "Wird ausgeführt", es: "En ejecución")
    }
    var relatedDataFound: String {
        value(en: "Related data found", tr: "Bulunan ilişkili veri", fr: "Données associées trouvées", de: "Zugehörige Daten gefunden", es: "Datos relacionados encontrados")
    }
    var selectedAction: String {
        value(en: "Selected action", tr: "Seçili işlem", fr: "Action choisie", de: "Gewählte Aktion", es: "Acción seleccionada")
    }
    var removalImpact: String {
        value(en: "Removal impact", tr: "Kaldırma etkisi", fr: "Impact de la suppression", de: "Auswirkung der Entfernung", es: "Impacto de eliminación")
    }
    var willMoveToTrash: String {
        value(en: "will move to Trash", tr: "Çöp Sepeti'ne taşınacak", fr: "ira à la corbeille", de: "wandert in den Papierkorb", es: "irá a la papelera")
    }
    var appOnlyActionDetail: String {
        "Only the app bundle will be moved to Trash. Related settings and caches stay on this Mac."
    }
    var appAndFilesActionDetail: String {
        "The app bundle and safe related files will be moved to Trash. Risky or admin-only items stay untouched."
    }
    var safetyNote: String {
        value(en: "Safety note", tr: "Güvenlik notu", fr: "Note de sécurité", de: "Sicherheitshinweis", es: "Nota de seguridad")
    }
    var safetyNoteDetail: String {
        "Detach never deletes permanently. Every removal is moved to Trash and recorded in History for restore."
    }
    var applicationBundle: String {
        value(en: "Application bundle", tr: "Uygulama paketi", fr: "Paquet de l'app", de: "App-Paket", es: "Paquete de la app")
    }
    func relatedItems(_ count: Int) -> String {
        value(en: "\(count) related item(s)", tr: "\(count) ilişkili öğe", fr: "\(count) élément(s) associé(s)", de: "\(count) zugehörige Elemente", es: "\(count) elemento(s) relacionado(s)")
    }
    var relatedItemsDetail: String {
        "Preferences, caches, support files, and containers found with safe confidence"
    }
    func skippedItems(_ count: Int) -> String {
        value(en: "\(count) item(s) skipped", tr: "\(count) öğe atlandı", fr: "\(count) élément(s) ignoré(s)", de: "\(count) Elemente übersprungen", es: "\(count) elemento(s) omitidos")
    }
    var skippedItemsDetail: String {
        "Low confidence, protected, or symbolic link items are never moved automatically"
    }
    func adminItems(_ count: Int) -> String {
        value(en: "\(count) admin-only item(s)", tr: "\(count) admin öğesi", fr: "\(count) élément(s) admin", de: "\(count) Admin-Elemente", es: "\(count) elemento(s) de administrador")
    }
    var adminItemsDetail: String {
        "System-wide related files under /Library. Select individually; password required at removal time."
    }
    var adminPasswordRequired: String {
        value(
            en: "Administrator password required for selected admin-only items.",
            tr: "Seçili admin öğeleri için yönetici parolası gerekir.",
            fr: "Mot de passe administrateur requis pour les éléments admin sélectionnés.",
            de: "Administratorpasswort für ausgewählte Admin-Elemente erforderlich.",
            es: "Se requiere contraseña de administrador para los elementos seleccionados."
        )
    }
    var adminOnlyRelatedFiles: String {
        value(en: "Admin-only related files", tr: "Admin gerektiren ilişkili dosyalar", fr: "Fichiers associés admin", de: "Adminpflichtige Dateien", es: "Archivos relacionados de administrador")
    }
    var matchReason: String {
        value(en: "Match reason", tr: "Eşleşme nedeni", fr: "Raison de correspondance", de: "Treffergrund", es: "Motivo de coincidencia")
    }
    var selected: String {
        value(en: "Selected", tr: "Seçildi", fr: "Sélectionné", de: "Ausgewählt", es: "Seleccionado")
    }
    var protected: String {
        value(en: "Protected", tr: "Korumalı", fr: "Protégé", de: "Geschützt", es: "Protegido")
    }
    var relatedFilesKeptTitle: String {
        value(en: "Related files stay in place", tr: "İlişkili dosyalar yerinde kalır", fr: "Les fichiers associés restent en place", de: "Zugehörige Dateien bleiben erhalten", es: "Los archivos relacionados se conservan")
    }
    var relatedFilesKeptDetail: String {
        "Settings, caches, and support data are preserved"
    }
    var kept: String {
        value(en: "Kept", tr: "Korunur", fr: "Conservé", de: "Behalten", es: "Conservado")
    }
    var selectedRemovalMode: String {
        value(en: "Selected removal mode", tr: "Seçili kaldırma modu", fr: "Mode de suppression choisi", de: "Gewählter Entfernungsmodus", es: "Modo de eliminación seleccionado")
    }
    var bundleFootprint: String {
        value(en: "Bundle footprint", tr: "Paket boyutu", fr: "Taille du paquet", de: "Bundle-Größe", es: "Tamaño del paquete")
    }
    var cleanupScope: String {
        value(en: "Cleanup scope", tr: "Temizlik kapsamı", fr: "Portée du nettoyage", de: "Bereinigungsumfang", es: "Alcance de limpieza")
    }
    var cleanupSize: String {
        value(en: "Cleanup size", tr: "Temizlik boyutu", fr: "Taille du nettoyage", de: "Bereinigungsgröße", es: "Tamaño de limpieza")
    }
    var safetyChecks: String {
        value(en: "Safety checks", tr: "Güvenlik kontrolleri", fr: "Contrôles de sécurité", de: "Sicherheitsprüfungen", es: "Comprobaciones de seguridad")
    }
    var movedToTrashOnly: String {
        value(en: "Moves to Trash only", tr: "Yalnızca Çöp Sepeti'ne taşır", fr: "Déplace seulement vers la corbeille", de: "Verschiebt nur in den Papierkorb", es: "Solo mueve a la papelera")
    }
    var historyRestoreReady: String {
        value(en: "History restore record", tr: "Geçmiş geri yükleme kaydı", fr: "Historique de restauration", de: "Wiederherstellungsverlauf", es: "Registro de restauración")
    }
    var protectedPathsUntouched: String {
        value(en: "Protected paths stay untouched", tr: "Korumalı yollar dokunulmaz kalır", fr: "Les chemins protégés restent intacts", de: "Geschützte Pfade bleiben unverändert", es: "Las rutas protegidas no se tocan")
    }

    var uninstall: String {
        value(en: "Uninstall", tr: "Kaldır", fr: "Désinstaller", de: "Deinstallieren", es: "Desinstalar")
    }
    func movedToTrash(_ count: Int) -> String {
        value(en: "Moved \(count) item(s) to Trash", tr: "\(count) öğe Çöp Sepeti'ne taşındı", fr: "\(count) élément(s) mis à la corbeille", de: "\(count) Elemente in den Papierkorb gelegt", es: "\(count) elemento(s) movidos a la papelera")
    }
    var reviewUninstall: String {
        value(en: "Review Uninstall", tr: "Kaldırmayı İncele", fr: "Vérifier la désinstallation", de: "Deinstallation prüfen", es: "Revisar desinstalación")
    }
    var secondConfirmationMessage: String {
        "A second confirmation is required before anything is moved. Items go to Trash and an undo manifest is written."
    }
    var continueTitle: String {
        value(en: "Continue", tr: "Devam", fr: "Continuer", de: "Fortfahren", es: "Continuar")
    }
    var settings: String {
        value(en: "Settings", tr: "Ayarlar", fr: "Réglages", de: "Einstellungen", es: "Ajustes")
    }
    var general: String {
        value(en: "General", tr: "Genel", fr: "Général", de: "Allgemein", es: "General")
    }
    var languageSetting: String {
        value(en: "Language", tr: "Dil", fr: "Langue", de: "Sprache", es: "Idioma")
    }
    var appearance: String {
        value(en: "Appearance", tr: "Görünüm", fr: "Apparence", de: "Darstellung", es: "Apariencia")
    }
    var themes: String {
        value(en: "Themes", tr: "Temalar", fr: "Thèmes", de: "Themes", es: "Temas")
    }
    var scan: String {
        value(en: "Scan", tr: "Tarama", fr: "Analyse", de: "Scan", es: "Escaneo")
    }
    var adminCleanup: String {
        value(en: "Admin Cleanup", tr: "Admin temizliği", fr: "Nettoyage admin", de: "Admin-Bereinigung", es: "Limpieza admin")
    }
    var settingsSubtitle: String {
        "Control how Detach looks, scans, reviews, and records removals."
    }
    var themeDetail: String {
        "Choose the visual mood for the app."
    }
    var system: String {
        value(en: "System", tr: "Sistem", fr: "Système", de: "System", es: "Sistema")
    }
    var light: String {
        value(en: "Light", tr: "Açık", fr: "Clair", de: "Hell", es: "Claro")
    }
    var dark: String {
        value(en: "Dark", tr: "Koyu", fr: "Sombre", de: "Dunkel", es: "Oscuro")
    }
    var startSidebarCompact: String {
        value(en: "Start sidebar compact", tr: "Kenar çubuğu kompakt başlasın", fr: "Démarrer avec la barre compacte", de: "Seitenleiste kompakt starten", es: "Iniciar barra lateral compacta")
    }
    var autoScanOnLaunch: String {
        value(en: "Auto-scan on launch", tr: "Açılışta otomatik tara", fr: "Analyser au lancement", de: "Beim Start automatisch scannen", es: "Escanear al iniciar")
    }
    var scanNow: String {
        value(en: "Scan now", tr: "Şimdi tara", fr: "Analyser maintenant", de: "Jetzt scannen", es: "Escanear ahora")
    }
    var refresh: String {
        value(en: "Refresh", tr: "Yenile", fr: "Actualiser", de: "Aktualisieren", es: "Actualizar")
    }
    var scanScope: String {
        value(en: "Scan scope", tr: "Tarama kapsamı", fr: "Portée de l'analyse", de: "Scanumfang", es: "Alcance del escaneo")
    }
    var scanScopeDetail: String {
        "Detach scans /Applications, ~/Applications, and safe Library locations for related files."
    }
    var uninstallSettings: String {
        value(en: "Uninstall", tr: "Kaldırma", fr: "Désinstallation", de: "Deinstallation", es: "Desinstalación")
    }
    var defaultUninstallMode: String {
        value(en: "Default uninstall mode", tr: "Varsayılan kaldırma yöntemi", fr: "Mode de désinstallation par défaut", de: "Standard-Deinstallationsmodus", es: "Modo de desinstalación predeterminado")
    }
    var doubleConfirmation: String {
        value(en: "Double confirmation", tr: "Çift onay", fr: "Double confirmation", de: "Doppelte Bestätigung", es: "Doble confirmación")
    }
    var alwaysOn: String {
        value(en: "Always on", tr: "Her zaman açık", fr: "Toujours activé", de: "Immer aktiv", es: "Siempre activo")
    }
    var showAdminOnlyMatches: String {
        value(en: "Show admin-only matches", tr: "Admin eşleşmelerini göster", fr: "Afficher les éléments admin", de: "Admin-Treffer anzeigen", es: "Mostrar coincidencias admin")
    }
    var showSkippedMatches: String {
        value(en: "Show skipped matches", tr: "Atlanan eşleşmeleri göster", fr: "Afficher les éléments ignorés", de: "Übersprungene Treffer anzeigen", es: "Mostrar omitidos")
    }
    var warnBeforeAdminCleanup: String {
        value(en: "Warn before admin cleanup", tr: "Admin temizliğinden önce uyar", fr: "Avertir avant le nettoyage admin", de: "Vor Admin-Bereinigung warnen", es: "Avisar antes de limpieza admin")
    }
    var powerUserControls: String {
        value(en: "Power-user controls", tr: "Gelişmiş kullanıcı kontrolleri", fr: "Contrôles avancés", de: "Power-User-Steuerung", es: "Controles avanzados")
    }
    var lockedSafetyRules: String {
        value(en: "Locked safety rules", tr: "Kilitli güvenlik kuralları", fr: "Règles de sécurité verrouillées", de: "Gesperrte Sicherheitsregeln", es: "Reglas de seguridad bloqueadas")
    }
    var doubleConfirmationDetail: String {
        "Always required before moving anything to Trash."
    }
    var historySettingsDetail: String {
        "Restore and history cleanup are managed from the History sheet."
    }
    var historyStorage: String {
        value(en: "History storage", tr: "Geçmiş depolama", fr: "Stockage de l'historique", de: "Verlaufsspeicher", es: "Almacenamiento del historial")
    }
    var historyStorageDetail: String {
        "Manifests are saved in Application Support under Detach."
    }
    var scanApps: String {
        value(en: "Scan Apps", tr: "Uygulamaları Tara", fr: "Analyser les apps", de: "Apps scannen", es: "Escanear apps")
    }
    var historyRetention: String {
        value(en: "History retention", tr: "Geçmiş saklama", fr: "Conservation de l'historique", de: "Verlauf aufbewahren", es: "Retención del historial")
    }
    var historyCount: String {
        value(en: "Saved manifests", tr: "Kayıtlı manifestler", fr: "Manifestes enregistrés", de: "Gespeicherte Manifeste", es: "Manifiestos guardados")
    }
    var openHistory: String {
        value(en: "Open History", tr: "Geçmişi Aç", fr: "Ouvrir l'historique", de: "Verlauf öffnen", es: "Abrir historial")
    }
    var clearHistory: String {
        value(en: "Clear History", tr: "Geçmişi Temizle", fr: "Effacer l'historique", de: "Verlauf leeren", es: "Borrar historial")
    }
    var clearHistoryTitle: String {
        value(en: "Clear saved history?", tr: "Kayıtlı geçmiş temizlensin mi?", fr: "Effacer l'historique ?", de: "Gespeicherten Verlauf leeren?", es: "¿Borrar historial guardado?")
    }
    var clearHistoryDetail: String {
        "This removes Detach history records only. It does not delete files from Trash or original locations."
    }
    var accessibility: String {
        value(en: "Accessibility", tr: "Erişilebilirlik", fr: "Accessibilité", de: "Bedienungshilfen", es: "Accesibilidad")
    }
    var accessibilityPermission: String {
        value(en: "Accessibility permission", tr: "Erişilebilirlik izni", fr: "Autorisation d'accessibilité", de: "Bedienungshilfen-Zugriff", es: "Permiso de accesibilidad")
    }
    var accessibilityPermissionDetail: String {
        "Give Detach macOS Accessibility permission once if you want smoother permission handling."
    }
    var accessibilityStatus: String {
        value(en: "Permission status", tr: "İzin durumu", fr: "État de l'autorisation", de: "Berechtigungsstatus", es: "Estado del permiso")
    }
    var permissionGranted: String {
        value(en: "Granted", tr: "Verildi", fr: "Accordée", de: "Erteilt", es: "Concedido")
    }
    var permissionNotGranted: String {
        value(en: "Not granted", tr: "Verilmedi", fr: "Non accordée", de: "Nicht erteilt", es: "No concedido")
    }
    var accessibilityGrantedDetail: String {
        "macOS currently trusts Detach for Accessibility."
    }
    var accessibilityNotGrantedDetail: String {
        "Detach will not ask on launch. You can grant access from here when you are ready."
    }
    var accessibilityOneTimeApproval: String {
        value(en: "One-time macOS approval", tr: "Tek seferlik macOS onayı", fr: "Approbation macOS unique", de: "Einmalige macOS-Freigabe", es: "Aprobación única de macOS")
    }
    var accessibilityOneTimeApprovalDetail: String {
        "macOS requires the user to approve this manually. Once approved for the installed app, it should persist."
    }
    var requestPermission: String {
        value(en: "Request Permission", tr: "İzin İste", fr: "Demander l'autorisation", de: "Berechtigung anfordern", es: "Solicitar permiso")
    }
    var openSystemSettings: String {
        value(en: "Open System Settings", tr: "Sistem Ayarları'nı Aç", fr: "Ouvrir Réglages Système", de: "Systemeinstellungen öffnen", es: "Abrir Ajustes del Sistema")
    }
    var history: String {
        value(en: "History", tr: "Geçmiş", fr: "Historique", de: "Verlauf", es: "Historial")
    }
    var uninstallHistory: String {
        value(en: "Uninstall History", tr: "Kaldırma Geçmişi", fr: "Historique des désinstallations", de: "Deinstallationsverlauf", es: "Historial de desinstalación")
    }
    var noHistory: String {
        value(en: "No history yet", tr: "Henüz geçmiş yok", fr: "Aucun historique", de: "Noch kein Verlauf", es: "Sin historial")
    }
    var noHistoryDetail: String {
        "Apps you move to Trash will appear here with restore details."
    }
    var restore: String {
        value(en: "Restore", tr: "Geri Yükle", fr: "Restaurer", de: "Wiederherstellen", es: "Restaurar")
    }
    var removeFromHistory: String {
        value(en: "Remove from History", tr: "Geçmişten Kaldır", fr: "Retirer de l'historique", de: "Aus Verlauf entfernen", es: "Quitar del historial")
    }
    var items: String {
        value(en: "Items", tr: "Öğeler", fr: "Éléments", de: "Elemente", es: "Elementos")
    }
    var restored: String {
        value(en: "Restored", tr: "Geri yüklendi", fr: "Restauré", de: "Wiederhergestellt", es: "Restaurado")
    }
    var missingFromTrash: String {
        value(en: "Missing from Trash", tr: "Çöp Sepeti'nde yok", fr: "Absent de la corbeille", de: "Nicht im Papierkorb", es: "No está en la papelera")
    }
    var destinationExists: String {
        value(en: "Destination exists", tr: "Hedef mevcut", fr: "La destination existe", de: "Ziel existiert", es: "El destino existe")
    }
    var failed: String {
        value(en: "Failed", tr: "Başarısız", fr: "Échec", de: "Fehlgeschlagen", es: "Falló")
    }
    func restoreSummary(_ restored: Int, _ missing: Int, _ conflicts: Int, _ failed: Int) -> String {
        value(
            en: "\(restored) restored, \(missing) missing, \(conflicts) conflict(s), \(failed) failed",
            tr: "\(restored) geri yüklendi, \(missing) eksik, \(conflicts) çakışma, \(failed) başarısız",
            fr: "\(restored) restauré(s), \(missing) absent(s), \(conflicts) conflit(s), \(failed) échec(s)",
            de: "\(restored) wiederhergestellt, \(missing) fehlen, \(conflicts) Konflikt(e), \(failed) fehlgeschlagen",
            es: "\(restored) restaurado(s), \(missing) faltante(s), \(conflicts) conflicto(s), \(failed) fallido(s)"
        )
    }
}

@MainActor
final class AppUninstallerViewModel: ObservableObject {
    enum UninstallMode: String, CaseIterable, Identifiable {
        case appOnly
        case appAndFiles

        var id: Self { self }

        func title(language: AppLanguage) -> String {
            switch self {
            case .appOnly:
                switch language {
                case .english: return "Remove app only"
                case .turkish: return "Sadece uygulamayı kaldır"
                case .french: return "Supprimer seulement l'app"
                case .german: return "Nur App entfernen"
                case .spanish: return "Eliminar solo la app"
                }
            case .appAndFiles:
                switch language {
                case .english: return "Remove app and related files"
                case .turkish: return "Uygulamayı ve ilişkili dosyaları kaldır"
                case .french: return "Supprimer l'app et ses fichiers"
                case .german: return "App und zugehörige Dateien entfernen"
                case .spanish: return "Eliminar app y archivos relacionados"
                }
            }
        }

        func description(language: AppLanguage) -> String {
            switch self {
            case .appOnly:
                return "Moves only the application bundle to Trash. Preferences, caches, and support files stay on this Mac."
            case .appAndFiles:
                return "Moves the application bundle and safe user-space related files to Trash. Risky matches are left untouched."
            }
        }
    }

    enum State: Equatable {
        case idle
        case scanningApps
        case scanningFiles
        case deleting
        case finished
        case failed(String)
    }

    @Published private(set) var apps: [InstalledApp] = []
    @Published var selectedApp: InstalledApp?
    @Published private(set) var relatedFiles: [RelatedFile] = []
    @Published var uninstallMode: UninstallMode = .appOnly
    @Published private(set) var manifest: DeletionManifest?
    @Published private(set) var state: State = .idle
    @Published var searchText = ""
    @Published var isReviewPresented = false
    @Published var isSecondConfirmationPresented = false
    @Published var isHistoryPresented = false
    @Published var selectedAdminFileIDs = Set<URL>()
    @Published private(set) var historyManifests: [DeletionManifest] = []
    @Published var selectedHistoryManifestID: UUID?
    @Published private(set) var restoreResult: RestoreResult?
    @Published private(set) var historyErrorMessage: String?

    private let appScanner: AppScanner
    private let relatedFileScanner: RelatedFileScanner
    private let deletionService: FileDeletionService
    private let manifestStore: ManifestStoring
    private let restoreService: RestoreServicing

    init(
        appScanner: AppScanner = AppScanner(),
        relatedFileScanner: RelatedFileScanner = RelatedFileScanner(),
        deletionService: FileDeletionService = FileDeletionService(),
        manifestStore: ManifestStoring = ManifestStore(),
        restoreService: RestoreServicing = RestoreService()
    ) {
        self.appScanner = appScanner
        self.relatedFileScanner = relatedFileScanner
        self.deletionService = deletionService
        self.manifestStore = manifestStore
        self.restoreService = restoreService
    }

    var filteredApps: [InstalledApp] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return apps }
        return apps.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
            || ($0.bundleIdentifier?.localizedCaseInsensitiveContains(searchText) == true)
        }
    }

    var selectedFiles: [RelatedFile] {
        guard uninstallMode == .appAndFiles else { return [] }
        return relatedFiles.filter(\.isSafeForAutomaticRemoval)
    }

    var adminRelatedFiles: [RelatedFile] {
        guard uninstallMode == .appAndFiles else { return [] }
        return relatedFiles.filter(\.isEligibleForAdminRemoval)
    }

    var selectedAdminFiles: [RelatedFile] {
        guard uninstallMode == .appAndFiles else { return [] }
        return adminRelatedFiles.filter { selectedAdminFileIDs.contains($0.id) }
    }

    var selectedTotalSize: Int64 {
        (selectedApp?.size ?? 0)
        + selectedFiles.reduce(0) { $0 + $1.size }
        + selectedAdminFiles.reduce(0) { $0 + $1.size }
    }

    var skippedRelatedFiles: [RelatedFile] {
        guard uninstallMode == .appAndFiles else { return [] }
        return relatedFiles.filter { !$0.isSafeForAutomaticRemoval && !$0.isEligibleForAdminRemoval }
    }

    var relatedFilesTotalSize: Int64 {
        selectedFiles.reduce(0) { $0 + $1.size }
    }

    var selectedAdminFilesTotalSize: Int64 {
        selectedAdminFiles.reduce(0) { $0 + $1.size }
    }

    var canUninstallSelectedApp: Bool {
        guard let selectedApp else { return false }
        return !selectedApp.isAppleSignedOrProtected && !selectedApp.isRunning && state != .deleting
    }

    var selectedHistoryManifest: DeletionManifest? {
        guard let selectedHistoryManifestID else { return historyManifests.first }
        return historyManifests.first { $0.id == selectedHistoryManifestID }
    }

    func scanApps() {
        state = .scanningApps
        Task {
            apps = await appScanner.scan()
            selectedApp = apps.first
            state = .idle
            if let selectedApp {
                await scanRelatedFiles(for: selectedApp)
            }
        }
    }

    func select(_ app: InstalledApp) {
        selectedApp = app
        relatedFiles = []
        manifest = nil
        selectedAdminFileIDs = []
        Task { await scanRelatedFiles(for: app) }
    }

    func applyDefaultUninstallMode(_ rawValue: String) {
        uninstallMode = UninstallMode(rawValue: rawValue) ?? .appOnly
    }

    func scanRelatedFiles(for app: InstalledApp) async {
        state = .scanningFiles
        relatedFiles = await relatedFileScanner.scan(for: app)
        selectedAdminFileIDs = selectedAdminFileIDs.intersection(Set(relatedFiles.map(\.id)))
        state = .idle
    }

    func setAdminFile(_ file: RelatedFile, selected: Bool) {
        guard file.isEligibleForAdminRemoval else { return }
        if selected {
            selectedAdminFileIDs.insert(file.id)
        } else {
            selectedAdminFileIDs.remove(file.id)
        }
    }

    func clearAdminFileSelection() {
        selectedAdminFileIDs = []
    }

    func prepareReview() {
        isReviewPresented = true
    }

    func requestSecondConfirmation() {
        isReviewPresented = false
        isSecondConfirmationPresented = true
    }

    func uninstallSelectedApp() {
        guard let selectedApp else { return }
        let appBeingRemoved = selectedApp
        state = .deleting
        do {
            manifest = try deletionService.moveAppToTrash(
                appBeingRemoved,
                including: selectedFiles,
                includingAdminFiles: selectedAdminFiles
            )
            loadHistory()
            removeFromAppList(appBeingRemoved)
            state = .finished
            if let nextApp = self.selectedApp {
                Task { await scanRelatedFiles(for: nextApp) }
            }
        } catch {
            if !FileManager.default.fileExists(atPath: appBeingRemoved.url.path) {
                removeFromAppList(appBeingRemoved)
            }
            state = .failed(error.localizedDescription)
        }
    }

    func openHistory() {
        isHistoryPresented = true
        loadHistory()
    }

    func loadHistory() {
        do {
            historyManifests = try manifestStore.loadAll()
            historyErrorMessage = nil
            if selectedHistoryManifestID == nil {
                selectedHistoryManifestID = historyManifests.first?.id
            } else if selectedHistoryManifest == nil {
                selectedHistoryManifestID = historyManifests.first?.id
            }
        } catch {
            historyErrorMessage = error.localizedDescription
        }
    }

    func selectHistoryManifest(_ id: UUID?) {
        selectedHistoryManifestID = id
        restoreResult = nil
    }

    func restoreSelectedHistoryManifest() {
        guard let selectedHistoryManifest else { return }
        do {
            let result = try restoreService.restore(selectedHistoryManifest)
            restoreResult = result
            historyErrorMessage = nil
            if result.restoredAllEntries {
                try manifestStore.delete(selectedHistoryManifest)
                loadHistory()
            }
        } catch {
            historyErrorMessage = error.localizedDescription
        }
    }

    func removeSelectedManifestFromHistory() {
        guard let selectedHistoryManifest else { return }
        do {
            try manifestStore.delete(selectedHistoryManifest)
            restoreResult = nil
            selectedHistoryManifestID = nil
            loadHistory()
            historyErrorMessage = nil
        } catch {
            historyErrorMessage = error.localizedDescription
        }
    }

    private func removeFromAppList(_ app: InstalledApp) {
        let visibleAppsBeforeRemoval = filteredApps
        let removedVisibleIndex = visibleAppsBeforeRemoval.firstIndex { $0.id == app.id }

        apps.removeAll { $0.id == app.id }
        relatedFiles = []

        let visibleAppsAfterRemoval = filteredApps
        if let removedVisibleIndex, !visibleAppsAfterRemoval.isEmpty {
            let nextIndex = min(removedVisibleIndex, visibleAppsAfterRemoval.count - 1)
            selectedApp = visibleAppsAfterRemoval[nextIndex]
        } else if selectedApp?.id == app.id {
            selectedApp = visibleAppsAfterRemoval.first ?? apps.first
        }
    }
}
