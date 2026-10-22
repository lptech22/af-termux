#!/data/data/com.termux/files/usr/bin/bash
# AF Termux (ADB Fastboot Termux) — installer
# By lptech22

set -u

REPO="lptech22/af-termux"
REPO_RAW="https://raw.githubusercontent.com/$REPO/main"
BACKEND_RAW="https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
LOG="${TMPDIR:-$PREFIX/tmp}/af-install.log"

GREEN="\033[32m"; RED="\033[31m"; YELLOW="\033[33m"; CYAN="\033[36m"; RESET="\033[0m"

: > "$LOG"

spin() {
  local pid=$1 msg=$2 i=0
  local frames='|/-\'
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r${CYAN}[%s]${RESET} %s" "${frames:i++%4:1}" "$msg"
    sleep 0.15
  done
}

# step "Pesan" perintah...
step() {
  local msg=$1; shift
  "$@" >>"$LOG" 2>&1 &
  local pid=$!
  spin "$pid" "$msg"
  if wait "$pid"; then
    printf "\r${GREEN}[ OK ]${RESET} %s\n" "$msg"
  else
    printf "\r${RED}[GAGAL]${RESET} %s\n" "$msg"
    echo -e "${YELLOW}Lihat log: $LOG${RESET}"
    exit 1
  fi
}

echo -e "${CYAN}=== AF Termux (ADB Fastboot Termux) — by lptech22 ===${RESET}"

if [ ! -d "$PREFIX" ] || ! command -v pkg >/dev/null 2>&1; then
  echo -e "${RED}Installer ini hanya untuk Termux.${RESET}"
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

step "Memperbarui daftar paket"                         pkg update -y
step "Memasang dependensi (curl, termux-api, libusb)"   pkg install -y curl termux-api libusb
step "Memasang backend termux-adb"                      install_backend
step "Memeriksa backend"                                verify_backend
step "Memasang AF Termux"                               install_toolkit

VER=$(grep -m1 '^AF_VERSION=' "$PREFIX/bin/af" 2>/dev/null | cut -d'"' -f2)

echo
echo -e "${GREEN}Instalasi selesai${RESET} (AF Termux ${VER:-?})."
echo "Pastikan aplikasi Termux:API sudah terpasang di Android."
echo "Opsional: jalankan 'termux-setup-storage' agar hasil screenshot/rekaman tersimpan di penyimpanan bersama."
echo -e "Jalankan toolkit dengan: ${CYAN}af${RESET}"
