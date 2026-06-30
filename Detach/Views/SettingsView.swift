import AppKit
import SwiftUI

@MainActor
final class SettingsWindowPresenter {
    static let shared = SettingsWindowPresenter()

    private var window: NSWindow?

    private init() {}

    func show() {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hostingController = NSHostingController(rootView: SettingsWindowContent())
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Detach Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.setContentSize(NSSize(width: 820, height: 560))
        window.center()
        self.window = window

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

private struct SettingsWindowContent: View {
    @AppStorage("appearanceMode") private var appearanceModeCode = AppAppearanceMode.light.rawValue

    private var appearanceMode: AppAppearanceMode {
        AppAppearanceMode(rawValue: appearanceModeCode) ?? .light
    }

    var body: some View {
        SettingsView()
            .preferredColorScheme(appearanceMode.colorScheme)
    }
}

struct SettingsView: View {
    @AppStorage("appLanguage") private var languageCode = AppLanguage.english.rawValue
    @AppStorage("appearanceMode") private var appearanceModeCode = AppAppearanceMode.light.rawValue
    @AppStorage("startSidebarCompact") private var startSidebarCompact = false
    @AppStorage("autoScanOnLaunch") private var autoScanOnLaunch = true
    @AppStorage("defaultUninstallMode") private var defaultUninstallMode = AppUninstallerViewModel.UninstallMode.appOnly.rawValue
    @AppStorage("showAdminOnlyMatches") private var showAdminOnlyMatches = true
    @AppStorage("showSkippedMatches") private var showSkippedMatches = true
    @AppStorage("warnBeforeAdminCleanup") private var warnBeforeAdminCleanup = true
    @AppStorage("historyRetentionMode") private var historyRetentionMode = HistoryRetentionMode.keepAll.rawValue
    @State private var selectedSection = SettingsSection.appearance
    @State private var historyManifests: [DeletionManifest] = []
    @State private var historyErrorMessage: String?
    @State private var isClearHistoryConfirmationPresented = false

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .english
    }

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    private var appearanceMode: AppAppearanceMode {
        AppAppearanceMode(rawValue: appearanceModeCode) ?? .light
    }

    var body: some View {
        HStack(spacing: 0) {
            SettingsSidebar(
                selection: $selectedSection,
                appearanceModeCode: $appearanceModeCode,
                language: language,
                appearanceMode: appearanceMode
            )
            .frame(width: 188)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SettingsHeader(section: selectedSection, language: language)

                    switch selectedSection {
                    case .appearance:
                        AppearanceSettingsSection(
                            languageCode: $languageCode,
                            appearanceModeCode: $appearanceModeCode,
                            language: language,
                            appearanceMode: appearanceMode
                        )
                    case .scan:
                        ScanSettingsSection(
                            autoScanOnLaunch: $autoScanOnLaunch,
                            startSidebarCompact: $startSidebarCompact,
                            language: language,
                            appearanceMode: appearanceMode
                        )
                    case .uninstall:
                        UninstallSettingsSection(
                            defaultUninstallMode: $defaultUninstallMode,
                            language: language,
                            appearanceMode: appearanceMode
                        )
                    case .adminCleanup:
                        AdminCleanupSettingsSection(
                            showAdminOnlyMatches: $showAdminOnlyMatches,
                            showSkippedMatches: $showSkippedMatches,
                            warnBeforeAdminCleanup: $warnBeforeAdminCleanup,
                            language: language,
                            appearanceMode: appearanceMode
                        )
                    case .history:
                        HistorySettingsSection(
                            historyRetentionMode: $historyRetentionMode,
                            historyManifests: historyManifests,
                            historyErrorMessage: historyErrorMessage,
                            language: language,
                            appearanceMode: appearanceMode,
                            refresh: refreshHistory,
                            openHistory: openHistory,
                            clearHistory: { isClearHistoryConfirmationPresented = true }
                        )
                    case .accessibility:
                        AccessibilitySettingsSection(
                            language: language,
                            appearanceMode: appearanceMode
                        )
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(appearanceMode.windowBackground)
        }
        .frame(width: 720, height: 460)
        .background(appearanceMode.windowBackground)
        .tint(appearanceMode.accentColor)
        .onAppear {
            normalizeAppearanceMode()
            refreshHistory()
        }
        .onChange(of: appearanceModeCode) { _ in
            normalizeAppearanceMode()
        }
        .confirmationDialog(
            text.clearHistoryTitle,
            isPresented: $isClearHistoryConfirmationPresented
        ) {
            Button(text.clearHistory, role: .destructive) {
                clearHistory()
            }
            Button(text.cancel, role: .cancel) {}
        } message: {
            Text(text.clearHistoryDetail)
        }
    }

    private var normalizedAppearanceMode: AppAppearanceMode {
        AppAppearanceMode(rawValue: appearanceModeCode) ?? .light
    }

    private func normalizeAppearanceMode() {
        if AppAppearanceMode(rawValue: appearanceModeCode) == nil {
            appearanceModeCode = AppAppearanceMode.light.rawValue
        }
    }

    private func refreshHistory() {
        do {
            historyManifests = try ManifestStore().loadAll()
            historyErrorMessage = nil
        } catch {
            historyErrorMessage = error.localizedDescription
        }
    }

    private func openHistory() {
        NotificationCenter.default.post(name: .detachHistoryRequested, object: nil)
    }

    private func clearHistory() {
        do {
            let store = ManifestStore()
            for manifest in historyManifests {
                try store.delete(manifest)
            }
            refreshHistory()
        } catch {
            historyErrorMessage = error.localizedDescription
        }
    }
}

private enum SettingsSection: String, CaseIterable, Identifiable {
    case appearance
    case scan
    case uninstall
    case adminCleanup
    case history
    case accessibility

    var id: Self { self }

    var symbol: String {
        switch self {
        case .appearance: return "paintpalette"
        case .scan: return "magnifyingglass"
        case .uninstall: return "trash"
        case .adminCleanup: return "lock.open.trianglebadge.exclamationmark"
        case .history: return "clock.arrow.circlepath"
        case .accessibility: return "accessibility"
        }
    }

    func title(_ text: LocalizedText) -> String {
        switch self {
        case .appearance: return text.appearance
        case .scan: return text.scan
        case .uninstall: return text.uninstallSettings
        case .adminCleanup: return text.adminCleanup
        case .history: return text.history
        case .accessibility: return text.accessibility
        }
    }
}

private struct SettingsSidebar: View {
    @Binding var selection: SettingsSection
    @Binding var appearanceModeCode: String
    let language: AppLanguage
    let appearanceMode: AppAppearanceMode

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                SettingsLogoView(size: 36)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Detach")
                        .font(.headline)
                    Text(text.settings)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 4)

            VStack(spacing: 6) {
                ForEach(SettingsSection.allCases) { section in
                    Button {
                        selection = section
                    } label: {
                        HStack(spacing: 9) {
                            Image(systemName: section.symbol)
                                .frame(width: 18)
                            Text(section.title(text))
                                .lineLimit(1)
                            Spacer()
                        }
                        .font(.callout.weight(selection == section ? .semibold : .regular))
                        .foregroundStyle(selection == section ? Color.primary : Color.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(selection == section ? appearanceMode.accentColor.opacity(0.16) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text(text.themes)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    ForEach(AppAppearanceMode.allCases) { mode in
                        Button {
                            appearanceModeCode = mode.rawValue
                        } label: {
                            Circle()
                                .fill(mode.accentColor)
                                .frame(width: 16, height: 16)
                                .overlay {
                                    Circle()
                                        .stroke(mode == appearanceMode ? appearanceMode.controlText : Color.secondary.opacity(0.35), lineWidth: mode == appearanceMode ? 2 : 1)
                                }
                                .padding(3)
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .help(mode.title(language: language))
                        .accessibilityLabel(mode.title(language: language))
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(appearanceMode.sidebarBackground)
    }
}

private struct SettingsHeader: View {
    let section: SettingsSection
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(section.title(text), systemImage: section.symbol)
                .font(.title2.weight(.semibold))
            Text(text.settingsSubtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }
}

private struct AppearanceSettingsSection: View {
    @Binding var languageCode: String
    @Binding var appearanceModeCode: String
    let language: AppLanguage
    let appearanceMode: AppAppearanceMode

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsCard(title: text.themes, detail: text.themeDetail, symbol: "paintpalette", appearanceMode: appearanceMode) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 10)], alignment: .leading, spacing: 10) {
                    ForEach(AppAppearanceMode.allCases) { mode in
                        ThemeOptionCard(
                            mode: mode,
                            language: language,
                            isSelected: appearanceModeCode == mode.rawValue
                        ) {
                            appearanceModeCode = mode.rawValue
                        }
                    }
                }
            }

            SettingsCard(title: text.languageSetting, detail: text.settingsSubtitle, symbol: "globe", appearanceMode: appearanceMode) {
                HStack {
                    Text(text.languageSetting)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(appearanceMode.controlText)
                    Spacer()
                    Picker(text.languageSetting, selection: $languageCode) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.title).tag(language.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(appearanceMode.accentColor)
                    .foregroundStyle(appearanceMode.controlText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(appearanceMode.controlBackground, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

private struct ScanSettingsSection: View {
    @Binding var autoScanOnLaunch: Bool
    @Binding var startSidebarCompact: Bool
    let language: AppLanguage
    let appearanceMode: AppAppearanceMode

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsCard(title: text.scan, detail: text.scanScopeDetail, symbol: "magnifyingglass", appearanceMode: appearanceMode) {
                Toggle(text.autoScanOnLaunch, isOn: $autoScanOnLaunch)
                Toggle(text.startSidebarCompact, isOn: $startSidebarCompact)

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(text.scanNow)
                            .font(.callout.weight(.medium))
                        Text(text.scanScopeDetail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    Button {
                        NotificationCenter.default.post(name: .detachScanRequested, object: nil)
                    } label: {
                        Label(text.scanNow, systemImage: "arrow.clockwise")
                    }
                }
            }

            SettingsCard(title: text.scanScope, detail: text.scanScopeDetail, symbol: "folder.badge.gearshape", appearanceMode: appearanceMode) {
                SafetyStatusRow(title: "/Applications", detail: text.applicationBundle, status: text.alwaysOn, tint: .green)
                SafetyStatusRow(title: "~/Applications", detail: text.userApplication, status: text.alwaysOn, tint: .green)
                SafetyStatusRow(title: "~/Library + /Library", detail: text.relatedItemsDetail, status: text.alwaysOn, tint: .green)
            }
        }
    }
}

private struct UninstallSettingsSection: View {
    @Binding var defaultUninstallMode: String
    let language: AppLanguage
    let appearanceMode: AppAppearanceMode

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsCard(title: text.uninstallSettings, detail: text.doubleConfirmationDetail, symbol: "trash", appearanceMode: appearanceMode) {
                Picker(text.defaultUninstallMode, selection: $defaultUninstallMode) {
                    ForEach(AppUninstallerViewModel.UninstallMode.allCases) { mode in
                        Text(mode.title(language: language)).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.radioGroup)
            }

            SettingsCard(title: text.lockedSafetyRules, detail: text.doubleConfirmationDetail, symbol: "checkmark.shield", appearanceMode: appearanceMode) {
                SafetyStatusRow(title: text.doubleConfirmation, detail: text.doubleConfirmationDetail, status: text.alwaysOn, tint: .green)
                SafetyStatusRow(title: text.movedToTrashOnly, detail: text.safetyNoteDetail, status: text.alwaysOn, tint: .green)
                SafetyStatusRow(title: text.protectedPathsUntouched, detail: text.protectedAppBanner, status: text.alwaysOn, tint: .green)
            }
        }
    }
}

private struct AccessibilitySettingsSection: View {
    let language: AppLanguage
    let appearanceMode: AppAppearanceMode
    @State private var isTrusted = AccessibilityPermissionService().isTrusted()
    private let statusRefreshTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    private let service = AccessibilityPermissionService()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsCard(title: text.accessibilityPermission, detail: text.accessibilityPermissionDetail, symbol: "accessibility", appearanceMode: appearanceMode) {
                SafetyStatusRow(
                    title: text.accessibilityStatus,
                    detail: isTrusted ? text.accessibilityGrantedDetail : text.accessibilityNotGrantedDetail,
                    status: isTrusted ? text.permissionGranted : text.permissionNotGranted,
                    tint: isTrusted ? .green : .orange
                )

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(text.accessibilityOneTimeApproval)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(appearanceMode.controlText)
                        Text(text.accessibilityOneTimeApprovalDetail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Button {
                            service.requestPermissionPrompt()
                            refresh()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                refresh()
                            }
                        } label: {
                            Label(text.requestPermission, systemImage: "hand.raised")
                        }
                        Button {
                            service.openAccessibilitySettings()
                        } label: {
                            Label(text.openSystemSettings, systemImage: "gearshape")
                        }
                    }
                }
            }
        }
        .onAppear(perform: refresh)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refresh()
        }
        .onReceive(statusRefreshTimer) { _ in
            refresh()
        }
    }

    private func refresh() {
        isTrusted = service.isTrusted()
    }
}

private struct AdminCleanupSettingsSection: View {
    @Binding var showAdminOnlyMatches: Bool
    @Binding var showSkippedMatches: Bool
    @Binding var warnBeforeAdminCleanup: Bool
    let language: AppLanguage
    let appearanceMode: AppAppearanceMode

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsCard(title: text.powerUserControls, detail: text.adminItemsDetail, symbol: "lock.open.trianglebadge.exclamationmark", appearanceMode: appearanceMode) {
                Toggle(text.showAdminOnlyMatches, isOn: Binding(
                    get: { showAdminOnlyMatches },
                    set: { newValue in
                        showAdminOnlyMatches = newValue
                        if !newValue {
                            NotificationCenter.default.post(name: .detachAdminSelectionResetRequested, object: nil)
                        }
                    }
                ))
                Toggle(text.showSkippedMatches, isOn: $showSkippedMatches)
                Toggle(text.warnBeforeAdminCleanup, isOn: $warnBeforeAdminCleanup)
            }

            SettingsCard(title: text.lockedSafetyRules, detail: text.adminItemsDetail, symbol: "lock.shield", appearanceMode: appearanceMode) {
                SafetyStatusRow(title: text.adminOnlyRelatedFiles, detail: text.adminItemsDetail, status: text.kept, tint: .orange)
                SafetyStatusRow(title: text.protectedPathsUntouched, detail: text.protectedAppBanner, status: text.alwaysOn, tint: .green)
                SafetyStatusRow(title: text.doubleConfirmation, detail: text.adminPasswordRequired, status: text.alwaysOn, tint: .green)
            }
        }
    }
}

private struct HistorySettingsSection: View {
    @Binding var historyRetentionMode: String
    let historyManifests: [DeletionManifest]
    let historyErrorMessage: String?
    let language: AppLanguage
    let appearanceMode: AppAppearanceMode
    let refresh: () -> Void
    let openHistory: () -> Void
    let clearHistory: () -> Void

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    private var totalHistorySize: Int64 {
        historyManifests.reduce(0) { $0 + $1.totalSize }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsCard(title: text.history, detail: text.historySettingsDetail, symbol: "clock.arrow.circlepath", appearanceMode: appearanceMode) {
                HStack(alignment: .top, spacing: 14) {
                    HistoryStat(title: text.historyCount, value: "\(historyManifests.count)", detail: totalHistorySize.formattedByteCount)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Button {
                            openHistory()
                        } label: {
                            Label(text.openHistory, systemImage: "clock.arrow.circlepath")
                        }
                        Button {
                            refresh()
                        } label: {
                            Label(text.refresh, systemImage: "arrow.clockwise")
                        }
                    }
                }

                if let historyErrorMessage {
                    Text(historyErrorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            SettingsCard(title: text.historyRetention, detail: text.clearHistoryDetail, symbol: "archivebox", appearanceMode: appearanceMode) {
                Picker(text.historyRetention, selection: $historyRetentionMode) {
                    ForEach(HistoryRetentionMode.allCases) { mode in
                        Text(mode.title(language: language)).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.radioGroup)

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(text.historyStorage)
                            .font(.callout.weight(.medium))
                        Text(text.historyStorageDetail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        clearHistory()
                    } label: {
                        Label(text.clearHistory, systemImage: "trash")
                    }
                    .disabled(historyManifests.isEmpty)
                }
            }
        }
    }
}

private struct SafetyStatusRow: View {
    let title: String
    let detail: String
    let status: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(tint)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Text(status)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)
                .lineLimit(1)
        }
        .padding(.vertical, 2)
    }
}

private struct HistoryStat: View {
    let title: String
    let value: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.semibold))
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct SettingsCard<Content: View>: View {
    let title: String
    let detail: String
    let symbol: String
    let appearanceMode: AppAppearanceMode
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: symbol)
                    .frame(width: 22)
                    .foregroundStyle(appearanceMode.accentColor)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }

            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(appearanceMode.panelBackground, in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(appearanceMode.accentColor.opacity(0.18), lineWidth: 1)
        }
    }
}

private struct ThemeOptionCard: View {
    let mode: AppAppearanceMode
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(mode.accentColor)
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(mode.previewBackground)
                        .frame(width: 15, height: 15)
                        .overlay {
                            Circle().stroke(Color.secondary.opacity(0.22), lineWidth: 1)
                        }
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? mode.accentColor : Color.secondary.opacity(0.55))
                }

                Text(mode.title(language: language))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(mode.previewText)
                    .lineLimit(1)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
            .background(mode.previewBackground, in: RoundedRectangle(cornerRadius: 9))
            .overlay(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(mode.previewSurface)
                    .frame(width: 52, height: 7)
                    .padding(12)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 9)
                    .stroke(isSelected ? mode.accentColor : Color.secondary.opacity(0.16), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .help(mode.title(language: language))
    }
}

private struct SettingsLogoView: View {
    let size: CGFloat

    var body: some View {
        Group {
            if let image = Self.logoImage {
                Image(nsImage: image)
                    .resizable()
            } else {
                Image(systemName: "app.fill")
                    .resizable()
                    .foregroundStyle(.blue)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
    }

    private static var logoImage: NSImage? {
        guard let url = Bundle.main.url(forResource: "AppLogo", withExtension: "png") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }
}
