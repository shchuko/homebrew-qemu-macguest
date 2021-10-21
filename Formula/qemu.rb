class Qemu < Formula
  desc "Emulator for x86 and PowerPC"
  homepage "https://www.qemu.org/"
  url "https://github.com/shchuko/qemu/releases/download/v6.1.0-vmnet-v3-oskdirect-v1/qemu-v6.1.0-vmnet-v3-oskdirect-v1.tar.gz"
  version "v6.1.0-vmnet-v3-oskdirect-v1"
  sha256 "b94192ddef6025e2baf074fb218180d1c82413bd684b1fafe7c334a7e18bbe0f"
  license "GPL-2.0-only"
  head "https://github.com/shchuko/qemu.git", branch: "master"

  depends_on "libtool" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build

  depends_on "glib"
  depends_on "gnutls"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libslirp"
  depends_on "libssh"
  depends_on "libusb"
  depends_on "lzo"
  depends_on "ncurses"
  depends_on "nettle"
  depends_on "pixman"
  depends_on "snappy"
  depends_on "vde"

  fails_with gcc: "5"

  # 820KB floppy disk image file of FreeDOS 1.2, used to test QEMU
  resource "test-image" do
    url "https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.2/FD12FLOPPY.zip"
    sha256 "81237c7b42dc0ffc8b32a2f5734e3480a3f9a470c50c14a9c4576a2561a35807"
  end

  def install
    ENV["LIBTOOL"] = "glibtool"

    args = %W[
      --prefix=#{prefix}
      --cc=#{ENV.cc}
      --host-cc=#{ENV.cc}
      --disable-bsd-user
      --disable-guest-agent
      --enable-curses
      --enable-libssh
      --enable-slirp=system
      --enable-vde
      --extra-cflags=-DNCURSES_WIDECHAR=1
      --disable-sdl
      --disable-gtk
    ]
    # Sharing Samba directories in QEMU requires the samba.org smbd which is
    # incompatible with the macOS-provided version. This will lead to
    # silent runtime failures, so we set it to a Homebrew path in order to
    # obtain sensible runtime errors. This will also be compatible with
    # Samba installations from external taps.
    args << "--smbd=#{HOMEBREW_PREFIX}/sbin/samba-dot-org-smbd"

    args << "--enable-cocoa" 
    
    # Build qemu-system-x86_64 only
    args << "--target-list=x86_64-softmmu"

    system "./configure", *args
    system "make", "V=1", "install"
  end

  test do
    expected = build.stable? ? version.to_s : "QEMU Project"
    assert_match expected, shell_output("#{bin}/qemu-system-x86_64 --version")
    resource("test-image").stage testpath
    assert_match "file format: raw", shell_output("#{bin}/qemu-img info FLOPPY.img")
  end
end

