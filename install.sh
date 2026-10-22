#!/data/data/com.termux/files/usr/bin/bash
# AF Termux (ADB Fastboot Termux) — installer
# v1.1 — by lptech22
#
# Pemakaian:
#   curl -fsSL https://raw.githubusercontent.com/lptech22/af-termux/main/install.sh | bash
# Opsi:
#   --no-update     lewati 'pkg update' (instalasi lebih cepat)
#   --uninstall     hapus AF Termux
#
# Catatan pipa:
#   curl -fsSL URL/install.sh | bash -s -- --no-update

set -u

REPO="lptech22/af-termux"
REPO_RAW="https://raw.githubusercontent.com/$REPO/main"
BACKEND_RAW="https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
LOG="${TMPDIR:-$PREFIX/tmp}/af-install.log"

GREEN="\033[32m"; RED="\033[31m"; YELLOW="\033[33m"; CYAN="\033[36m"; BOLD="\033[1m"; RESET="\033[0m"

SKIP_UPDATE=0
case "${1:-}" in
  --no-update) SKIP_UPDATE=1 ;;
  --uninstall)
    rm -f "$PREFIX/bin/af" "$PREFIX/bin/adb-fb"
    echo "AF Termux dihapus (backend termux-adb/termux-fastboot tidak disentuh)."
    exit 0 ;;
  -h|--help)
    cat <<EOF
AF Termux installer — pasang 'af' (ADB & Fastboot toolkit untuk Termux)

Pemakaian:
  curl -fsSL $REPO_RAW/install.sh | bash

Opsi:
  --no-update     Lewati 'pkg update' (pakai cache paket lokal)
  --uninstall     Hapus AF Termux
  -h, --help      Bantuan ini
EOF
    exit 0 ;;
esac

mkdir -p "$(dirname "$LOG")"
: > "$LOG"

cleanup() { rm -f "$PREFIX/bin/af.new"; }
trap cleanup EXIT

spin() {
  local pid=$1 msg=$2 i=0
  local frames='|/-\'
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r${CYAN}[%s]${RESET} %s" "${frames:i++%4:1}" "$msg"
    sleep 0.15
  done
}

# step "Pesan" perintah...
# Mengembalikan status (tidak exit sendiri); pemanggil yang memutuskan.
step() {
  local msg=$1; shift
  "$@" >>"$LOG" 2>&1 &
  local pid=$!
  spin "$pid" "$msg"
  if wait "$pid"; then
    printf "\r${GREEN}[ OK ]${RESET} %s\n" "$msg"
    return 0
  fi
  printf "\r${RED}[GAGAL]${RESET} %s\n" "$msg"
  echo -e "${YELLOW}--- 15 baris terakhir log ---${RESET}"
  tail -n 15 "$LOG"
  echo -e "${YELLOW}Log lengkap: $LOG${RESET}"
  return 1
}

echo -e "${CYAN}${BOLD}=== AF Termux (ADB Fastboot Termux) — installer ===${RESET}"

if [ ! -d "$PREFIX" ] || ! command -v pkg >/dev/null 2>&1; then
  echo -e "${RED}Installer ini hanya untuk Termux.${RESET}"
  echo "Unduh Termux resmi: https://github.com/termux/termux-app/releases"
  exit 1
fi

install_backend() {
  set -o pipefail
  curl -fsSL "$BACKEND_RAW" | bash
}

verify_backend() {
  command -v termux-adb >/dev/null 2>&1 && command -v termux-fastboot >/dev/null 2>&1
}

install_toolkit() {
  local tmp="$PREFIX/bin/af.new"
  curl -fsSL "$REPO_RAW/af" -o "$tmp" \
    && bash -n "$tmp" \
    && chmod +x "$tmp" \
    && mv -f "$tmp" "$PREFIX/bin/af" \
    && ln -sf af "$PREFIX/bin/adb-fb"
}

if [ "$SKIP_UPDATE" -eq 1 ]; then
  echo -e "${YELLOW}[LEWAT]${RESET} pkg update dilewati (--no-update)"
else
  step "Memperbarui daftar paket" pkg update -y \
    || echo -e "${YELLOW}[LEWAT]${RESET} pkg update gagal (jaringan/mirror). Melanjutkan dengan cache lokal."
fi

step "Memasang dependensi (curl, termux-api, libusb)" pkg install -y curl termux-api libusb || exit 1
step "Memasang backend termux-adb (nohajc)"            install_backend || exit 1
step "Memeriksa backend (termux-adb + termux-fastboot)" verify_backend || exit 1
step "Memasang AF Termux"                              install_toolkit || exit 1

VER=$(grep -m1 '^AF_VERSION=' "$PREFIX/bin/af" 2>/dev/null | cut -d'"' -f2)
ADB_LINE=$(termux-adb version 2>/dev/null | head -n1)
FB_LINE=$(termux-fastboot version 2>/dev/null | head -n1)

echo
echo -e "${GREEN}${BOLD}Instalasi selesai${RESET} — AF Termux ${VER:-?}"
echo "Backend:"
echo "  ADB      : ${ADB_LINE:-termux-adb (versi tak terbaca)}"
echo "  Fastboot : ${FB_LINE:-termux-fastboot (versi tak terbaca)}"
echo
echo "Langkah selanjutnya:"
echo " 1. Pastikan aplikasi Termux:API terpasang di Android (wajib untuk akses USB)."
echo " 2. Opsional: jalankan 'termux-setup-storage' agar hasil screenshot/rekaman"
echo "    tersimpan di penyimpanan bersama."
echo -e " 3. Jalankan toolkit: ${CYAN}af${RESET}"
echo
echo -e "Perintah lain: ${CYAN}af --help${RESET} · ${CYAN}af update${RESET} · ${CYAN}af uninstall${RESET} · ${CYAN}af info${RESET}"
echo -e "Catatan: modul ${YELLOW}Advanced${RESET} (flash/sideload) memakai konfirmasi ganda; tidak ada erase partisi."
