{ config, lib, pkgs, ... }:

let
  cfg = config.programs.razerWindowsVm;
  udevRules = pkgs.writeTextFile {
    name = "razer-windows-vm-udev-rules";
    destination = "/lib/udev/rules.d/99-z-razer-windows-vm.rules";
    text = ''
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="1532", ATTR{idProduct}=="00a4", MODE="0666"
    '';
  };
  razerWindowsVm = pkgs.writeShellApplication {
    name = "razer-windows-vm";
    runtimeInputs = with pkgs; [
      cdrtools
      coreutils
      curl
      gawk
      gnugrep
      gnused
      quickemu
      usbutils
    ];
    text = ''
      vm_root="''${XDG_DATA_HOME:-$HOME/.local/share}/razer-windows-vm"
      vm_config="$vm_root/windows-11.conf"
      vm_dir="$vm_root/windows-11"
      windows_iso_name="Win11_25H2_English_x64.iso"
      windows_iso="$vm_dir/$windows_iso_name"
      windows_iso_download="$vm_root/$windows_iso_name"
      windows_iso_url="https://go.microsoft.com/fwlink/?linkid=2334167&clcid=0x409&culture=en-us&country=us"
      virtio_iso="$vm_dir/virtio-win.iso"
      virtio_iso_url="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"

      usage() {
        cat <<'EOF'
      Usage: razer-windows-vm <start|destroy>

        start    Download Windows 11 when needed, then launch the VM
        destroy  Stop the VM and delete its disk, ISOs, and all other state
      EOF
      }

      has_minimum_size() {
        local file="$1"
        local minimum_size="$2"
        [[ -f "$file" ]] && (( $(stat --format='%s' "$file") >= minimum_size ))
      }

      recover_incomplete_vm() {
        if [[ -f "$vm_config" ]] \
          && { ! has_minimum_size "$windows_iso" 4000000000 \
            || ! has_minimum_size "$virtio_iso" 500000000; }; then
          local disk_size=0
          if [[ -f "$vm_dir/disk.qcow2" ]]; then
            disk_size=$(stat --format='%s' "$vm_dir/disk.qcow2")
          fi
          if (( disk_size > 10485760 )); then
            echo "The existing VM has an incomplete installer but a non-empty Windows disk." >&2
            echo "Run 'razer-windows-vm destroy' before recreating it." >&2
            exit 1
          fi
          echo "Discarding the incomplete VM download from the previous attempt."
          rm -rf "$vm_root"
        fi

        if [[ ! -f "$vm_config" && -d "$vm_dir" ]]; then
          if has_minimum_size "$windows_iso" 4000000000; then
            mkdir -p "$vm_root"
            mv "$windows_iso" "$windows_iso_download"
          fi
          rm -rf "$vm_dir"
        fi
      }

      create_vm() {
        recover_incomplete_vm
        if [[ ! -f "$vm_config" ]]; then
          mkdir -p "$vm_root"
          echo "Downloading Microsoft's Windows 11 Enterprise evaluation ISO."
          echo "The download is approximately 7 GB and resumes if interrupted."
          curl \
            --continue-at - \
            --fail \
            --location \
            --output "$windows_iso_download" \
            --retry 3 \
            --retry-all-errors \
            "$windows_iso_url"
          if ! has_minimum_size "$windows_iso_download" 4000000000; then
            echo "The Windows ISO download is incomplete or invalid." >&2
            exit 1
          fi

          (
            cd "$vm_root"
            quickget --create-config windows-11 "$windows_iso_name" --unattended
          )

          # Quickget's browser user-agent is blocked by the VirtIO mirror's
          # bot protection, which it mistakes for a successful ISO download.
          rm -f "$virtio_iso"
          curl \
            --continue-at - \
            --fail \
            --location \
            --output "$virtio_iso" \
            --retry 3 \
            --retry-all-errors \
            "$virtio_iso_url"
          if ! has_minimum_size "$virtio_iso" 500000000; then
            echo "The VirtIO driver ISO download is incomplete or invalid." >&2
            exit 1
          fi

          # Evaluation media selects its only edition without a product key.
          sed -i \
            -e '/<ProductKey>W269N-WFGWX-YVC9B-4J6C9-T83GX<\/ProductKey>/d' \
            -e '/        <ProductKey>/,/        <\/ProductKey>/d' \
            "$vm_dir/unattended/autounattend.xml"
          mkisofs -quiet -J -o "$vm_dir/unattended.iso" "$vm_dir/unattended"
        fi

        if ! grep -q '^# Razer pairing overrides$' "$vm_config"; then
          cat >> "$vm_config" <<'EOF'

      # Razer pairing overrides
      disk_size="64G"
      tpm="on"
      secureboot="off"
      ram="8G"
      cpu_cores="4"
      usb_devices=("1532:00a4")
      EOF
        fi
      }

      require_accessible_dock() {
        local usb_node
        usb_node=$(lsusb -d 1532:00a4 | awk 'NR == 1 { sub(":", "", $4); print "/dev/bus/usb/" $2 "/" $4 }')
        if [[ -z "$usb_node" ]]; then
          echo "Razer Mouse Dock Pro 1532:00a4 is not connected." >&2
          exit 1
        fi
        if [[ ! -w "$usb_node" ]]; then
          echo "The Razer Mouse Dock Pro is not writable at $usb_node." >&2
          echo "Rebuild NixOS, then unplug and reconnect the dock before retrying." >&2
          exit 1
        fi
      }

      start_vm() {
        require_accessible_dock
        create_vm
        (
          cd "$vm_root"
          quickemu --vm windows-11.conf
        )
      }

      destroy_vm() {
        if [[ ! -d "$vm_root" ]]; then
          echo "No disposable Razer Windows VM exists."
          return
        fi

        read -r -p "Delete the disposable Windows VM and all downloaded data? [y/N] " reply
        case "$reply" in
          y | Y | yes | YES)
            ;;
          *)
            echo "Cancelled."
            return
            ;;
        esac

        if [[ -f "$vm_config" ]]; then
          (
            cd "$vm_root"
            quickemu --vm windows-11.conf --kill --delete-vm
          )
        fi
        rm -rf "$vm_root"
        echo "Deleted $vm_root"
      }

      case "''${1:-}" in
        start)
          start_vm
          ;;
        destroy)
          destroy_vm
          ;;
        help | --help | -h)
          usage
          ;;
        *)
          usage >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  options.programs.razerWindowsVm.enable =
    lib.mkEnableOption "a disposable Windows VM for Razer device pairing";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ razerWindowsVm ];

    # Quickemu passes the complete USB device through to QEMU. Limit access to
    # the Mouse Dock Pro. OpenRazer locks its group assignment, so this later
    # rule grants write access only on the dock's complete USB device node.
    services.udev.packages = [ udevRules ];
  };
}
