{
  description = "Nix devShell for low-level Linux projects";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default =
      
      (pkgs.buildFHSEnvBubblewrap {
        name = "kernel-dev-fhs";
        runScript = "bash";   # interactive shell inside the FHS env

        # all the tools you had before
        targetPkgs = p: with p; [
          # Compilers + tooling
          gcc musl gnumake binutils gdb pkg-config flex bison strace ltrace xtrace
          
          # kernel / low-level deps
          elfutils ncurses openssl zlib zstd bc cpio bzip2 pahole
          
          # ISO + FS tools
          syslinux cdrkit dosfstools mtools
          
          # emulators
          qemu qemu-utils OVMF swtpm
        ];

        extraOutputsToInstall = [ "dev" ];

        # Map syslinux files where the kernel script *hardcodes* its search
        # (/usr/{lib,lib64,share}/syslinux{,/modules/bios})
        extraMounts = [
          { source = "${pkgs.syslinux}/share/syslinux";    target = "/usr/share/syslinux"; }
          { source = "${pkgs.syslinux}/share/syslinux";    target = "/usr/lib/syslinux"; }
          { source = "${pkgs.syslinux}/share/syslinux";    target = "/usr/lib64/syslinux"; }
          { source = "${pkgs.syslinux}/share/syslinux";    target = "/usr/lib/syslinux/modules/bios"; }
          { source = "${pkgs.elfutils.dev}/include";       target = "/usr/include"; }        # provides gelf.h
          { source = "${pkgs.elfutils}/lib";               target = "/usr/lib"; }            # libelf.so
          { source = "${pkgs.elfutils.dev}/lib/pkgconfig"; target = "/usr/lib/pkgconfig"; }  # libelf.pc for pkg-config
        ];
      }).env;
  };
}

