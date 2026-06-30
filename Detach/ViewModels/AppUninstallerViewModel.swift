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
        value(
            en: "This uses the selected uninstall mode and writes an undo manifest. Nothing is permanently deleted.",
            tr: "Seçili kaldırma yöntemi uygulanır ve geri alma manifesti yazılır. Hiçbir şey kalıcı olarak silinmez.",
            fr: "Le mode de désinstallation choisi sera utilisé et un manifeste de restauration sera créé. Rien n'est supprimé définitivement.",
            de: "Der gewählte Deinstallationsmodus wird verwendet und ein Wiederherstellungsmanifest wird erstellt. Nichts wird dauerhaft gelöscht.",
            es: "Se usa el modo de desinstalación elegido y se crea un manifiesto de restauración. Nada se elimina permanentemente."
        )
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
        value(
            en: "Protected Apple or system app. Uninstall is disabled for this app.",
            tr: "Korumalı Apple veya sistem uygulaması. Bu uygulama için kaldırma devre dışı.",
            fr: "App Apple ou système protégée. La désinstallation est désactivée pour cette app.",
            de: "Geschützte Apple- oder System-App. Die Deinstallation ist für diese App deaktiviert.",
            es: "App protegida de Apple o del sistema. La desinstalación está desactivada para esta app."
        )
    }
    var runningAppBanner: String {
        value(
            en: "This app is currently running. Quit it before uninstalling.",
            tr: "Bu uygulama şu anda çalışıyor. Kaldırmadan önce kapatın.",
            fr: "Cette app est en cours d'exécution. Fermez-la avant de la désinstaller.",
            de: "Diese App wird gerade ausgeführt. Beenden Sie sie vor der Deinstallation.",
            es: "Esta app se está ejecutando. Ciérrela antes de desinstalarla."
        )
    }
    func skippedBanner(_ count: Int) -> String {
        value(
            en: "\(count) risky related item(s) will be left untouched.",
            tr: "\(count) riskli ilişkili öğe olduğu gibi bırakılacak.",
            fr: "\(count) élément(s) risqués seront ignorés.",
            de: "\(count) riskante Elemente bleiben unverändert.",
            es: "\(count) elemento(s) arriesgados se dejarán intactos."
        )
    }
    func adminOnlyBanner(_ count: Int) -> String {
        value(
            en: "\(count) admin-only related item(s) can be reviewed separately. They are not selected by default.",
            tr: "\(count) admin gerektiren ilişkili öğe ayrı incelenebilir. Varsayılan olarak seçilmez.",
            fr: "\(count) élément(s) admin peuvent être vérifiés séparément. Ils ne sont pas sélectionnés par défaut.",
            de: "\(count) adminpflichtige Elemente können separat geprüft werden. Sie sind standardmäßig nicht ausgewählt.",
            es: "\(count) elemento(s) de administrador se pueden revisar por separado. No se seleccionan por defecto."
        )
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
        value(
            en: "Detach reads the app bundle and nearby user-space data to explain what will happen before anything is moved to Trash.",
            tr: "Detach, herhangi bir şey Çöp Sepeti'ne taşınmadan önce ne olacağını açıklamak için uygulama paketini ve ilişkili kullanıcı verilerini okur.",
            fr: "Detach lit le paquet de l'app et les données utilisateur associées pour expliquer ce qui se passera avant tout déplacement vers la corbeille.",
            de: "Detach liest das App-Paket und zugehörige Benutzerdaten, um vor dem Verschieben in den Papierkorb zu erklären, was passiert.",
            es: "Detach lee el paquete de la app y datos de usuario cercanos para explicar qué ocurrirá antes de mover nada a la papelera."
        )
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
        value(
            en: "Only the app bundle will be moved to Trash. Related settings and caches stay on this Mac.",
            tr: "Yalnızca uygulama paketi Çöp Sepeti'ne taşınır. İlişkili ayarlar ve önbellekler bu Mac'te kalır.",
            fr: "Seul le paquet de l'app sera déplacé vers la corbeille. Les réglages et caches associés restent sur ce Mac.",
            de: "Nur das App-Paket wird in den Papierkorb verschoben. Zugehörige Einstellungen und Caches bleiben auf diesem Mac.",
            es: "Solo el paquete de la app se moverá a la papelera. Los ajustes y cachés relacionados se quedan en este Mac."
        )
    }
    var appAndFilesActionDetail: String {
        value(
            en: "The app bundle and safe related files will be moved to Trash. Risky or admin-only items stay untouched.",
            tr: "Uygulama paketi ve güvenli ilişkili dosyalar Çöp Sepeti'ne taşınır. Riskli veya admin gerektiren öğeler bırakılır.",
            fr: "Le paquet de l'app et les fichiers associés sûrs seront déplacés vers la corbeille. Les éléments risqués ou admin restent intacts.",
            de: "Das App-Paket und sichere zugehörige Dateien werden in den Papierkorb verschoben. Riskante oder adminpflichtige Elemente bleiben unverändert.",
            es: "El paquete de la app y archivos seguros relacionados se moverán a la papelera. Los elementos arriesgados o de administrador no se tocarán."
        )
    }
    var safetyNote: String {
        value(en: "Safety note", tr: "Güvenlik notu", fr: "Note de sécurité", de: "Sicherheitshinweis", es: "Nota de seguridad")
    }
    var safetyNoteDetail: String {
        value(
            en: "Detach never deletes permanently. Every removal is moved to Trash and recorded in History for restore.",
            tr: "Detach kalıcı silme yapmaz. Her kaldırma Çöp Sepeti'ne taşınır ve geri yükleme için Geçmiş'e kaydedilir.",
            fr: "Detach ne supprime jamais définitivement. Chaque suppression va à la corbeille et est enregistrée dans l'historique.",
            de: "Detach löscht nie dauerhaft. Jede Entfernung landet im Papierkorb und wird im Verlauf zur Wiederherstellung gespeichert.",
            es: "Detach nunca elimina permanentemente. Todo se mueve a la papelera y queda registrado en Historial para restaurar."
        )
    }
    var applicationBundle: String {
        value(en: "Application bundle", tr: "Uygulama paketi", fr: "Paquet de l'app", de: "App-Paket", es: "Paquete de la app")
    }
    func relatedItems(_ count: Int) -> String {
        value(en: "\(count) related item(s)", tr: "\(count) ilişkili öğe", fr: "\(count) élément(s) associé(s)", de: "\(count) zugehörige Elemente", es: "\(count) elemento(s) relacionado(s)")
    }
    var relatedItemsDetail: String {
        value(
            en: "Preferences, caches, support files, and containers found with safe confidence",
            tr: "Güvenli eşleşen tercihler, önbellekler, destek dosyaları ve container verileri",
            fr: "Préférences, caches, fichiers de support et conteneurs identifiés avec confiance",
            de: "Einstellungen, Caches, Supportdateien und Container mit sicherer Zuordnung",
            es: "Preferencias, cachés, archivos de soporte y contenedores detectados con confianza"
        )
    }
    func skippedItems(_ count: Int) -> String {
        value(en: "\(count) item(s) skipped", tr: "\(count) öğe atlandı", fr: "\(count) élément(s) ignoré(s)", de: "\(count) Elemente übersprungen", es: "\(count) elemento(s) omitidos")
    }
    var skippedItemsDetail: String {
        value(
            en: "Low confidence, protected, or symbolic link items are never moved automatically",
            tr: "Düşük güvenli, korumalı veya sembolik link olan öğeler otomatik taşınmaz",
            fr: "Les éléments peu fiables, protégés ou liens symboliques ne sont jamais déplacés automatiquement",
            de: "Unsichere, geschützte oder symbolische Links werden nie automatisch verschoben",
            es: "Los elementos de baja confianza, protegidos o enlaces simbólicos nunca se mueven automáticamente"
        )
    }
    func adminItems(_ count: Int) -> String {
        value(en: "\(count) admin-only item(s)", tr: "\(count) admin öğesi", fr: "\(count) élément(s) admin", de: "\(count) Admin-Elemente", es: "\(count) elemento(s) de administrador")
    }
    var adminItemsDetail: String {
        value(
            en: "System-wide related files under /Library. Select individually; password required at removal time.",
            tr: "/Library altındaki sistem geneli ilişkili dosyalar. Tek tek seçilir; kaldırma anında parola gerekir.",
            fr: "Fichiers associés système sous /Library. Sélection individuelle ; mot de passe requis au moment de la suppression.",
            de: "Systemweite zugehörige Dateien unter /Library. Einzeln auswählen; Passwort erst beim Entfernen nötig.",
            es: "Archivos relacionados del sistema bajo /Library. Selección individual; contraseña requerida al eliminar."
        )
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
        value(
            en: "Settings, caches, and support data are preserved",
            tr: "Ayarlar, önbellekler ve destek verileri korunur",
            fr: "Les réglages, caches et données de support sont conservés",
            de: "Einstellungen, Caches und Supportdaten bleiben erhalten",
            es: "Se conservan ajustes, cachés y datos de soporte"
        )
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
        value(
            en: "A second confirmation is required before anything is moved. Items go to Trash and an undo manifest is written.",
            tr: "Herhangi bir şey taşınmadan önce ikinci onay gerekir. Öğeler Çöp Sepeti'ne taşınır ve geri alma manifesti yazılır.",
            fr: "Une seconde confirmation est requise avant tout déplacement. Les éléments vont à la corbeille et un manifeste est créé.",
            de: "Vor dem Verschieben ist eine zweite Bestätigung erforderlich. Elemente landen im Papierkorb und ein Manifest wird erstellt.",
            es: "Se requiere una segunda confirmación antes de mover nada. Los elementos van a la papelera y se crea un manifiesto."
        )
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
        value(
            en: "Control how Detach looks, scans, reviews, and records removals.",
            tr: "Detach'in görünümünü, taramasını, incelemesini ve kayıtlarını yönetin.",
            fr: "Contrôlez l'apparence, l'analyse, la vérification et l'historique de Detach.",
            de: "Steuere Darstellung, Scans, Prüfung und Verlauf von Detach.",
            es: "Controla apariencia, escaneo, revisión e historial de Detach."
        )
    }
    var themeDetail: String {
        value(
            en: "Choose the visual mood for the app.",
            tr: "Uygulamanın görsel havasını seçin.",
            fr: "Choisissez l'ambiance visuelle de l'app.",
            de: "Wähle die visuelle Stimmung der App.",
            es: "Elige el estilo visual de la app."
        )
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
        value(
            en: "Detach scans /Applications, ~/Applications, and safe Library locations for related files.",
            tr: "Detach /Applications, ~/Applications ve güvenli Library konumlarını ilişkili dosyalar için tarar.",
            fr: "Detach analyse /Applications, ~/Applications et les emplacements Library sûrs.",
            de: "Detach scannt /Applications, ~/Applications und sichere Library-Orte.",
            es: "Detach escanea /Applications, ~/Applications y ubicaciones seguras de Library."
        )
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
        value(
            en: "Always required before moving anything to Trash.",
            tr: "Herhangi bir şey Çöp Sepeti'ne taşınmadan önce her zaman gerekir.",
            fr: "Toujours requise avant tout déplacement vers la corbeille.",
            de: "Immer erforderlich, bevor etwas in den Papierkorb verschoben wird.",
            es: "Siempre requerida antes de mover algo a la papelera."
        )
    }
    var historySettingsDetail: String {
        value(
            en: "Restore and history cleanup are managed from the History sheet.",
            tr: "Geri yükleme ve geçmiş temizliği Geçmiş penceresinden yönetilir.",
            fr: "La restauration et le nettoyage de l'historique se gèrent depuis l'historique.",
            de: "Wiederherstellung und Verlaufspflege werden im Verlauf verwaltet.",
            es: "La restauración y limpieza del historial se gestionan desde Historial."
        )
    }
    var historyStorage: String {
        value(en: "History storage", tr: "Geçmiş depolama", fr: "Stockage de l'historique", de: "Verlaufsspeicher", es: "Almacenamiento del historial")
    }
    var historyStorageDetail: String {
        value(
            en: "Manifests are saved in Application Support under Detach.",
            tr: "Manifestler Application Support altında Detach klasörüne kaydedilir.",
            fr: "Les manifestes sont enregistrés dans Application Support sous Detach.",
            de: "Manifeste werden in Application Support unter Detach gespeichert.",
            es: "Los manifiestos se guardan en Application Support dentro de Detach."
        )
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
        value(
            en: "This removes Detach history records only. It does not delete files from Trash or original locations.",
            tr: "Bu yalnızca Detach geçmiş kayıtlarını kaldırır. Çöp Sepeti'nden veya özgün konumlardan dosya silmez.",
            fr: "Cela supprime seulement l'historique de Detach, pas les fichiers.",
            de: "Dies entfernt nur Detach-Verlaufseinträge, keine Dateien.",
            es: "Esto solo elimina registros de Detach, no archivos."
        )
    }
    var accessibility: String {
        value(en: "Accessibility", tr: "Erişilebilirlik", fr: "Accessibilité", de: "Bedienungshilfen", es: "Accesibilidad")
    }
    var accessibilityPermission: String {
        value(en: "Accessibility permission", tr: "Erişilebilirlik izni", fr: "Autorisation d'accessibilité", de: "Bedienungshilfen-Zugriff", es: "Permiso de accesibilidad")
    }
    var accessibilityPermissionDetail: String {
        value(
            en: "Give Detach macOS Accessibility permission once if you want smoother permission handling.",
            tr: "Daha sorunsuz izin yönetimi için Detach'e macOS Erişilebilirlik iznini bir kez verebilirsiniz.",
            fr: "Accordez l'autorisation d'accessibilité macOS une fois pour une gestion plus fluide.",
            de: "Erteile Detach einmalig Bedienungshilfen-Zugriff für reibungslosere Berechtigungen.",
            es: "Da permiso de accesibilidad de macOS una vez para una gestión más fluida."
        )
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
        value(
            en: "macOS currently trusts Detach for Accessibility.",
            tr: "macOS şu anda Detach'e Erişilebilirlik için güveniyor.",
            fr: "macOS fait actuellement confiance à Detach pour l'accessibilité.",
            de: "macOS vertraut Detach aktuell für Bedienungshilfen.",
            es: "macOS confía actualmente en Detach para accesibilidad."
        )
    }
    var accessibilityNotGrantedDetail: String {
        value(
            en: "Detach will not ask on launch. You can grant access from here when you are ready.",
            tr: "Detach açılışta sormaz. Hazır olduğunuzda buradan erişim verebilirsiniz.",
            fr: "Detach ne demande rien au lancement. Vous pouvez accorder l'accès ici.",
            de: "Detach fragt nicht beim Start. Du kannst den Zugriff hier erteilen.",
            es: "Detach no lo pedirá al iniciar. Puedes conceder acceso desde aquí."
        )
    }
    var accessibilityOneTimeApproval: String {
        value(en: "One-time macOS approval", tr: "Tek seferlik macOS onayı", fr: "Approbation macOS unique", de: "Einmalige macOS-Freigabe", es: "Aprobación única de macOS")
    }
    var accessibilityOneTimeApprovalDetail: String {
        value(
            en: "macOS requires the user to approve this manually. Once approved for the installed app, it should persist.",
            tr: "macOS bu iznin kullanıcı tarafından elle onaylanmasını ister. Kurulu uygulama için onaylanınca kalıcı olmalıdır.",
            fr: "macOS exige une approbation manuelle. Une fois accordée pour l'app installée, elle devrait persister.",
            de: "macOS verlangt eine manuelle Freigabe. Für die installierte App sollte sie danach bestehen bleiben.",
            es: "macOS exige aprobación manual. Una vez concedida para la app instalada, debería persistir."
        )
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
        value(
            en: "Apps you move to Trash will appear here with restore details.",
            tr: "Çöp Sepeti'ne taşıdığınız uygulamalar geri yükleme detaylarıyla burada görünür.",
            fr: "Les apps envoyées à la corbeille apparaîtront ici avec les détails de restauration.",
            de: "Apps, die in den Papierkorb verschoben wurden, erscheinen hier mit Wiederherstellungsdetails.",
            es: "Las apps movidas a la papelera aparecerán aquí con detalles de restauración."
        )
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
                switch language {
                case .english:
                    return "Moves only the application bundle to Trash. Preferences, caches, and support files stay on this Mac."
                case .turkish:
                    return "Yalnızca uygulama paketini Çöp Sepeti'ne taşır. Tercihler, önbellekler ve destek dosyaları bu Mac'te kalır."
                case .french:
                    return "Déplace seulement le paquet de l'app vers la corbeille. Les préférences, caches et fichiers de support restent sur ce Mac."
                case .german:
                    return "Verschiebt nur das App-Paket in den Papierkorb. Einstellungen, Caches und Supportdateien bleiben auf diesem Mac."
                case .spanish:
                    return "Mueve solo el paquete de la app a la papelera. Las preferencias, cachés y archivos de soporte se quedan en este Mac."
                }
            case .appAndFiles:
                switch language {
                case .english:
                    return "Moves the application bundle and safe user-space related files to Trash. Risky matches are left untouched."
                case .turkish:
                    return "Uygulama paketini ve güvenli kullanıcı alanı ilişkili dosyalarını Çöp Sepeti'ne taşır. Riskli eşleşmeler olduğu gibi bırakılır."
                case .french:
                    return "Déplace l'app et les fichiers associés sûrs vers la corbeille. Les correspondances risquées sont ignorées."
                case .german:
                    return "Verschiebt die App und sichere zugehörige Benutzerdateien in den Papierkorb. Riskante Treffer bleiben unverändert."
                case .spanish:
                    return "Mueve la app y los archivos relacionados seguros a la papelera. Las coincidencias arriesgadas se dejan intactas."
                }
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
