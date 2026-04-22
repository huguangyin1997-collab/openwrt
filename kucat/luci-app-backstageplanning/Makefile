include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-backstageplanning
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Miku

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-backstageplanning
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Backstage Planning - LAN Settings
  PKGARCH:=all
  DEPENDS:=+luci-base
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) -r ./luasrc $(PKG_BUILD_DIR)/
	$(CP) -r ./root $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-backstageplanning/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/luasrc/controller/* $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/luasrc/view/* $(1)/usr/lib/lua/luci/view/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/root/usr/bin/backstageplanning $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/profile.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/root/etc/profile.d/backstageplanning.sh $(1)/etc/profile.d/backstageplanning.sh
endef

define Package/luci-app-backstageplanning/postinst
#!/bin/sh
if [ -z "$$IPKG_INSTROOT" ]; then
	chmod +x /usr/bin/backstageplanning
	# 可选：如果 /etc/shinit 存在且需要兼容极简环境，添加加载（有锁保护，不会重复）
	if [ -f /etc/shinit ]; then
		sed -i '/backstageplanning.sh/d' /etc/shinit
		echo ". /etc/profile.d/backstageplanning.sh" >> /etc/shinit
	fi
fi
exit 0
endef

define Package/luci-app-backstageplanning/prerm
#!/bin/sh
if [ -z "$$IPKG_INSTROOT" ]; then
	[ -f /etc/shinit ] && sed -i '/backstageplanning.sh/d' /etc/shinit
fi
exit 0
endef

$(eval $(call BuildPackage,luci-app-backstageplanning))