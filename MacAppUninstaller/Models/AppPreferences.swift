import SwiftUI

enum AppAppearanceMode: String, CaseIterable, Identifiable {
    case light
    case dark
    case silver

    var id: Self { self }

    var colorScheme: ColorScheme? {
        switch self {
        case .light, .silver:
            return .light
        case .dark:
            return .dark
        }
    }

    func title(language: AppLanguage) -> String {
        switch self {
        case .light:
            switch language {
            case .english: return "Light"
            case .turkish: return "Açık"
            case .french: return "Clair"
            case .german: return "Hell"
            case .spanish: return "Claro"
            }
        case .dark:
            switch language {
            case .english: return "Dark"
            case .turkish: return "Koyu"
            case .french: return "Sombre"
            case .german: return "Dunkel"
            case .spanish: return "Oscuro"
            }
        case .silver:
            switch language {
            case .english: return "Silver"
            case .turkish: return "Gümüş"
            case .french: return "Argent"
            case .german: return "Silber"
            case .spanish: return "Plateado"
            }
        }
    }

    var accentColor: Color {
        switch self {
        case .light: return .blue
        case .dark: return .blue
        case .silver: return Color(red: 0.50, green: 0.54, blue: 0.60)
        }
    }

    var windowBackground: Color {
        switch self {
        case .light:
            return Color(nsColor: .windowBackgroundColor)
        case .dark:
            return Color(red: 0.10, green: 0.11, blue: 0.12)
        case .silver:
            return Color(red: 0.86, green: 0.87, blue: 0.89)
        }
    }

    var panelBackground: Color {
        switch self {
        case .light:
            return Color.white.opacity(0.58)
        case .dark:
            return Color.white.opacity(0.06)
        case .silver:
            return Color.white.opacity(0.48)
        }
    }

    var sidebarBackground: Color {
        switch self {
        case .light:
            return Color(nsColor: .controlBackgroundColor)
        case .dark:
            return Color.black.opacity(0.16)
        case .silver:
            return Color(red: 0.78, green: 0.80, blue: 0.83)
        }
    }

    var previewBackground: Color {
        switch self {
        case .light:
            return Color(red: 0.96, green: 0.97, blue: 0.98)
        case .dark:
            return Color(red: 0.08, green: 0.09, blue: 0.10)
        case .silver:
            return Color(red: 0.78, green: 0.80, blue: 0.83)
        }
    }

    var previewSurface: Color {
        switch self {
        case .light:
            return .white
        case .dark:
            return Color(red: 0.17, green: 0.18, blue: 0.20)
        case .silver:
            return Color(red: 0.91, green: 0.92, blue: 0.94)
        }
    }

    var previewText: Color {
        switch self {
        case .light, .silver:
            return Color(red: 0.12, green: 0.13, blue: 0.15)
        case .dark:
            return Color(red: 0.92, green: 0.94, blue: 0.96)
        }
    }

    var controlBackground: Color {
        switch self {
        case .light:
            return Color.white.opacity(0.86)
        case .dark:
            return Color.white.opacity(0.08)
        case .silver:
            return Color(red: 0.94, green: 0.95, blue: 0.97)
        }
    }

    var controlText: Color {
        switch self {
        case .light, .silver:
            return Color(red: 0.11, green: 0.12, blue: 0.14)
        case .dark:
            return Color(red: 0.93, green: 0.95, blue: 0.97)
        }
    }
}

enum HistoryRetentionMode: String, CaseIterable, Identifiable {
    case keepAll
    case last30Days
    case last10Removals

    var id: Self { self }

    func title(language: AppLanguage) -> String {
        switch self {
        case .keepAll:
            switch language {
            case .english: return "Keep all history"
            case .turkish: return "Tüm geçmişi tut"
            case .french: return "Tout conserver"
            case .german: return "Gesamten Verlauf behalten"
            case .spanish: return "Conservar todo"
            }
        case .last30Days:
            switch language {
            case .english: return "Last 30 days"
            case .turkish: return "Son 30 gün"
            case .french: return "30 derniers jours"
            case .german: return "Letzte 30 Tage"
            case .spanish: return "Últimos 30 días"
            }
        case .last10Removals:
            switch language {
            case .english: return "Last 10 removals"
            case .turkish: return "Son 10 kaldırma"
            case .french: return "10 dernières suppressions"
            case .german: return "Letzte 10 Entfernungen"
            case .spanish: return "Últimas 10 eliminaciones"
            }
        }
    }
}

extension Notification.Name {
    static let detachScanRequested = Notification.Name("detachScanRequested")
    static let detachHistoryRequested = Notification.Name("detachHistoryRequested")
    static let detachAdminSelectionResetRequested = Notification.Name("detachAdminSelectionResetRequested")
}
