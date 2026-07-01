# Detach

Detach is a native macOS utility for uninstalling apps safely. It can remove only the app bundle, or move the app and matched related files to Trash with review, history, and restore support.


<p align="center">
  <img src="media/detach-overview.png" alt="Detach app overview" width="100%" />
</p>

## FULL RELEASE COMING SOON!



## What Detach Does

- Lists apps from `/Applications` and `~/Applications`.
- Offers two uninstall modes: app-only or app with related files.
- Moves files to Trash to delete them.
- Shows risky, skipped, and admin-only matches separately.
- Saves removal history so moved items can be restored.

## Safety

- No permanent delete path.
- Second confirmation before removal.
- Low-confidence matches are never selected automatically.
- Protected Apple/system paths are left untouched.
- Admin-only items are separate and never selected by default.


## Project Structure

- `Detach/Views`: SwiftUI app UI.
- `Detach/ViewModels`: app state and uninstall flow.
- `Detach/Models`: app, related-file, and manifest models.
- `Detach/Services`: scanning, Trash movement, history, restore, and permission services.
- `DetachTests`: unit tests for scanning, risk, manifests, restore, and deletion services.
- `Casks/detach.rb`: Homebrew cask for the release DMG.

## License

Detach is licensed under the [MIT License](LICENSE).
