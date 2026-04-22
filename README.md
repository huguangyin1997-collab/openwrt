![OpenWrt logo](include/logo.png)

OpenWrt Project is a Linux operating system targeting embedded devices. Instead
of trying to create a single, static firmware, OpenWrt provides a fully
writable filesystem with package management. This frees you from the
application selection and configuration provided by the vendor and allows you
to customize the device through the use of packages to suit any application.
For developers, OpenWrt is the framework to build an application without having
to build a complete firmware around it; for users this means the ability for
full customization, to use the device in ways never envisioned.

Sunshine!

## Download

Built firmware images are available for many architectures and come with a
package selection to be used as WiFi home router. To quickly find a factory
image usable to migrate from a vendor stock firmware to OpenWrt, try the
*Firmware Selector*.

* [OpenWrt Firmware Selector](https://firmware-selector.openwrt.org/)

If your device is supported, please follow the **Info** link to see install
instructions or consult the support resources listed below.

## 

An advanced user may require additional or specific package. (Toolchain, SDK, ...) For everything else than simple firmware download, try the wiki download page:

* [OpenWrt Wiki Download](https://openwrt.org/downloads)

## Development

To build your own firmware you need a GNU/Linux, BSD or macOS system (case
sensitive filesystem required). Cygwin is unsupported because of the lack of a
case sensitive file system.

### Requirements

You need the following tools to compile OpenWrt, the package names vary between
distributions. A complete list with distribution specific packages is found in
the [Build System Setup](https://openwrt.org/docs/guide-developer/build-system/install-buildsystem)
documentation.

```
binutils bzip2 diff find flex gawk gcc-6+ getopt grep install libc-dev libz-dev
make4.1+ perl python3.7+ rsync subversion unzip which
```

### Quickstart

1. Run `./scripts/feeds update -a` to obtain all the latest package definitions
   defined in feeds.conf / feeds.conf.default

2. Run `./scripts/feeds install -a` to install symlinks for all obtained
   packages into package/feeds/

3. Run `make menuconfig` to select your preferred configuration for the
   toolchain, target system & firmware packages.

4. Run `make` to build your firmware. This will download all sources, build the
   cross-compile toolchain and then cross-compile the GNU/Linux kernel & all chosen
   applications for your target system.

### Related Repositories

The main repository uses multiple sub-repositories to manage packages of
different categories. All packages are installed via the OpenWrt package
manager called `opkg`. If you're looking to develop the web interface or port
packages to OpenWrt, please find the fitting repository below.

* [LuCI Web Interface](https://github.com/openwrt/luci): Modern and modular
  interface to control the device via a web browser.

* [OpenWrt Packages](https://github.com/openwrt/packages): Community repository
  of ported packages.

* [OpenWrt Routing](https://github.com/openwrt/routing): Packages specifically
  focused on (mesh) routing.

* [OpenWrt Video](https://github.com/openwrt/video): Packages specifically
  focused on display servers and clients (Xorg and Wayland).

## Support Information

For a list of supported devices see the [OpenWrt Hardware Database](https://openwrt.org/supported_devices)

### Documentation

* [Quick Start Guide](https://openwrt.org/docs/guide-quick-start/start)
* [User Guide](https://openwrt.org/docs/guide-user/start)
* [Developer Documentation](https://openwrt.org/docs/guide-developer/start)
* [Technical Reference](https://openwrt.org/docs/techref/start)

### Support Community

* [Forum](https://forum.openwrt.org): For usage, projects, discussions and hardware advise.
* [Support Chat](https://webchat.oftc.net/#openwrt): Channel `#openwrt` on **oftc.net**.

### Developer Community

* [Bug Reports](https://bugs.openwrt.org): Report bugs in OpenWrt
* [Dev Mailing List](https://lists.openwrt.org/mailman/listinfo/openwrt-devel): Send patches
* [Dev Chat](https://webchat.oftc.net/#openwrt-devel): Channel `#openwrt-devel` on **oftc.net**.

## License

OpenWrt is licensed under GPL-2.0

## 注意

1. **不要用 root 用户进行编译**
2. 国内用户编译前最好准备好梯子
3. 默认登陆IP 192.168.1.1 密码 password

## 编译命令

1. 首先装好 Linux 系统，推荐 Debian 或 Ubuntu LTS 22/24

2. 安装编译依赖

      ```bash
      sudo apt update -y
      sudo apt full-upgrade -y
      sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
      bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
      genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
      libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
      libreadline-dev libssl-dev libtool llvm lrzsz libnsl-dev ninja-build p7zip p7zip-full patch pkgconf \
      python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
      swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
      ```

3. 下载源代码，更新 feeds 并选择配置

      ```bash
      git clone xxxx(你选择的)
      cd openwrt

      快速入门
      unset LD_LIBRARY_PATH
      unset LIBRARY_PATH
      export LC_ALL=C
      ./scripts/feeds update -a
      ./scripts/feeds install -a
      make menuconfig
      
      多线程下载编译
      make download -j$(nproc)
      make V=s -j$(nproc)
      
      首次建议使用单线程编译
      make V=s -j1
      
      删除编译的保存
      make clean
      make distclean
      ```

4. 下载 dl 库，编译固件
     （-j 后面是线程数，第一次编译推荐用单线程）
   
      ```bash
      make download -j8
      make V=s -j1
      ```
5. 集成自己想要的固件

      ```
      cd openwrt
      ```
      5.1 Kucat主题
        
              ```
              git clone https://github.com/sirpdboy/luci-app-kucat-config.git package/luci-app-kucat-config
              git clone https://github.com/sirpdboy/luci-theme-kucat.git package/luci-theme-kucat
              移动到本地 kucat 文件夹中
              mv package/luci-app-kucat-config kucat/
              mv package/luci-theme-kucat kucat/
              删除git(可选)
              rm -rf kucat/luci-app-backstageplanning/.git
              rm -rf kucat/luci-app-kucat-config/.git
              修改feeds.conf.default文件 添加（/usr/src 填自己的本地路径）
              src-link kucat /usr/src/openwrt/kucat 
              更新安装
              rm -rf tmp/
              ./scripts/feeds update kucat
              ./scripts/feeds install -a -p kucat
              ```
      5.2 istore商店
        
             ```
             echo >> feeds.conf.default
             echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
             ./scripts/feeds update istore
             ./scripts/feeds install -d y -p istore luci-app-store
             ```
6.编译前准备

      ```
      彻底切断环境变量干扰 (最关键)，避免很多麻烦
      在当前终端执行以下命令，确保编译脚本不会去错误挂载不属于它的库：
      unset LD_LIBRARY_PATH
      unset LIBRARY_PATH
      export LC_ALL=C
      ```
7.解决环境问题

      ```
      检查并补全宿主机 musl 开发环境
      Ubuntu 24.04 对 musl 的支持有所变动。请安装这个包来补全宿主机的 fts 定义：
      sudo apt update
      sudo apt install -y musl-tools
      
      执行以下命令安装 uuid 的开发头文件和库
      sudo apt update
      sudo apt install uuid-dev
      ```
8.更改分区

      8.1.iStoreos 更改分区大小
            ```
            scripts/gen_image_generic.sh  
            将这行改成自己需要的大小
            USERDATASIZE="2048"
             ```
      8.2.LEDE与openwrt原版
            ```
            直接编译更改就可以
            make menuconfig
            ```
9.单独编译自己的开发的ipk包

      9.1.修改feeds.conf.default文件
            ```
            #src-link custom /usr/src/openwrt/custom-feed
            ```
      9.1编译命令
            ```
            rm -rf tmp/
            ./scripts/feeds update custom
            ./scripts/feeds install -a -p custom

            
            make package/feeds/custom/luci-app-custom/clean
            make package/feeds/custom/luci-app-custom/compile V=s
            ```
10.其它插件

      10.1 openclash
      
            ```
            https://github.com/vernesong/OpenClash.git
            ```
      10.2 passwall
      
            ```
            https://github.com/Openwrt-Passwall/openwrt-passwall.git
            ```
      10.3 passwall2
      
            ```
            https://github.com/Openwrt-Passwall/openwrt-passwall2.git
            ```
      10.4 SSR PLUS
      
            ```
            https://github.com/maxlicheng/luci-app-ssr-plus.git
            ```
11.鸣谢！

      特别感谢 **iStore/iStoreOS** 团队及所有 **OpenWrt** 相关的开源项目贡献者，排名不分先后。
