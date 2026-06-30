# Detach

Native macOS 13+ SwiftUI utility for listing installed apps, scanning related support files, reviewing risk, and moving selected user-space files to Trash.

<p align="center">
  <a href="https://github.com/arlkn/Detach/releases/latest/download/Detach.dmg">
    <img src="MacAppUninstaller/Resources/AppIcon.png" alt="Download Detach" width="128" />
  </a>
</p>

<p align="center">
  <strong>Click the icon to download the latest Detach DMG</strong>
</p>

## Kurulum

1. `MacAppUninstaller.xcodeproj` dosyasını Xcode ile açın.
2. `MacAppUninstaller` scheme'ini seçin.
3. Signing için kendi development team'inizi seçin.
4. Build and Run.

## Komut Satırı Build

Full Xcode yoksa proje `swiftc` fallback ile de çalıştırılabilir:

```bash
./script/build_and_run.sh
```

Sadece app bundle üretmek için:

```bash
./script/build_and_run.sh --build-only
```

## DMG Paketi

İndirilebilir macOS disk imajı üretmek için:

```bash
./script/package_dmg.sh
```

Çıktı:

```text
build/dist/Detach.dmg
```

Not: Bu geliştirme paketi ad-hoc imzalıdır ve notarize edilmemiştir. Genel dağıtım için Apple Developer ID sertifikası, hardened runtime ve notarization akışı eklenmelidir.

## Ana Dosya Yapısı

- `MacAppUninstaller/AppUninstallerApp.swift`: SwiftUI app entry point.
- `MacAppUninstaller/Views/ContentView.swift`: Sol uygulama listesi, detay paneli, kaldırma modları, review ve ikinci onay akışı.
- `MacAppUninstaller/ViewModels/AppUninstallerViewModel.swift`: MVVM state, selection ve deletion orchestration.
- `MacAppUninstaller/Models`: `InstalledApp`, `RelatedFile`, `DeletionManifest`.
- `MacAppUninstaller/Services/AppScanner.swift`: `/Applications` ve `~/Applications` içindeki `.app` paketlerini tarar.
- `MacAppUninstaller/Services/RelatedFileScanner.swift`: Kullanıcı ve sistem Library lokasyonlarında ilişkili dosyaları listeler.
- `MacAppUninstaller/Services/RiskClassifier.swift`: Bundle id, uygulama adı ve ters domain eşleşmesiyle güven seviyesi üretir.
- `MacAppUninstaller/Services/FileDeletionService.swift`: Güvenlik doğrulaması sonrası seçili dosyaları Trash'e taşır.
- `MacAppUninstaller/Services/ManifestStore.swift`: Undo manifest JSON dosyalarını yazar.
- `MacAppUninstaller/Services/RestoreService.swift`: History manifestlerinden Trash'e taşınan öğeleri özgün konumlarına geri yükler.
- `MacAppUninstallerTests`: Risk, eşleşme ve Trash mock testleri.

## Gereken İzinler

İlk sürüm sandbox kapalı olacak şekilde yapılandırıldı (`ENABLE_APP_SANDBOX = NO`). Bunun nedeni uygulamanın `~/Library` ve salt listeleme için `/Library` altındaki farklı konumları okuyabilmesidir.

Kullanıcı alanındaki dosyaları Trash'e taşıma desteklenir. `/Library/...` gibi sistem genelindeki ilişkili dosyalar ayrı gösterilir, varsayılan seçilmez ve yalnızca kaldırma anında admin onayı istenir.

## Sınırlamalar

- v1 kalıcı silme yapmaz; yalnızca Trash'e taşır.
- Apple/system protected uygulamalar için uygulama bundle'ını kaldırma akışı eklenmedi.
- Kod imza doğrulaması derin notarization veya certificate-chain analizi yapmaz; bundle id ve bilinen sistem uygulaması korumalarıyla muhafazakar davranır.

## Güvenlik Notları

- Hiçbir dosya otomatik taşınmaz.
- Kullanıcı önce Review ekranını, sonra ikinci onay dialog'unu geçmek zorundadır.
- Low confidence dosyalar varsayılan seçili gelmez.
- `/System`, `/bin`, `/usr`, `/sbin` gibi sistem dizinleri taşınmaz.
- Symlink dosyalar otomatik seçilmez ve taşınmaz; hedef körlemesine takip edilmez.
- Bundle ID eşleşmesi olmayan dosyalar düşük veya orta güvene düşürülür.
- Sistem genelindeki dosyalar admin gerektirir olarak işaretlenir, varsayılan seçilmez ve açık kullanıcı onayı olmadan taşınmaz.
- Her başarılı Trash işlemi için `~/Library/Application Support/Detach/DeletionManifests` altında undo manifest yazılır.

## Gelecek Sürüm Planı

- Authorization Services veya SMAppService tabanlı signed privileged helper.
- Daha güçlü Apple code-signing doğrulaması.
- Daha ayrıntılı eşleşme denetimi ve kullanıcıya confidence açıklamaları.
- CI üzerinde `xcodebuild test` entegrasyonu.

## License

Detach is licensed under the [MIT License](LICENSE).
