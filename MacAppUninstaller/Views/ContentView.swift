import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: AppUninstallerViewModel
    @State private var isSidebarCompact = false
    @AppStorage("appLanguage") private var languageCode = AppLanguage.english.rawValue
    @AppStorage("appearanceMode") private var appearanceModeCode = AppAppearanceMode.light.rawValue
    @AppStorage("autoScanOnLaunch") private var autoScanOnLaunch = true
    @AppStorage("startSidebarCompact") private var startSidebarCompact = false
    @AppStorage("defaultUninstallMode") private var defaultUninstallModeCode = AppUninstallerViewModel.UninstallMode.appOnly.rawValue
    @AppStorage("showAdminOnlyMatches") private var showAdminOnlyMatches = true
    @AppStorage("showSkippedMatches") private var showSkippedMatches = true
    @AppStorage("warnBeforeAdminCleanup") private var warnBeforeAdminCleanup = true

    init(viewModel: AppUninstallerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        let compact = UserDefaults.standard.object(forKey: "startSidebarCompact") as? Bool ?? false
        _isSidebarCompact = State(initialValue: compact)
    }

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
            AppListView(
                viewModel: viewModel,
                isCompact: $isSidebarCompact,
                defaultUninstallModeCode: defaultUninstallModeCode,
                language: language
            )
                .frame(width: isSidebarCompact ? 72 : 330)
                .background(appearanceMode.sidebarBackground)
            Divider()
            DetailView(viewModel: viewModel, language: language)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(appearanceMode.windowBackground)
        .animation(.easeInOut(duration: 0.18), value: isSidebarCompact)
        .task {
            viewModel.applyDefaultUninstallMode(defaultUninstallModeCode)
            if autoScanOnLaunch && viewModel.apps.isEmpty {
                viewModel.scanApps()
            }
        }
        .onChange(of: defaultUninstallModeCode) { newValue in
            viewModel.applyDefaultUninstallMode(newValue)
        }
        .onChange(of: startSidebarCompact) { newValue in
            withAnimation(.easeInOut(duration: 0.18)) {
                isSidebarCompact = newValue
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .detachScanRequested)) { _ in
            viewModel.scanApps()
        }
        .onReceive(NotificationCenter.default.publisher(for: .detachHistoryRequested)) { _ in
            viewModel.openHistory()
        }
        .onReceive(NotificationCenter.default.publisher(for: .detachAdminSelectionResetRequested)) { _ in
            viewModel.clearAdminFileSelection()
        }
        .sheet(isPresented: $viewModel.isReviewPresented) {
            ReviewSheet(viewModel: viewModel, language: language)
        }
        .sheet(isPresented: $viewModel.isHistoryPresented) {
            HistorySheet(viewModel: viewModel, language: language)
        }
        .confirmationDialog(
            text.moveAppTitle(viewModel.selectedApp?.name),
            isPresented: $viewModel.isSecondConfirmationPresented
        ) {
            Button(text.moveToTrash, role: .destructive) {
                viewModel.uninstallSelectedApp()
            }
            Button(text.cancel, role: .cancel) {}
        } message: {
            Text(viewModel.selectedAdminFiles.isEmpty || !warnBeforeAdminCleanup ? text.confirmationMessage : "\(text.confirmationMessage)\n\n\(text.adminPasswordRequired)")
        }
    }
}

private struct AppListView: View {
    @ObservedObject var viewModel: AppUninstallerViewModel
    @Binding var isCompact: Bool
    let defaultUninstallModeCode: String
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                if isCompact {
                    VStack(spacing: 8) {
                        AppLogoView(size: 34)
                        SidebarToggleButton(isCompact: $isCompact)
                        .help(text.showAppNames)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    AppLogoView(size: 28)
                    TextField(text.searchApps, text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                    if viewModel.state == .scanningApps {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Button {
                        viewModel.openHistory()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .frame(width: 26, height: 26)
                    }
                    .buttonStyle(.plain)
                    .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 7))
                    .help(text.history)
                    SettingsButton(language: language)
                    SidebarToggleButton(isCompact: $isCompact)
                    .help(text.showIconsOnly)
                }
            }
            .padding(isCompact ? 10 : 12)

            if isCompact {
                CompactAppIconList(viewModel: viewModel, defaultUninstallModeCode: defaultUninstallModeCode)
            } else {
                ExpandedAppList(viewModel: viewModel, defaultUninstallModeCode: defaultUninstallModeCode)
            }
        }
    }
}

private struct SettingsButton: View {
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        Button {
            SettingsWindowPresenter.shared.show()
        } label: {
            Image(systemName: "gearshape")
                .frame(width: 26, height: 26)
        }
        .buttonStyle(.plain)
        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 7))
        .help(text.settings)
    }
}

private struct SidebarToggleButton: View {
    @Binding var isCompact: Bool

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                isCompact.toggle()
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 13, weight: .semibold))
                .rotationEffect(.degrees(isCompact ? 180 : 0))
                .frame(width: 26, height: 26)
                .contentShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 7))
    }
}

private struct AppLogoView: View {
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

private struct CompactAppIconList: View {
    @ObservedObject var viewModel: AppUninstallerViewModel
    let defaultUninstallModeCode: String

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(viewModel.filteredApps) { app in
                    Button {
                        viewModel.applyDefaultUninstallMode(defaultUninstallModeCode)
                        viewModel.select(app)
                    } label: {
                        AppIcon(app: app, size: 34)
                            .frame(width: 52, height: 52)
                            .background(selectionBackground(for: app), in: RoundedRectangle(cornerRadius: 8))
                            .contentShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .help(app.name)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
        }
    }

    private func selectionBackground(for app: InstalledApp) -> Color {
        viewModel.selectedApp?.id == app.id ? Color.accentColor.opacity(0.22) : Color.clear
    }
}

private struct ExpandedAppList: View {
    @ObservedObject var viewModel: AppUninstallerViewModel
    let defaultUninstallModeCode: String

    var body: some View {
        List(viewModel.filteredApps, selection: Binding(
            get: { viewModel.selectedApp?.id },
            set: { id in
                guard let id, let app = viewModel.apps.first(where: { $0.id == id }) else { return }
                viewModel.applyDefaultUninstallMode(defaultUninstallModeCode)
                viewModel.select(app)
            }
        )) { app in
            HStack(spacing: 10) {
                AppIcon(app: app, size: 32)
                VStack(alignment: .leading, spacing: 3) {
                    Text(app.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(app.displayBundleIdentifier)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .tag(app.id)
            .padding(.vertical, 4)
            .help(app.name)
        }
        .listStyle(.sidebar)
    }
}

private struct AppIcon: View {
    let app: InstalledApp
    let size: CGFloat

    var body: some View {
        Group {
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
            } else {
                Image(systemName: "app")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}

private struct DetailView: View {
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let app = viewModel.selectedApp {
                AppHeader(app: app, viewModel: viewModel, language: language)
                Divider()
                RiskBanner(app: app, viewModel: viewModel, language: language)
                ScrollView {
                    UninstallOptionsView(app: app, viewModel: viewModel, language: language)
                }
            } else {
                VStack(spacing: 14) {
                    ContentUnavailableView(text.noAppSelected, systemImage: "app.dashed")
                    Button {
                        viewModel.scanApps()
                    } label: {
                        Label(text.scanApps, systemImage: "arrow.clockwise")
                    }
                    .controlSize(.large)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct AppHeader: View {
    let app: InstalledApp
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 60, height: 60)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(app.name)
                    .font(.title.weight(.semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(app.displayBundleIdentifier)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                HStack(spacing: 18) {
                    Label("\(text.version) \(app.displayVersion)", systemImage: "number")
                    Label(app.size.formattedByteCount, systemImage: "externaldrive")
                    Label(app.url.path, systemImage: "folder")
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .frame(maxWidth: 1240, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RiskBanner: View {
    let app: InstalledApp
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage
    @AppStorage("showAdminOnlyMatches") private var showAdminOnlyMatches = true
    @AppStorage("showSkippedMatches") private var showSkippedMatches = true

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(spacing: 8) {
            if app.isAppleSignedOrProtected {
                Banner(text: text.protectedAppBanner, symbol: "lock.shield", tint: .red)
            }
            if app.isRunning {
                Banner(text: text.runningAppBanner, symbol: "exclamationmark.triangle", tint: .orange)
            }
            if showSkippedMatches && viewModel.uninstallMode == .appAndFiles && !viewModel.skippedRelatedFiles.isEmpty {
                Banner(text: text.skippedBanner(viewModel.skippedRelatedFiles.count), symbol: "shield.lefthalf.filled", tint: .blue)
            }
            if showAdminOnlyMatches && viewModel.uninstallMode == .appAndFiles && !viewModel.adminRelatedFiles.isEmpty {
                Banner(text: text.adminOnlyBanner(viewModel.adminRelatedFiles.count), symbol: "lock.open.trianglebadge.exclamationmark", tint: .orange)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 10)
        .frame(maxWidth: 1240, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct Banner: View {
    let text: String
    let symbol: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
            Text(text)
                .lineLimit(2)
            Spacer()
        }
        .font(.callout)
        .padding(10)
        .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct UninstallOptionsView: View {
    let app: InstalledApp
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                ModeCard(
                    symbol: "app.badge",
                    title: AppUninstallerViewModel.UninstallMode.appOnly.title(language: language),
                    description: AppUninstallerViewModel.UninstallMode.appOnly.description(language: language),
                    indicatorColor: .blue,
                    isSelected: viewModel.uninstallMode == .appOnly
                ) {
                    viewModel.uninstallMode = .appOnly
                }

                ModeCard(
                    symbol: "trash.slash",
                    title: AppUninstallerViewModel.UninstallMode.appAndFiles.title(language: language),
                    description: AppUninstallerViewModel.UninstallMode.appAndFiles.description(language: language),
                    indicatorColor: .red,
                    isSelected: viewModel.uninstallMode == .appAndFiles
                ) {
                    viewModel.uninstallMode = .appAndFiles
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ActionBar(viewModel: viewModel, language: language)
                .frame(maxWidth: .infinity, alignment: .leading)

            AppDetailsPanel(app: app, viewModel: viewModel, language: language)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 22)
        .frame(maxWidth: 1240, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .overlay {
            if viewModel.state == .scanningFiles {
                ProgressView(text.checkingRelatedFiles)
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

private struct ModeCard: View {
    let symbol: String
    let title: String
    let description: String
    let indicatorColor: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(indicatorColor)
                    .frame(width: 5, height: 72)

                Image(systemName: symbol)
                    .font(.title2)
                    .frame(width: 30)
                    .foregroundStyle(indicatorColor)
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .lineLimit(2)
                    Text(description)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? indicatorColor : indicatorColor.opacity(0.55))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 124, alignment: .leading)
            .background(indicatorColor.opacity(isSelected ? 0.12 : 0.06), in: RoundedRectangle(cornerRadius: 8))
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(indicatorColor.opacity(isSelected ? 0.95 : 0.35), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct AppDetailsPanel: View {
    let app: InstalledApp
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage
    @AppStorage("showAdminOnlyMatches") private var showAdminOnlyMatches = true
    @AppStorage("showSkippedMatches") private var showSkippedMatches = true

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    private var appTypeDescription: String {
        app.isAppleSignedOrProtected ? text.protectedSystemApplication : text.userApplication
    }

    private var statusDescription: String {
        if app.isRunning {
            return text.currentlyRunning
        }
        if app.isAppleSignedOrProtected {
            return text.protected
        }
        return text.readyToRemove
    }

    private var statusTint: Color {
        if app.isRunning { return .orange }
        if app.isAppleSignedOrProtected { return .red }
        return .green
    }

    private var selectedRelatedCount: Int {
        viewModel.selectedFiles.count + viewModel.selectedAdminFiles.count
    }

    private var impactTint: Color {
        viewModel.uninstallMode == .appOnly ? .blue : .red
    }

    private var location: String {
        app.url.deletingLastPathComponent().path
    }

    private var relatedDataSummary: String {
        "\(viewModel.relatedFiles.count) \(text.items.lowercased())"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text.appDetails)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(app.name)
                        .font(.title3.weight(.semibold))
                        .lineLimit(1)
                    Text(app.displayBundleIdentifier)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                Spacer()
                StatusChip(title: statusDescription, tint: statusTint)
            }

            Divider()

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 190), spacing: 18)
            ], alignment: .leading, spacing: 18) {
                DescriptionMetric(symbol: "number", title: text.version, value: app.displayVersion)
                DescriptionMetric(symbol: "externaldrive", title: text.applicationBundle, value: app.size.formattedByteCount)
                DescriptionMetric(symbol: "folder", title: text.appLocation, value: location)
                DescriptionMetric(symbol: "app", title: text.appType, value: appTypeDescription)
                DescriptionMetric(symbol: "tag", title: text.bundleIdentifier, value: app.displayBundleIdentifier)
                DescriptionMetric(symbol: "folder.badge.gearshape", title: text.relatedDataFound, value: relatedDataSummary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Label(text.removalImpact, systemImage: "arrow.down.doc")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(impactTint)

                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 150), spacing: 8)
                ], alignment: .leading, spacing: 8) {
                    ImpactPill(title: viewModel.uninstallMode.title(language: language), symbol: "cursorarrow.click", tint: impactTint)
                    ImpactPill(title: "\(viewModel.selectedTotalSize.formattedByteCount) \(text.willMoveToTrash.lowercased())", symbol: "trash", tint: .secondary)
                    ImpactPill(title: text.relatedItems(selectedRelatedCount), symbol: "folder.badge.minus", tint: impactTint)
                    if showSkippedMatches && !viewModel.skippedRelatedFiles.isEmpty {
                        ImpactPill(title: text.skippedItems(viewModel.skippedRelatedFiles.count), symbol: "shield", tint: .secondary)
                    }
                    if showAdminOnlyMatches && !viewModel.adminRelatedFiles.isEmpty {
                        ImpactPill(title: text.adminItems(viewModel.adminRelatedFiles.count), symbol: "lock.open.trianglebadge.exclamationmark", tint: .orange)
                    }
                }
            }
            .padding(12)
            .background(impactTint.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct StatusChip: View {
    let title: String
    let tint: Color

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.14), in: Capsule())
    }
}

private struct ImpactPill: View {
    let title: String
    let symbol: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption.weight(.medium))
            .foregroundStyle(tint)
            .lineLimit(1)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Color.secondary.opacity(0.08), in: Capsule())
    }
}

private struct DescriptionMetric: View {
    let symbol: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: symbol)
                .frame(width: 18)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }
}

private struct RemovalSummary: View {
    let app: InstalledApp
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage
    @AppStorage("showAdminOnlyMatches") private var showAdminOnlyMatches = true
    @AppStorage("showSkippedMatches") private var showSkippedMatches = true

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    private var selectedRelatedCount: Int {
        viewModel.selectedFiles.count + viewModel.selectedAdminFiles.count
    }

    private var summaryTint: Color {
        viewModel.uninstallMode == .appOnly ? .blue : .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "checklist")
                    .frame(width: 22)
                    .foregroundStyle(summaryTint)
                VStack(alignment: .leading, spacing: 3) {
                    Text(text.removalSummary)
                        .font(.headline)
                    Text(viewModel.uninstallMode.title(language: language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(viewModel.selectedTotalSize.formattedByteCount)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(summaryTint)
            }

            VStack(alignment: .leading, spacing: 10) {
                SummaryRow(
                    symbol: "app",
                    title: app.name,
                    detail: text.applicationBundle,
                    tint: .secondary
                )

                if viewModel.uninstallMode == .appAndFiles {
                    SummaryRow(
                        symbol: "folder.badge.minus",
                        title: text.relatedItems(selectedRelatedCount),
                        detail: "\(viewModel.relatedFilesTotalSize.formattedByteCount) \(text.selected.lowercased())",
                        tint: .red
                    )
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                if showSkippedMatches && !viewModel.skippedRelatedFiles.isEmpty {
                    SummaryChip(
                        symbol: "shield",
                        title: text.skippedItems(viewModel.skippedRelatedFiles.count),
                        tint: .secondary
                    )
                }

                if showAdminOnlyMatches && !viewModel.adminRelatedFiles.isEmpty {
                    SummaryChip(
                        symbol: "lock.open.trianglebadge.exclamationmark",
                        title: viewModel.selectedAdminFiles.isEmpty ? text.adminItems(viewModel.adminRelatedFiles.count) : text.adminItems(viewModel.selectedAdminFiles.count),
                        tint: .orange
                    )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct SummaryRow: View {
    let symbol: String
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .frame(width: 20)
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
        }
    }
}

private struct SummaryChip: View {
    let symbol: String
    let title: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption.weight(.medium))
            .foregroundStyle(tint)
            .lineLimit(1)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(tint.opacity(0.12), in: Capsule())
    }
}

private struct ActionBar: View {
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        HStack {
            Text("\(viewModel.uninstallMode.title(language: language)) · \(viewModel.selectedTotalSize.formattedByteCount)")
                .foregroundStyle(.secondary)
            Spacer()
            if case .failed(let message) = viewModel.state {
                Text(message)
                    .foregroundStyle(.red)
                    .lineLimit(1)
            }
            if case .finished = viewModel.state, let manifest = viewModel.manifest {
                Text(text.movedToTrash(manifest.entries.count))
                    .foregroundStyle(.green)
            }
            if !viewModel.selectedAdminFiles.isEmpty {
                Label(text.adminPasswordRequired, systemImage: "lock")
                    .foregroundStyle(.orange)
                    .lineLimit(1)
            }
            Button {
                viewModel.prepareReview()
            } label: {
                Label(text.uninstall, systemImage: "trash.fill")
                    .font(.headline)
                    .frame(minWidth: 180, minHeight: 38)
            }
            .buttonStyle(.borderedProminent)
            .tint(.gray)
            .controlSize(.large)
            .disabled(!viewModel.canUninstallSelectedApp)
        }
        .padding(.vertical, 6)
    }
}

private struct ReviewSheet: View {
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage
    @Environment(\.dismiss) private var dismiss
    @AppStorage("showAdminOnlyMatches") private var showAdminOnlyMatches = true
    @AppStorage("warnBeforeAdminCleanup") private var warnBeforeAdminCleanup = true

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(text.reviewUninstall)
                .font(.title2.weight(.semibold))
            Text(viewModel.uninstallMode.description(language: language))
                .foregroundStyle(.secondary)

            if let app = viewModel.selectedApp {
                RemovalSummary(app: app, viewModel: viewModel, language: language)
            }

            if showAdminOnlyMatches && viewModel.uninstallMode == .appAndFiles && !viewModel.adminRelatedFiles.isEmpty {
                AdminRelatedFilesSection(viewModel: viewModel, language: language)
            }

            Text(text.secondConfirmationMessage)
                .font(.callout)
                .foregroundStyle(.secondary)
            if warnBeforeAdminCleanup && !viewModel.selectedAdminFiles.isEmpty {
                Label(text.adminPasswordRequired, systemImage: "lock")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.orange)
            }

            HStack {
                Spacer()
                Button(text.cancel) {
                    dismiss()
                }
                Button(role: .destructive) {
                    viewModel.requestSecondConfirmation()
                } label: {
                    Label(text.continueTitle, systemImage: "arrow.right")
                }
            }
        }
        .padding(22)
        .frame(minWidth: 720, minHeight: 460)
    }
}

private struct AdminRelatedFilesSection: View {
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(text.adminOnlyRelatedFiles, systemImage: "lock.open.trianglebadge.exclamationmark")
                    .font(.headline)
                Spacer()
                Text(text.adminItems(viewModel.selectedAdminFiles.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.adminRelatedFiles) { file in
                        AdminRelatedFileRow(file: file, viewModel: viewModel, language: language)
                    }
                }
            }
            .frame(maxHeight: 180)
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct AdminRelatedFileRow: View {
    let file: RelatedFile
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        Toggle(isOn: Binding(
            get: { viewModel.selectedAdminFileIDs.contains(file.id) },
            set: { viewModel.setAdminFile(file, selected: $0) }
        )) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: iconName)
                    .frame(width: 20)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 3) {
                    Text(file.url.lastPathComponent)
                        .font(.callout.weight(.medium))
                        .lineLimit(1)
                    Text(file.url.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text("\(text.matchReason): \(file.reason)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(file.size.formattedByteCount)
                    Text(file.confidence.rawValue)
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
        .toggleStyle(.checkbox)
        .padding(8)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }

    private var iconName: String {
        switch file.kind {
        case .preferences: return "slider.horizontal.3"
        case .caches: return "externaldrive"
        case .launchAgent, .launchDaemon: return "terminal"
        case .privilegedHelper: return "key"
        default: return "folder"
        }
    }
}

private struct HistorySheet: View {
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage
    @Environment(\.dismiss) private var dismiss

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label(text.uninstallHistory, systemImage: "clock.arrow.circlepath")
                    .font(.title2.weight(.semibold))
                Spacer()
                Button(text.close) {
                    dismiss()
                }
            }
            .padding(20)

            Divider()

            if viewModel.historyManifests.isEmpty {
                ContentUnavailableView(
                    text.noHistory,
                    systemImage: "clock",
                    description: Text(text.noHistoryDetail)
                )
                .frame(minWidth: 780, minHeight: 430)
            } else {
                HStack(spacing: 0) {
                    HistoryManifestList(viewModel: viewModel, language: language)
                        .frame(width: 300)
                    Divider()
                    HistoryDetail(viewModel: viewModel, language: language)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(minWidth: 820, minHeight: 500)
            }
        }
        .onAppear {
            viewModel.loadHistory()
        }
    }
}

private struct HistoryManifestList: View {
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        List(viewModel.historyManifests, selection: Binding(
            get: { viewModel.selectedHistoryManifestID },
            set: { viewModel.selectHistoryManifest($0) }
        )) { manifest in
            VStack(alignment: .leading, spacing: 5) {
                Text(manifest.appName)
                    .font(.headline)
                    .lineLimit(1)
                Text(manifest.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Label("\(manifest.entries.count)", systemImage: "doc.on.doc")
                    Text(manifest.totalSize.formattedByteCount)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 5)
            .tag(manifest.id)
        }
        .listStyle(.sidebar)
    }
}

private struct HistoryDetail: View {
    @ObservedObject var viewModel: AppUninstallerViewModel
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let manifest = viewModel.selectedHistoryManifest {
                VStack(alignment: .leading, spacing: 8) {
                    Text(manifest.appName)
                        .font(.title2.weight(.semibold))
                    HStack(spacing: 14) {
                        Label(manifest.createdAt.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                        Label("\(manifest.entries.count) \(text.items.lowercased())", systemImage: "doc.on.doc")
                        Label(manifest.totalSize.formattedByteCount, systemImage: "externaldrive")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if let bundleIdentifier = manifest.bundleIdentifier {
                        Text(bundleIdentifier)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                if let result = viewModel.restoreResult {
                    RestoreResultBanner(result: result, language: language)
                }

                List(manifest.entries) { entry in
                    HistoryEntryRow(entry: entry, result: viewModel.restoreResult, language: language)
                }
                .listStyle(.inset)

                if let historyErrorMessage = viewModel.historyErrorMessage {
                    Text(historyErrorMessage)
                        .foregroundStyle(.red)
                        .lineLimit(2)
                }

                HStack {
                    Button(role: .destructive) {
                        viewModel.removeSelectedManifestFromHistory()
                    } label: {
                        Label(text.removeFromHistory, systemImage: "xmark.circle")
                    }
                    Spacer()
                    Button {
                        viewModel.restoreSelectedHistoryManifest()
                    } label: {
                        Label(text.restore, systemImage: "arrow.uturn.backward.circle.fill")
                            .font(.headline)
                            .frame(minWidth: 130, minHeight: 34)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
        .padding(20)
    }
}

private struct RestoreResultBanner: View {
    let result: RestoreResult
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        Label(
            text.restoreSummary(
                result.restoredEntries.count,
                result.skippedMissingEntries.count,
                result.skippedConflictEntries.count,
                result.failedEntries.count
            ),
            systemImage: result.hasIssues ? "exclamationmark.triangle" : "checkmark.circle"
        )
        .font(.callout)
        .foregroundStyle(result.hasIssues ? .orange : .green)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background((result.hasIssues ? Color.orange : Color.green).opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct HistoryEntryRow: View {
    let entry: DeletionManifest.Entry
    let result: RestoreResult?
    let language: AppLanguage

    private var text: LocalizedText {
        LocalizedText(language: language)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: status.symbol)
                .frame(width: 22)
                .foregroundStyle(status.color)
            VStack(alignment: .leading, spacing: 3) {
                Text(URL(fileURLWithPath: entry.originalPath).lastPathComponent)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                Text(entry.originalPath)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Text(status.title)
                .font(.caption)
                .foregroundStyle(status.color)
        }
        .padding(.vertical, 4)
    }

    private var status: (title: String, symbol: String, color: Color) {
        guard let result else {
            return (entry.confidence.rawValue, "circle", .secondary)
        }
        if result.restoredEntries.contains(where: { $0.id == entry.id }) {
            return (text.restored, "checkmark.circle.fill", .green)
        }
        if result.skippedMissingEntries.contains(where: { $0.id == entry.id }) {
            return (text.missingFromTrash, "questionmark.circle", .orange)
        }
        if result.skippedConflictEntries.contains(where: { $0.id == entry.id }) {
            return (text.destinationExists, "exclamationmark.circle", .orange)
        }
        if result.failedEntries.contains(where: { $0.id == entry.id }) {
            return (text.failed, "xmark.circle", .red)
        }
        return (entry.confidence.rawValue, "circle", .secondary)
    }
}
