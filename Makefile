include $(TOPDIR)/rules.mk

PKG_NAME:=rtl8812bu-waihe
PKG_RELEASE=1

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=

PKG_SOURCE_URL:=https://github.com/fastoe/RTL8812BU.git
PKG_MIRROR_HASH:=skip

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2022-05-20
PKG_SOURCE_VERSION:=edd9e6f495fbebd1e8a620b3cf78fb67d97bcded

PKG_MAINTAINER:=Shoko
PKG_BUILD_PARALLEL:=1
#PKG_EXTMOD_SUBDIRS:=rtl8812bu-shoko

STAMP_CONFIGURED_DEPENDS := $(STAGING_DIR)/usr/include/mac80211-backport/backport/autoconf.h

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/rtl88x2bu
  SUBMENU:=Wireless Drivers
  TITLE:=Driver for Realtek 88x2 BU devices
  DEPENDS:=+kmod-cfg80211 +kmod-usb-core +@DRIVER_11N_SUPPORT +@DRIVER_11AC_SUPPORT
  FILES:=\
	$(PKG_BUILD_DIR)/rtl88x2bu.ko
  AUTOLOAD:=$(call AutoProbe,rtl88x2bu)
  PROVIDES:=kmod-rtl88x2bu
endef

NOSTDINC_FLAGS := \
	$(KERNEL_NOSTDINC_FLAGS) \
	-I$(PKG_BUILD_DIR) \
	-I$(PKG_BUILD_DIR)/include \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-include backport/autoconf.h \
	-include backport/backport.h

EXTRA_CFLAGS:= \
	-DRTW_SINGLE_WIPHY \
	-DRTW_USE_CFG80211_STA_EVENT \
	-DCONFIG_IOCTL_CFG80211 \
	-DCONFIG_CONCURRENT_MODE \
	-DBUILD_OPENWRT

EXTRA_KCONFIG:= \
	CONFIG_RTL8822BU=m \
	USER_MODULE_NAME=rtl88x2bu

NOSTDINC_FLAGS+=-DCONFIG_IOCTL_CFG80211 -DRTW_USE_CFG80211_STA_EVENT -DBUILD_OPENWRT

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
		M="$(PKG_BUILD_DIR)" \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
		USER_EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		$(EXTRA_KCONFIG) \
		modules
endef

$(eval $(call KernelPackage,rtl88x2bu))
