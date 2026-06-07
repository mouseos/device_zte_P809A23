# CyanogenMod 12.1 product for ZTE ZTF32 (P809A23)

# Inherit device configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/embedded.mk)
$(call inherit-product, device/zte/P809A23/device.mk)

# Inherit common CM stuff (full phone)
$(call inherit-product, vendor/cm/config/common_full_phone.mk)

# Low-RAM (512MB) tuning
$(call inherit-product-if-exists, frameworks/native/build/phone-xhdpi-512-dalvik-heap.mk)

PRODUCT_NAME := cm_P809A23
PRODUCT_DEVICE := P809A23
PRODUCT_BRAND := ZTE
PRODUCT_MODEL := ZTF32
PRODUCT_MANUFACTURER := ZTE

PRODUCT_GMS_CLIENTID_BASE := android-zte

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=ZTF32_jp_kdi \
    TARGET_DEVICE=P809A23 \
    BUILD_FINGERPRINT="ZTE/ZTF32_jp_kdi/P809A23:5.1.1/LMY47V/20210828.163906:user/test-keys" \
    PRIVATE_BUILD_DESC="ZTF32_jp_kdi-user 5.1.1 LMY47V 20210828.163906 test-keys"
