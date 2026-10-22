# AF Termux (ADB Fastboot Termux)

**By lptech22** · Versi 1.0.0

Toolkit untuk menggunakan Android sebagai alat ADB dan Fastboot melalui USB OTG, tanpa root.

## Download Termux

* [Termux — GitHub resmi](https://github.com/termux/termux-app/releases)
* [Termux:API — GitHub resmi](https://github.com/termux/termux-api/releases)

Pasang Termux dan Termux:API dari sumber yang sama dan kompatibel (misalnya keduanya dari GitHub), serta pastikan aplikasi Termux:API terpasang di Android agar fitur deteksi USB berfungsi dengan baik.

## Instalasi (satu perintah)

Buka Termux, lalu tempel dan jalankan:

```bash
pkg upgrade -y -o Dpkg::Options::="--force-confold" && curl -fsSL https://raw.githubusercontent.com/lptech22/af-termux/main/install.sh | bash
```

Perintah ini memperbarui paket (menjaga konfigurasi lama secara otomatis) lalu memasang AF Termux. Tunggu sampai selesai.

## Jalankan

```bash
af
```

Perintah lain:

```bash
af --version    # tampilkan versi
af --help       # bantuan
af update       # perbarui toolkit
af uninstall    # hapus toolkit
```

Perintah lama `adb-fb` tetap tersedia sebagai alias.

## Menu

1. **Perangkat** — cek ADB, cek Fastboot, info perangkat (ADB/Fastboot)
2. **File & Aplikasi** — salin file, install APK, screenshot, rekam layar
3. **Reboot** — System, Recovery, Bootloader, FastbootD, Sideload, Download mode, EDL (via ADB); System, Bootloader, Recovery, FastbootD (via Fastboot)
4. **Koneksi** — diagnosis USB, ADB nirkabel (pairing, connect, disconnect)
5. **Alat** — simpan logcat, backup kunci ADB, shell ADB
6. **Pengaturan** — bantuan, tentang/versi, perbarui, hapus toolkit

Hasil screenshot, rekaman, dan logcat disimpan di folder `AF` (di penyimpanan bersama jika Anda sudah menjalankan `termux-setup-storage`, jika tidak di `~/af-output`).

## Catatan

* ADB membutuhkan USB debugging dan persetujuan pada perangkat target.
* Fastboot membutuhkan perangkat target dalam mode bootloader Fastboot.
* Gunakan kabel data dan adapter OTG yang mendukung USB host.
* Android dapat meminta izin USB ketika perangkat disambungkan.
* Beberapa mode reboot (Download, EDL, FastbootD, Sideload) bergantung pada perangkat.
* Kompatibilitas bergantung pada perangkat, ROM, kabel, daya, dan izin USB.
* Toolkit tidak melakukan flash atau erase partisi.

## Troubleshooting

**`curl` error "CANNOT LINK EXECUTABLE ... SSL_set_quic_tls_early_data_enabled"**
Paket Termux tidak sinkron. Pilih mirror lalu perbarui semua paket:

```bash
termux-change-repo
apt update && apt full-upgrade -y
```

Setelah `curl --version` berjalan normal, ulangi perintah instalasi.

**Log installer:** `$TMPDIR/af-install.log`

## Kredit

* Toolkit dan dokumentasi: **lptech22**
* Backend ADB/Fastboot: [nohajc/termux-adb](https://github.com/nohajc/termux-adb)
* Termux: [termux/termux-app](https://github.com/termux/termux-app)
* Termux:API: [termux/termux-api](https://github.com/termux/termux-api)
