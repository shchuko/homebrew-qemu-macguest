class OvmfDarwin < Formula
  desc "OVMF clone that provides macOS guests support with no third-party bootloaders"
  homepage "https://github.com/shchuko/OvmfDarwinPkg"

  url "https://github.com/shchuko/OvmfDarwinPkg/releases/download/v1.0-edk2-stable202105/ovmf-darwin-X64-RELEASE-v1.0-edk2-stable202105.tar.gz"
  sha256 "04b77fa4dbde90d400f1f01e23a873031e8e6c06501d4e3bb8afc172114c5126"

  head "https://github.com/shchuko/OvmfDarwinPkg.git", branch: "master"

  def install
    mkdir_p share/"OVMF_DARWIN"
    (share/"OVMF_DARWIN").install Dir["*"]
    chmod 0444, Dir[share/"OVMF_DARWIN/*"]
  end
end
