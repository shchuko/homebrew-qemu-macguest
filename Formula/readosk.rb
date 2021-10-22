class Readosk < Formula
  desc "An utility to retrieve OSK key requred for QEMU-AppleSMC"
  homepage "https://github.com/shchuko/readosk"
  
  url "https://github.com/shchuko/readosk/archive/refs/tags/v0.0.1.tar.gz"
#   version "0.0.1"
  sha256 "171f7b288f591ea57862ea74c3c1ad82baf52fdc27764a579e342961df5f1c84"

  head "https://github.com/shchuko/readosk.git", branch: "master"
  
  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "readosk"
  end
end
