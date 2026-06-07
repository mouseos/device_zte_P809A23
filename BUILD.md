# Building CyanogenMod 12.1 (Android 5.1.1) for ZTE ZTF32 (P809A23)

Fully reproducible build of a custom CM-12.1 ROM for the ZTE ZTF32 / P809A23
(Qualcomm MSM8909, Cortex-A7, Adreno 304, 512 MB RAM, 240x320 ST7789V-SPI panel).

This device shipped with Android 5.1.1, so the matching base is **CyanogenMod 12.1**
(LineageOS has no 5.1 branch). Builds on a modern host (Ubuntu 24.04) with the
toolchain workarounds below.

## 1. Host packages (sudo apt)
    sudo apt install gcc-multilib g++-multilib libc6-dev-i386 lib32z1-dev \
        lib32ncurses-dev gperf pngcrush xsltproc ccache schedtool gnupg lzop \
        imagemagick libxml2-utils libreadline-dev bc flex bison zip unzip

## 2. Toolchains the AOSP-5.1 build needs (NOT system defaults)
- **JDK 7** — CM-12.1 main.mk requires java 1.7 (1.8 miscompiles libcore/EnumMap).
  Portable Azul Zulu 7 works:
      https://cdn.azul.com/zulu/bin/zulu7.56.0.11-ca-jdk7.0.352-linux_x64.tar.gz
  (main.mk java check is patched to also accept the "openjdk" prefix string.)
- **python2** — 5.1 build scripts are py2. e.g. a conda env:
      conda create -y -n py27 python=2.7
- host gcc 4.6 + arm toolchains come with the CM manifest (prebuilts/gcc).

## 3. Source + trees
    repo init -u https://github.com/CyanogenMod/android.git -b cm-12.1 --depth=1
    repo sync -c --no-tags --no-clone-bundle -j8
    git clone https://github.com/mouseos/device_zte_P809A23 device/zte/P809A23
    git clone https://github.com/mouseos/kernel_zte_msm8909  kernel/zte/msm8909
    # device/qcom/common provides dtbToolCM:
    git clone -b cm-12.1 https://github.com/CyanogenMod/android_device_qcom_common device/qcom/common

## 4. Build env (each shell)
    export JAVA_HOME=/path/to/zulu7...; export PATH=/path/to/py27/bin:$JAVA_HOME/bin:$PATH
    export LC_ALL=C
    export LIBART_IMG_HOST_BASE_ADDRESS=0x60000000 LIBART_IMG_TARGET_BASE_ADDRESS=0x70000000
    export OUT_DIR=/tmp/zo      # IMPORTANT: short OUT_DIR; deep paths overflow ARG_MAX
                                # (libavcodec link "Argument list too long"). Symlink to real out.

## 5. Build
    source build/envsetup.sh
    lunch cm_P809A23-userdebug
    make -j8                    # full droid; or `make -j8 bootimage systemimage`
    # raw system for EDL:
    out/host/linux-x86/bin/simg2img $OUT_DIR/target/product/P809A23/system.img system_raw.img

## 6. Proprietary blobs
proprietary-files.txt (297 entries) was pulled from the device's stock /system via
adb (root). Re-pull with: device/zte/P809A23/extract-files.sh (adb, device rooted).
Blobs are delivered as PRODUCT_COPY_FILES (vendor/zte/P809A23) — qcom HALs are NOT
built from source on first bring-up to avoid source/blob collisions.

## 7. Flash (EDL)
    edl w boot   $OUT_DIR/target/product/P809A23/boot.img      # QCDT embedded via dtbToolCM
    edl w system system_raw.img                                # raw, not sparse
    edl reset

## 8. Build-system workarounds applied (CM-12.1 on a 2026 host)
- main.mk: accept java 1.7/1.8 + "openjdk" version string.
- export LIBART_IMG_*_BASE_ADDRESS (unset otherwise in art/build).
- short OUT_DIR (ARG_MAX on libavcodec link).
- kernel HOSTCFLAGS += -fcommon (scripts/dtc yylloc multiple-definition on gcc>=10).
- BoardConfig: TARGET_KERNEL_ARCH=arm, BOARD_DTBTOOL_ARGS=--force-v2.

## 9. Device specifics / fixes baked into this tree
- cm.mk inherits embedded.mk (core ramdisk: adbd/healthd/sepolicy).
- fstab.qcom uses /dev/block/platform/soc.0/by-name/* (the /dev/block/bootdevice
  symlink is NOT created by this kernel; by-name lives under platform/soc.0).
- kernel defconfig enables ANDROID_RAM_CONSOLE -> /proc/last_kmsg (panic survives
  reboot; region = DTS ram_console_reserve @0x8FF00000). Essential for debugging.
- androidboot.selinux=permissive while bringing up (tighten later).

## Debugging boot (Qualcomm crash dump / 900e)
On a kernel panic the device enters Qualcomm crashdump (USB 05c6:900e). Pull the
panic with: `edl memorydump` -> RAMCON.BIN is the ram_console region (the Linux
kernel log incl. the panic). The dload cookie is in volatile IMEM: a COLD power-off
(or forced EDL) is required to leave 900e (warm `edl reset` keeps it).
