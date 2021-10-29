# homebrew-qemu-macguest

En example of usage:

```bash
brew tap shchuko/qemu-macguest
brew install shchuko/qemu-macguest/qemu
```

Provided packages:

- `shchuko/qemu-macguest/qemu` - **QEMU** with vmnet.framework and isa-applesmc patches
- `shchuko/qemu-macguest/ovmf-darwin` - Packed
  [**OvmfDarwinPkg**](https://github.com/shchuko/OvmfDarwinPkg)
- `libvirt` - modifies **libvirt** formula that provides custom "*.plist" for launchd (
  see [Libvirt notes](#libvirt-notes) below)

## Libvirt notes

Libvirt from `homebrew/core` is not supposed to run as root using brew services. We tried to do that
with another approach.

After `brew install shchuko/qemu-macguest/libvirt` you should NOT run `brew services start libvirt`.
Run its daemons using launchctl directly:

```bash
# Copy launchd.plist configs
sudo cp -fi "/usr/local/opt/libvirt/libvirtd.service.plist" "/Library/LaunchDaemons/"
sudo cp -fi "/usr/local/opt/libvirt/virtlogd.service.plist" "/Library/LaunchDaemons/"
# Launch 'libvirtd' and 'virtlogd' daemons
sudo launchctl load "/Library/LaunchDaemons/libvirtd.service.plist"
sudo launchctl load "/Library/LaunchDaemons/virtlogd.service.plist"
```

Before `brew remove libvirt`, run:

```bash
# Unload 'libvirtd' and 'virtlogd'
sudo launchctl uload "/Library/LaunchDaemons/libvirtd.service.plist"
sudo launchctl uload "/Library/LaunchDaemons/virtlogd.service.plist"

# Remove launchd.plist configs
sudo rm "/usr/local/opt/libvirt/libvirtd.service.plist" "/Library/LaunchDaemons/"
sudo rm "/usr/local/opt/libvirt/virtlogd.service.plist" "/Library/LaunchDaemons/"
```

After install, it may be required to remove some files manually. Check there paths:
```
/usr/local/var/cache/libvirt
/usr/local/var/lib/libvirt
/usr/local/var/log/libvirt
/usr/local/var/log/swtpm/libvirt
/usr/local/var/var/run/libvirt

/usr/local/etc/libvirt
```