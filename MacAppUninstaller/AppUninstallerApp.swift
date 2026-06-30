import SwiftUI

@main
struct AppUninstallerApp: App {
    @AppStorage("appearanceMode") private var appearanceModeCode = AppAppearanceMode.light.rawValue
    @AppStorage("appLanguage") private var languageCode = AppLanguage.english.rawValue

    private var appearanceMode: AppAppearanceMode {
        AppAppearanceMode(rawValue: appearanceModeCode) ?? .light
    }

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .english
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: AppUninstallerViewModel())
                .frame(minWidth: 1120, minHeight: 720)
                .preferredColorScheme(appearanceMode.colorScheme)
                .tint(appearanceMode.accentColor)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button(LocalizedText(language: language).settings) {
                    SettingsWindowPresenter.shared.show()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }

        Settings {
            SettingsView()
                .preferredColorScheme(appearanceMode.colorScheme)
                .tint(appearanceMode.accentColor)
        }
    }
}
