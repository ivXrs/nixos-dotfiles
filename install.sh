#!/usr/bin/env bash
set -euo pipefail

readonly CACHE_SUBSTITUTER="https://cache.numtide.com"
readonly CACHE_KEY="niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="

usage() {
  cat <<'EOF'
uso: sudo ./install.sh [--disk /dev/disk/by-id/...] [host]

instala un host de este repositorio desde una iso live de nixos usando disko.
usa el repositorio donde está este script; no clona nada.
el host por defecto es roxas.

argumentos:
  host         nombre del host en nixosConfigurations (por defecto: roxas)
  --disk PATH  usa este disco y no muestra el menú; debe ser un disco completo
  -h, --help   muestra esta ayuda

si hosts/<host>/disko.nix contiene REPLACE-ME, el instalador muestra un menú
con los discos completos de /dev/disk/by-id y persiste el elegido en ese fichero.

aviso: el instalador borra el disco seleccionado o declarado en hosts/<host>/disko.nix.
EOF
}

error() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'aviso: %s\n' "$*" >&2
}

info() {
  printf '==> %s\n' "$*"
}

post_disko_error() {
  error "$* el disco ya fue preparado por disko; no vuelvas a ejecutar disko. corrige el problema y ejecuta nixos-install manualmente si procede"
}

tmp_dir=""
trap 'if [[ -n ${tmp_dir:-} && -d ${tmp_dir:-} ]]; then rm -rf -- "${tmp_dir:-}" || true; fi' EXIT

count_hardware_imports() {
  local file=$1
  local count=0
  local line
  local code
  while IFS= read -r line || [[ -n $line ]]; do
    code=${line%%#*}
    if [[ $code == *"./hardware.nix"* ]]; then
      count=$((count + 1))
    fi
  done < "$file"
  printf '%s\n' "$count"
}

count_import_openers() {
  local file=$1
  grep -cE '^[[:space:]]*imports[[:space:]]*=[[:space:]]*\[[[:space:]]*(#.*)?$' -- "$file" || true
}

extract_disko_device() {
  local file=$1
  local -a found
  mapfile -t found < <(
    sed -nE 's/^[[:space:]]*(disko\.devices\.disk\.[A-Za-z0-9_-]+\.)?device[[:space:]]*=[[:space:]]*"([^"]*)".*/\2/p' "$file"
  )
  if (( ${#found[@]} != 1 )); then
    error "se esperaba exactamente un atributo device en $file; encontrados: ${#found[@]}"
  fi
  printf '%s\n' "${found[0]}"
}

validate_hardware_file() {
  local file=$1
  if [[ ! -s $file ]]; then
    error "el fichero $file está vacío o no es legible"
  fi
  if grep -Eq '^[[:space:]]*(fileSystems|swapDevices)([[:space:]]*\.|[[:space:]]*=)' -- "$file"; then
    error "$file define fileSystems o swapDevices; disko ya gestiona esos ajustes. elimínalos o regenera el fichero"
  fi
}

check_hardware_import_feasible() {
  local count
  local openers
  count="$(count_hardware_imports "$default_file")"
  if (( count > 1 )); then
    error "$default_file importa ./hardware.nix más de una vez; corrígelo antes de instalar"
  fi
  if (( count == 0 )); then
    openers="$(count_import_openers "$default_file")"
    if (( openers != 1 )); then
      error "no se puede insertar ./hardware.nix de forma segura en $default_file: se esperaba una única lista 'imports = [' multilínea y se encontraron $openers"
    fi
  fi
}

check_mnt_free() {
  local targets
  if ! targets="$(findmnt -rn -o TARGET 2>/dev/null)"; then
    error "no se pudo comprobar si /mnt tiene montajes"
  fi
  if awk '$0 == "/mnt" || index($0, "/mnt/") == 1 { found = 1 } END { exit !found }' <<<"$targets"; then
    error "/mnt ya tiene montajes; desmóntalos antes de continuar. no se ha tocado el disco"
  fi
}

check_target_unmounted() {
  local mounted
  if ! mounted="$(lsblk -rno MOUNTPOINTS "$device" | awk 'NF')"; then
    error "no se pudo comprobar si el disco $device tiene montajes activos"
  fi
  if [[ -n $mounted ]]; then
    printf '%s\n' "$mounted" >&2
    error "el disco $device tiene montajes activos; desmóntalos antes de continuar. no se ha tocado el disco"
  fi
}

check_target_inactive() {
  local active
  if ! active="$(lsblk -rno TYPE "$device" 2>/dev/null)"; then
    error "no se pudo comprobar si el disco $device tiene dispositivos activos"
  fi
  active="$(printf '%s\n' "$active" | grep -E '^(crypt|lvm|raid[0-9]*|mpath|zfs_member|bcache)$' || true)"
  if [[ -n $active ]]; then
    printf '%s\n' "$active" >&2
    error "el disco $device tiene dispositivos activos (crypt/lvm/raid/mpath/zfs/bcache); desactívalos antes de continuar. no se ha tocado el disco"
  fi
}

make_tmp_dir() {
  if [[ -n ${tmp_dir:-} ]]; then
    return 0
  fi
  if ! tmp_dir="$(mktemp -d "$host_dir/.install.XXXXXX")"; then
    error "no se pudo crear un directorio temporal en $host_dir"
  fi
}

list_whole_disk_by_ids() {
  local link
  local target
  local dev_type
  local nullglob
  if shopt -q nullglob; then
    nullglob=1
  else
    nullglob=0
  fi
  shopt -s nullglob
  for link in /dev/disk/by-id/*; do
    [[ -L $link ]] || continue
    [[ ${link##*/} =~ -part[0-9]+$ ]] && continue
    target="$(readlink -f -- "$link" 2>/dev/null || true)"
    [[ -n $target && -b $target ]] || continue
    dev_type="$(lsblk -dno TYPE -- "$target" 2>/dev/null || true)"
    [[ $dev_type == disk ]] || continue
    printf '%s\n' "$link"
  done
  (( nullglob )) || shopt -u nullglob
}

resolve_disk_arg() {
  local arg=$1
  local target
  local link
  local -a byids
  if [[ -z $arg ]]; then
    error "--disk requiere una ruta"
  fi
  if [[ $arg != /* ]]; then
    error "--disk debe ser una ruta absoluta: '$arg'"
  fi
  if [[ ! -e $arg ]]; then
    error "--disk no existe: '$arg'"
  fi
  if [[ ! -b $arg ]]; then
    error "--disk no es un block device: '$arg'"
  fi
  if [[ $(lsblk -dno TYPE -- "$arg" 2>/dev/null || true) != disk ]]; then
    error "--disk no apunta a un disco completo: '$arg'"
  fi
  if [[ $arg == /dev/disk/by-id/* && -L $arg ]]; then
    device="$arg"
    return 0
  fi
  target="$(readlink -f -- "$arg")" || error "no se pudo resolver --disk '$arg'"
  mapfile -t byids < <(list_whole_disk_by_ids)
  for link in "${byids[@]}"; do
    if [[ $(readlink -f -- "$link" 2>/dev/null || true) == "$target" ]]; then
      device="$link"
      return 0
    fi
  done
  error "no se encontró un by-id para --disk '$arg'; pasa /dev/disk/by-id/..."
}

select_disko_device() {
  local -a byids
  local link
  local target
  local size
  local model
  local serial
  local removable
  local read_only
  local mounts
  local active
  local choice
  local i
  if command -v udevadm >/dev/null 2>&1; then
    udevadm settle --timeout=30 >/dev/null 2>&1 || true
  fi
  mapfile -t byids < <(list_whole_disk_by_ids)
  if (( ${#byids[@]} == 0 )); then
    error "no se encontró ningún by-id de disco completo en /dev/disk/by-id; conecta el disco o usa --disk /dev/disk/by-id/..."
  fi
  printf '\n'
  info "discos detectados:"
  if ! lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,MOUNTPOINTS; then
    error "no se pudo ejecutar lsblk"
  fi
  printf '\n'
  info "by-id de discos completos (varias entradas pueden apuntar al mismo disco):"
  for i in "${!byids[@]}"; do
    link=${byids[$i]}
    target="$(readlink -f -- "$link")"
    size="$(lsblk -dno SIZE -- "$target" 2>/dev/null || true)"
    model="$(lsblk -dno MODEL -- "$target" 2>/dev/null | sed 's/[[:space:]]*$//' || true)"
    serial="$(lsblk -dno SERIAL -- "$target" 2>/dev/null | sed 's/[[:space:]]*$//' || true)"
    removable="$(lsblk -dno RM -- "$target" 2>/dev/null || true)"
    read_only="$(lsblk -dno RO -- "$target" 2>/dev/null || true)"
    mounts="$(lsblk -rno MOUNTPOINTS -- "$target" 2>/dev/null | awk 'NF' | paste -sd, - || true)"
    active="$(lsblk -rno TYPE -- "$target" 2>/dev/null | grep -E '^(crypt|lvm|raid[0-9]*|mpath|zfs_member|bcache)$' | paste -sd, - || true)"
    printf '  %d) %s -> %s | %s | %s | %s | rm=%s ro=%s' \
      "$((i + 1))" "$link" "$target" "${size:--}" "${model:--}" "${serial:--}" "${removable:--}" "${read_only:--}"
    if [[ -n $mounts ]]; then
      printf ' | montajes=%s' "$mounts"
    fi
    if [[ -n $active ]]; then
      printf ' | activo=%s' "$active"
    fi
    printf '\n'
  done
  while true; do
    if ! read -r -p "selecciona el by-id del disco [1-${#byids[@]}] (q para salir): " choice; then
      error "no se pudo leer la selección; instalación cancelada"
    fi
    if [[ $choice == q || $choice == Q ]]; then
      error "instalación cancelada por el usuario"
    fi
    if [[ ! $choice =~ ^[0-9]+$ ]]; then
      warn "selección inválida: '$choice'"
      continue
    fi
    if (( choice < 1 || choice > ${#byids[@]} )); then
      warn "número fuera de rango: $choice"
      continue
    fi
    device="${byids[$((choice - 1))]}"
    break
  done
  if [[ ! -L $device ]]; then
    error "el by-id seleccionado no es un enlace simbólico: $device"
  fi
  if [[ ! -b $device ]]; then
    error "el by-id seleccionado no apunta a un block device: $device"
  fi
  if [[ $(lsblk -dno TYPE -- "$device" 2>/dev/null || true) != disk ]]; then
    error "el by-id seleccionado no apunta a un disco completo: $device"
  fi
  info "disco seleccionado: $device"
}

persist_disko_device() {
  local file=$1
  local selected=$2
  local current
  local tmp_disko
  local persisted
  current="$(extract_disko_device "$file")"
  if [[ $current == "$selected" ]]; then
    return 0
  fi
  make_tmp_dir
  tmp_disko="$tmp_dir/disko.nix"
  if ! awk -v dev="$selected" '
    /^[[:space:]]*(disko\.devices\.disk\.[A-Za-z0-9_-]+\.)?device[[:space:]]*=[[:space:]]*"[^"]*"/ {
      sub(/"[^"]*"/, "\"" dev "\"")
      replaced++
    }
    { print }
    END { if (replaced != 1) exit 42 }
  ' "$file" > "$tmp_disko"; then
    error "no se pudo actualizar el device en $file; el original no se ha modificado y no se ha tocado el disco"
  fi
  persisted="$(extract_disko_device "$tmp_disko")"
  if [[ $persisted != "$selected" ]]; then
    error "la actualización de $file no contiene el by-id seleccionado; el original no se ha modificado y no se ha tocado el disco"
  fi
  if ! nix --extra-experimental-features "nix-command flakes" eval --file "$tmp_disko" >/dev/null; then
    error "el $file modificado no es un fichero nix válido; el original no se ha modificado y no se ha tocado el disco"
  fi
  if command -v alejandra >/dev/null 2>&1; then
    if ! alejandra --quiet "$tmp_disko"; then
      error "alejandra falló al formatear $tmp_disko; el original no se ha modificado y no se ha tocado el disco"
    fi
    persisted="$(extract_disko_device "$tmp_disko")"
    if [[ $persisted != "$selected" ]]; then
      error "el $file modificado no conserva el by-id seleccionado; el original no se ha modificado y no se ha tocado el disco"
    fi
    if ! nix --extra-experimental-features "nix-command flakes" eval --file "$tmp_disko" >/dev/null; then
      error "el $file modificado no es válido después de alejandra; el original no se ha modificado y no se ha tocado el disco"
    fi
  fi
  chmod --reference="$file" "$tmp_disko" 2>/dev/null || true
  chown --reference="$file" "$tmp_disko" 2>/dev/null || true
  if ! mv -- "$tmp_disko" "$file"; then
    error "no se pudo reemplazar $file con el fichero modificado; el original no se ha modificado y no se ha tocado el disco"
  fi
  info "actualizado $file con el by-id $selected"
}

ensure_hardware_import() {
  local count
  local openers
  local tmp_default

  count="$(count_hardware_imports "$default_file")"
  if (( count == 1 )); then
    info "hardware.nix ya está importado exactamente una vez en default.nix"
    return 0
  fi
  if (( count > 1 )); then
    post_disko_error "$default_file importa ./hardware.nix más de una vez."
  fi

  openers="$(count_import_openers "$default_file")"
  if (( openers != 1 )); then
    post_disko_error "no se puede insertar ./hardware.nix de forma segura en $default_file: se esperaba una única lista 'imports = [' multilínea y se encontraron $openers."
  fi

  make_tmp_dir
  tmp_default="$tmp_dir/default.nix"
  awk '
    /^[[:space:]]*imports[[:space:]]*=[[:space:]]*\[[[:space:]]*(#.*)?$/ {
      print
      print "    ./hardware.nix"
      next
    }
    { print }
  ' "$default_file" > "$tmp_default"

  count="$(count_hardware_imports "$tmp_default")"
  if (( count != 1 )); then
    post_disko_error "la inserción de ./hardware.nix no dejó exactamente un import; el original no se ha modificado."
  fi
  if ! nix --extra-experimental-features "nix-command flakes" eval --file "$tmp_default" >/dev/null; then
    post_disko_error "el default.nix modificado no es un fichero nix válido; el original no se ha modificado."
  fi

  if command -v alejandra >/dev/null 2>&1; then
    if ! alejandra --quiet "$tmp_default"; then
      post_disko_error "alejandra falló al formatear $tmp_default; el original no se ha modificado."
    fi
    if ! nix --extra-experimental-features "nix-command flakes" eval --file "$tmp_default" >/dev/null; then
      post_disko_error "el default.nix modificado no es válido después de alejandra; el original no se ha modificado."
    fi
    count="$(count_hardware_imports "$tmp_default")"
    if (( count != 1 )); then
      post_disko_error "el default.nix modificado no conserva exactamente un import de ./hardware.nix; el original no se ha modificado."
    fi
  fi

  chmod --reference="$default_file" "$tmp_default" 2>/dev/null || true
  chown --reference="$default_file" "$tmp_default" 2>/dev/null || true
  if ! mv -- "$tmp_default" "$default_file"; then
    post_disko_error "no se pudo reemplazar $default_file con el fichero modificado; el original no se ha modificado."
  fi
  info "importado ./hardware.nix en $default_file"
}

host=""
disk_arg=""
disk_arg_set=0

while (( $# > 0 )); do
  case $1 in
    -h | --help)
      usage
      exit 0
      ;;
    --disk)
      if (( $# < 2 )); then
        printf 'error: --disk requiere una ruta\n' >&2
        usage >&2
        exit 2
      fi
      disk_arg="$2"
      disk_arg_set=1
      shift 2
      ;;
    --disk=*)
      disk_arg="${1#*=}"
      disk_arg_set=1
      shift
      ;;
    -*)
      printf 'error: argumento desconocido: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -n $host ]]; then
        printf 'error: argumentos sobrantes: %s\n' "$*" >&2
        usage >&2
        exit 2
      fi
      host="$1"
      shift
      ;;
  esac
done

host="${host:-roxas}"

if [[ ! $host =~ ^[A-Za-z_][A-Za-z0-9_-]*$ ]]; then
  error "nombre de host inválido: '$host'"
fi

if ! script_path="$(readlink -f -- "${BASH_SOURCE[0]}")"; then
  error "no se pudo resolver la ruta del script"
fi
repo_root="$(dirname -- "$script_path")"
if ! cd -- "$repo_root"; then
  error "no se pudo entrar en la raíz del repo: $repo_root"
fi

info "host: $host"
info "repo: $repo_root"

if (( EUID != 0 )); then
  error "ejecuta este script como root: sudo ./install.sh [--disk /dev/disk/by-id/...] [host]"
fi

kernel="$(uname -s)"
arch="$(uname -m)"
if [[ $kernel != Linux ]]; then
  error "este instalador solo funciona en linux"
fi
if [[ $arch != x86_64 ]]; then
  error "este instalador solo funciona en x86_64; arquitectura detectada: $arch"
fi
if [[ ! -d /sys/firmware/efi ]]; then
  error "el sistema no ha arrancado en modo uefi (falta /sys/firmware/efi)"
fi
if [[ ! -t 0 ]]; then
  error "se requiere una terminal interactiva para confirmar y para disko/nixos-install"
fi

for cmd in nix nixos-install nixos-generate-config; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error "falta el comando '$cmd'; ejecuta este script desde una iso live de nixos"
  fi
done

if ! nix --extra-experimental-features "nix-command flakes" flake --help >/dev/null 2>&1; then
  error "nix no tiene soporte de flakes; usa una iso live de nixos con flakes habilitadas"
fi

if features="$(nix --extra-experimental-features "nix-command flakes" config show experimental-features 2>/dev/null)"; then
  if [[ $features != *flakes* || $features != *nix-command* ]]; then
    error "nix no tiene 'nix-command' y 'flakes' habilitadas en su configuración; nixos-install --flake fallaría"
  fi
fi

flake_file="$repo_root/flake.nix"
host_dir="$repo_root/hosts/$host"
disko_file="$host_dir/disko.nix"
default_file="$host_dir/default.nix"
hardware_file="$host_dir/hardware.nix"

if [[ ! -f $flake_file ]]; then
  error "no existe $flake_file"
fi
if [[ ! -d $host_dir ]]; then
  error "no existe el directorio del host: $host_dir"
fi
if [[ ! -f $disko_file ]]; then
  error "no existe $disko_file"
fi
if [[ ! -f $default_file ]]; then
  error "no existe $default_file"
fi
if [[ ! -d /mnt ]]; then
  error "no existe /mnt; ejecuta este script desde una iso live de nixos"
fi

info "comprobando que el host '$host' existe en el flake..."
if ! nix --extra-experimental-features "nix-command flakes" eval --json --apply 'x: true' "path:$repo_root#nixosConfigurations.$host" >/dev/null; then
  error "no se pudo evaluar el host '$host' en el flake; comprueba que existe en nixosConfigurations y que el flake evalúa"
fi

info "extrayendo el disco de $disko_file..."
device="$(extract_disko_device "$disko_file")"
original_device="$device"
if (( disk_arg_set )); then
  if [[ -z $disk_arg ]]; then
    error "--disk no puede estar vacío"
  fi
  resolve_disk_arg "$disk_arg"
elif [[ $device == *REPLACE-ME* ]]; then
  select_disko_device
elif [[ -z $device ]]; then
  error "el atributo device de $disko_file está vacío"
fi
if [[ -z $device ]]; then
  error "no se ha seleccionado ningún disco"
fi
if [[ $device == *REPLACE-ME* ]]; then
  error "no se ha seleccionado un disco real; el atributo device de $disko_file sigue conteniendo REPLACE-ME"
fi
if [[ $device != /* ]]; then
  error "el dispositivo '$device' no es una ruta absoluta"
fi
if [[ ! -b $device ]]; then
  error "el dispositivo '$device' no existe o no es un block device"
fi
if [[ $(lsblk -dno TYPE -- "$device" 2>/dev/null || true) != disk ]]; then
  error "el dispositivo '$device' no es un disco completo; disko necesita el disco entero"
fi

check_mnt_free
check_target_unmounted
check_target_inactive

if [[ -e $hardware_file && ! -f $hardware_file ]]; then
  error "$hardware_file existe pero no es un fichero regular"
fi
if [[ -f $hardware_file ]]; then
  validate_hardware_file "$hardware_file"
fi
check_hardware_import_feasible

needs_hardware=0
needs_import=0
if [[ ! -e $hardware_file ]]; then
  needs_hardware=1
fi
import_count="$(count_hardware_imports "$default_file")"
if (( import_count == 0 )); then
  needs_import=1
fi
if (( needs_hardware == 1 || needs_import == 1 )); then
  if [[ ! -w $host_dir ]]; then
    error "el directorio $host_dir no es escribible; el instalador necesita generar hardware.nix o editar default.nix"
  fi
fi
if [[ $device != "$original_device" && ! -w $host_dir ]]; then
  error "el directorio $host_dir no es escribible; el instalador necesita actualizar $disko_file"
fi

info "resolviendo disko..."
disko_ref="nixpkgs#disko"
if ! nix --extra-experimental-features "nix-command flakes" eval --raw "nixpkgs#disko.outPath" >/dev/null 2>&1; then
  warn "nixpkgs#disko no está disponible; se usará github:nix-community/disko (no fijado por flake.lock)"
  disko_ref="github:nix-community/disko"
  if ! nix --extra-experimental-features "nix-command flakes" eval --raw "github:nix-community/disko#default.outPath" >/dev/null 2>&1; then
    error "no se pudo resolver disko desde nixpkgs ni desde github:nix-community/disko; no se ha tocado el disco"
  fi
fi

printf '\n'
info "disco objetivo: $device"
if ! lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,MOUNTPOINTS "$device"; then
  error "no se pudo mostrar información del disco $device"
fi
printf '\n'
if [[ $device != "$original_device" ]]; then
  warn "se actualizará $disko_file con el by-id seleccionado: $device"
fi
warn "se borrará el disco $device y todas sus particiones; los datos se perderán."
warn "se instalará el host '$host' con disko en modo destructivo."
if grep -Eq 'type[[:space:]]*=[[:space:]]*"luks"' -- "$disko_file"; then
  warn "disko pedirá la passphrase de luks de forma interactiva."
fi
printf '\n'
if ! read -r -p "escribe exactamente 'INSTALL $host' para continuar: " confirmation; then
  error "no se pudo leer la confirmación; instalación cancelada y disco sin tocar"
fi
if [[ $confirmation != "INSTALL $host" ]]; then
  error "confirmación incorrecta; instalación cancelada y disco sin tocar"
fi

check_mnt_free
check_target_unmounted
check_target_inactive
if [[ ! -b $device ]]; then
  error "el dispositivo '$device' ya no está disponible; no se ha tocado el disco"
fi
if [[ $(lsblk -dno TYPE -- "$device" 2>/dev/null || true) != disk ]]; then
  error "el dispositivo '$device' ya no es un disco completo; no se ha tocado el disco"
fi
if [[ $device != "$original_device" ]]; then
  info "actualizando $disko_file con el by-id seleccionado..."
  persist_disko_device "$disko_file" "$device"
  persisted_device="$(extract_disko_device "$disko_file")"
  if [[ $persisted_device != "$device" ]]; then
    error "no se pudo verificar el by-id persistido en $disko_file; no se ha tocado el disco"
  fi
fi

info "ejecutando disko en modo destructivo..."
if ! nix --extra-experimental-features "nix-command flakes" run "$disko_ref" -- --mode disko "hosts/$host/disko.nix"; then
  error "disko falló; no se ejecutará nixos-install. revisa el estado del disco antes de reintentar"
fi

info "verificando los montajes en /mnt..."
if ! findmnt -rn -M /mnt >/dev/null; then
  post_disko_error "disko terminó pero /mnt no está montado."
fi
if ! findmnt -rn -M /mnt/boot >/dev/null; then
  post_disko_error "disko terminó pero /mnt/boot no está montado."
fi

if [[ ! -e $hardware_file ]]; then
  info "generando $hardware_file..."
  make_tmp_dir
  tmp_hw="$tmp_dir/hardware.nix"
  if ! nixos-generate-config --root /mnt --no-filesystems --show-hardware-config > "$tmp_hw"; then
    post_disko_error "nixos-generate-config falló."
  fi
  validate_hardware_file "$tmp_hw"
  if ! nix --extra-experimental-features "nix-command flakes" eval --file "$tmp_hw" >/dev/null; then
    post_disko_error "el hardware.nix generado no es un fichero nix válido."
  fi
  if command -v alejandra >/dev/null 2>&1; then
    if ! alejandra --quiet "$tmp_hw"; then
      post_disko_error "alejandra falló al formatear $tmp_hw; el fichero original no se ha modificado."
    fi
    if ! nix --extra-experimental-features "nix-command flakes" eval --file "$tmp_hw" >/dev/null; then
      post_disko_error "el hardware.nix generado no es válido después de alejandra."
    fi
  fi
  chmod --reference="$default_file" "$tmp_hw" 2>/dev/null || true
  chown --reference="$default_file" "$tmp_hw" 2>/dev/null || true
  if ! mv -- "$tmp_hw" "$hardware_file"; then
    post_disko_error "no se pudo mover el hardware.nix generado a $hardware_file."
  fi
  info "generado $hardware_file"
else
  info "hardware.nix ya existe; no se regenera"
  validate_hardware_file "$hardware_file"
fi

ensure_hardware_import

info "validando la evaluación del host '$host'..."
if ! drv_path="$(nix --extra-experimental-features "nix-command flakes" eval --raw "path:$repo_root#nixosConfigurations.$host.config.system.build.toplevel.drvPath")"; then
  post_disko_error "la evaluación del host '$host' falló."
fi
if [[ -z $drv_path ]]; then
  post_disko_error "la evaluación del host '$host' devolvió una derivación vacía."
fi
info "derivación del sistema: $drv_path"

info "instalando el host '$host' con nixos-install..."
if ! nixos-install --flake "path:$repo_root#$host" \
  --option extra-substituters "$CACHE_SUBSTITUTER" \
  --option extra-trusted-public-keys "$CACHE_KEY"; then
  printf 'error: nixos-install falló; no se volverá a ejecutar disko.\n' >&2
  printf 'el disco ya está preparado y /mnt sigue montado. para reintentar manualmente como root:\n' >&2
  printf '  nixos-install --flake %q --option extra-substituters %q --option extra-trusted-public-keys %q\n' \
    "path:$repo_root#$host" "$CACHE_SUBSTITUTER" "$CACHE_KEY" >&2
  exit 1
fi

info "instalación completada"
cat <<EOF

siguientes pasos:
1. retira la iso o el usb de instalación.
2. reinicia el equipo.
3. conserva hosts/$host/hardware.nix en el repo; no lo borres.
4. si el layout usa luks, la passphrase será necesaria al arrancar.
5. home-manager ya está integrado en la configuración del sistema; no ejecutes home-manager switch.

en el sistema instalado, desde la raíz del repo:
  sudo nixos-rebuild switch --flake path:.#$host \\
    --option extra-substituters "$CACHE_SUBSTITUTER" \\
    --option extra-trusted-public-keys "$CACHE_KEY"

si el repo está bajo git, hardware.nix puede estar sin trackear; path: lo incluye.
cuando lo commitees, puedes volver a usar --flake .#$host.
EOF

exit 0
