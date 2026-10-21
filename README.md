# TunTask 🚀
### Production-Ready Jira-Style Agile Kanban Board & Task Management

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/Provider-6.1.5-blue.svg)](https://pub.dev/packages/provider)
[![Platform](https://img.shields.io/badge/Platforms-macOS%20%7C%20Web%20%7C%20iOS%20%7C%20Android-4caf50.svg)](#)
[![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen.svg)](#)

**TunTask** adalah aplikasi Task Management & Kanban Board modern berbasis Flutter yang terinspirasi oleh Atlassian Jira. Dirancang dengan estetika modern, gesture Drag-and-Drop native yang halus, kustomisasi tema dinamis (Light/Dark mode & Color Palette), pelacakan subtask interaktif, serta pencarian real-time.

---

## 🌟 Fitur Utama

- 📋 **Kanban Sprint Board Interaktif:**
  - Tampilan scroll horizontal untuk kolom board (*To Do*, *In Progress*, *In Review*, *Done*, dan kolom kustom).
  - Gesture Drag & Drop native (`LongPressDraggable` & `DragTarget`) yang halus, responsif untuk Touch (Mobile) maupun Mouse (Web/Desktop).
  - Indikator drop-zone visual saat memindahkan kartu antar kolom maupun reordering posisi dalam satu kolom.
  - Tambah, edit judul & warna, serta hapus kolom secara dinamis.

- 🗂️ **Task Card ala Jira:**
  - **Chip Prioritas:** Indikator warna dinamis (*Urgent: Merah, High: Oranye, Medium: Biru, Low: Abu-abu*).
  - **Due Date Indicator:** Tanggal jatuh tempo dengan badge peringatan merah jika terlambat (*overdue*).
  - **Subtask Progress:** Penghitung progress dan bar linear dinamis (contoh: `2/3 subtasks`).
  - **Assignee Avatar & Tag Labels:** Inisial avatar berwarna dan chip label modular.

- 📝 **Detail & Inline Edit Modal:**
  - Bottom sheet modal detail task dengan mode baca dan mode edit.
  - Kelola subtask secara interaktif: centang selesai, hapus subtask, dan tambah subtask baru secara instan.
  - Date Picker untuk batas waktu pengerjaan.
  - Dialog konfirmasi saat menghapus task atau kolom.

- 🎨 **Dynamic Theme & Settings:**
  - **Theme Mode Switcher:** Pilihan mode Terang (*Light*), Gelap (*Dark*), dan Otomatis (*System*).
  - **Primary Accent Palette:** Pilihan 8 warna tema Jira/Agile (*TunTask Blue, Emerald Green, Royal Indigo, Deep Purple, Warm Orange, Crimson Red, Ocean Teal, Slate Navy*).
  - **Live Preview:** Pratinjau komponen UI secara instan saat mengganti warna/tema.
  - **Persistensi Lokal:** Pengaturan tema tersimpan otomatis di perangkat menggunakan `shared_preferences`.

- 🔍 **Real-Time Search & Priority Filter:**
  - Pencarian instan berdasarkan judul, deskripsi, nama assignee, maupun label task.
  - Filter cepat multi-kategori berdasarkan prioritas task (*Semua, Urgent, High, Medium, Low*).
  - Tombol reset filter cepat dengan counter statistik task selesai.

- ⚡ **Animated Splash Screen & Custom App Icon:**
  - Animasi pembuka elegan dengan scale & fade transition.
  - Konfigurasi icon aplikasi native multi-platform via `flutter_launcher_icons`.

---

## 🏗️ Struktur Proyek

```
lib/
├── main.dart                       # Entry point aplikasi & MultiProvider setup
├── data/
│   └── mock_data.dart              # Mock data awal (Default columns & Jira sample tasks)
├── models/
│   ├── task_priority.dart          # Enum prioritas, warna & icon
│   ├── subtask_model.dart          # Data model subtask (copyWith, JSON serialization)
│   ├── board_column.dart           # Data model kolom Kanban
│   └── task_model.dart             # Data model task lengkap
├── providers/
│   ├── kanban_board_provider.dart  # Business logic & state management Kanban
│   └── theme_provider.dart         # State management tema & persistensi SharedPreferences
├── theme/
│   └── app_theme.dart              # ColorScheme dinamis, lightTheme & darkTheme
├── widgets/
│   ├── board_column_widget.dart    # Komponen kolom board & drop target
│   ├── task_card_widget.dart       # Komponen kartu task Jira-style
│   ├── search_filter_bar.dart      # Komponen pencarian real-time & chip filter
│   ├── task_detail_modal.dart      # Bottom sheet modal detail & edit task
│   ├── create_task_dialog.dart     # Form modal pembuatan task baru
│   └── column_dialog.dart          # Form modal tambah/edit kolom board
└── views/
    ├── splash_screen_view.dart     # Splash screen beranimasi
    ├── kanban_board_view.dart      # Main screen Kanban Board
    └── settings_screen.dart        # Screen & Modal pengaturan tema
```

---

## 📦 Dependencies

| Package | Versi | Deskripsi |
|---|---|---|
| [`provider`](https://pub.dev/packages/provider) | `^6.1.5` | State management reaktif untuk board & tema |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | `^2.5.6` | Penyimpanan preferensi tema pengguna |
| [`uuid`](https://pub.dev/packages/uuid) | `^4.6.0` | Generator ID unik untuk task dan subtask |
| [`intl`](https://pub.dev/packages/intl) | `^0.20.3` | Format tanggal & kalender due date |
| [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) | `^0.14.4` | Generator icon aplikasi native otomatis |

---

## 🚀 Panduan Menjalankan Aplikasi

### 1. Prasyarat
- Pastikan Flutter SDK sudah terpasang (versi `>=3.13.5`).
- Cek instalasi dengan:
  ```bash
  flutter doctor
  ```

### 2. Unduh Dependencies
```bash
flutter pub get
```

### 3. Generate App Icons (Opsional jika ingin rebuild icon)
```bash
dart run flutter_launcher_icons
```

### 4. Jalankan Tes & Analisis Kode
```bash
# Validasi linter (0 issues)
flutter analyze

# Jalankan smoke & widget test suite
flutter test
```

### 5. Jalankan Aplikasi
- **Web (Google Chrome):**
  ```bash
  flutter run -d chrome
  ```
- **macOS Native:**
  ```bash
  flutter run -d macos
  ```
- **Android / iOS Device / Emulator:**
  ```bash
  flutter run
  ```

---

## 🎨 Palet Warna Tema

Aplikasi mendukung 8 pilihan warna aksen utama yang dapat diubah secara langsung melalui menu **Settings (ikon palet di AppBar)**:

| Palet | Hex Code | Tampilan |
|---|---|---|
| **TunTask Blue** *(Default Jira)* | `#0052CC` | Jira Signature Blue |
| **Emerald Green** | `#00875A` | Success / Agile Green |
| **Royal Indigo** | `#3F51B5` | Deep Indigo Accent |
| **Deep Purple** | `#6554C0` | Modern Purple Accent |
| **Warm Orange** | `#FF8B00` | Energetic Warm Orange |
| **Crimson Red** | `#DE350B` | Bold Crimson |
| **Ocean Teal** | `#00B8D9` | Refreshing Teal |
| **Slate Navy** | `#4A6572` | Minimalist Slate Navy |

---

## 📄 Lisensi
Proyek ini dilisensikan di bawah lisensi private/internal untuk proyek **TunTask**.
