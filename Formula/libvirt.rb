class Libvirt < Formula
  desc "C virtualization API"
  homepage "https://github.com/shchuko/libvirt"
  url "https://github.com/shchuko/libvirt/releases/download/v7.8.0/libvirt-v7.8.0.tar.gz"
  sha256 "4af9338e64f817d0ce6f0b8a24a9e2f72ae7ff787a66afe54ea37fa9e448655d"
  license all_of: ["LGPL-2.1-or-later", "GPL-2.0-or-later"]
  head "https://github.com/shchuko/libvirt.git", branch: "master"

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "perl" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.9" => :build
  depends_on "rpcgen" => :build
  depends_on "gettext"
  depends_on "glib"
  depends_on "gnu-sed"
  depends_on "gnutls"
  depends_on "grep"
  depends_on "libgcrypt"
  depends_on "libiscsi"
  depends_on "libssh2"
  depends_on "yajl"

  uses_from_macos "curl"
  uses_from_macos "libxslt"

  def libvirtd_plist_name; "libvirtd.service" end
  def virtlogd_plist_name; "virtlogd.service" end

  def libvirtd_plist_path; prefix+(libvirtd_plist_name+'.plist') end
  def virtlogd_plist_path; prefix+(virtlogd_plist_name+'.plist') end

  def libvirt_enable_script_name; "libvirt-enable.sh" end
  def libvirt_disable_script_name; "libvirt-disable.sh" end

  def libvirt_enable_script_path; bin+libvirt_enable_script_name end
  def libvirt_disable_script_path; bin+libvirt_disable_script_name end

  def libvirtd_plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Disables</key>
        <false/>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{libvirtd_plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_sbin}/libvirtd</string>
          <string>-f</string>
          <string>#{etc}/libvirt/libvirtd.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
      </dict>
      </plist>
    EOS
  end

  def virtlogd_plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Disabled</key>
        <false/>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{virtlogd_plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_sbin}/virtlogd</string>
          <string>-f</string>
          <string>#{etc}/libvirt/virtlogd.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
      </dict>
      </plist>
    EOS
  end

  def libvirt_enable_script
    <<~EOS
      #!/bin/bash
      if [[ "$EUID" -ne 0 ]]
        then echo "Please run as root"
        exit
      fi
      set -x
      cp -fi #{libvirtd_plist_path} /Library/LaunchDaemons/
      cp -fi #{virtlogd_plist_path} /Library/LaunchDaemons/
      launchctl load /Library/LaunchDaemons/#{(libvirtd_plist_name+'.plist')}
      launchctl load /Library/LaunchDaemons/#{(virtlogd_plist_name+'.plist')}
    EOS
  end

  def libvirt_disable_script
    <<~EOS
      #!/bin/bash
      if [[ "$EUID" -ne 0 ]]
        then echo "Please run as root"
        exit
      fi
      set -x
      launchctl unload /Library/LaunchDaemons/#{(libvirtd_plist_name+'.plist')}
      launchctl unload /Library/LaunchDaemons/#{(virtlogd_plist_name+'.plist')}
      rm -i /Library/LaunchDaemons/#{(libvirtd_plist_name+'.plist')}
      rm -i /Library/LaunchDaemons/#{(virtlogd_plist_name+'.plist')}
    EOS
  end

  def install
    mkdir "build" do
      args = %W[
        --localstatedir=#{var}
        --mandir=#{man}
        --sysconfdir=#{etc}
        -Ddriver_esx=enabled
        -Ddriver_qemu=enabled
        -Dinit_script=none
        -Ddocs=disabled
      ]
      system "meson", *std_meson_args, *args, ".."
      system "meson", "compile"
      system "meson", "install"

      File.open(libvirtd_plist_path, 'w') do |f|
        f.puts libvirtd_plist
      end

      File.open(virtlogd_plist_path, 'w') do |f|
        f.puts virtlogd_plist
      end

      mkdir_p bin
      File.open(libvirt_enable_script_path, 'w') do |f|
        f.puts libvirt_enable_script
      end

      File.open(libvirt_disable_script_path, 'w') do |f|
        f.puts libvirt_disable_script
      end
    end
  end


  def caveats; <<~EOS
      Please IGNORE brew's message about running libvirt as its service.
      Instead you should run:
      * To enable libvirt services:
        sudo #{libvirt_enable_script_name}

      * To disable libvirt services:
        sudo #{libvirt_disable_script_name}
    EOS
  end

  test do
    if build.head?
      output = shell_output("#{bin}/virsh -V")
      assert_match "Compiled with support for:", output
    else
      output = shell_output("#{bin}/virsh -v")
      assert_match version.to_s, output
    end
  end
end
