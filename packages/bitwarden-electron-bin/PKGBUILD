# Download this repository's preprocessed system-Electron application archive.
# No upstream DEB extraction, ASAR processing, or application build is performed.
pkgname=bitwarden-electron-bin
pkgver=2026.9.1
pkgrel=1
pkgdesc='Bitwarden using system Electron (prebuilt application)'
arch=('x86_64')
url='https://github.com/fansion314/bitwarden'
license=('GPL-3.0-only')
depends=('electron' 'bash' 'glibc' 'libgcc' 'hicolor-icon-theme'
         'libnotify' 'org.freedesktop.secrets' 'libxtst' 'libxss' 'libnss_nis')
provides=("bitwarden=$pkgver" "bitwarden-electron=$pkgver")
conflicts=('bitwarden' 'bitwarden-bin' 'bitwarden-electron')
options=('!strip' '!debug')
# Independently pin the published input: pkgrel can change without rebuilding it.
_release='2026.9.1-1'
_archive='bitwarden-electron-2026.9.1-1-x86_64.pkg.tar.zst'
source=("https://github.com/fansion314/bitwarden/releases/download/v${_release}/${_archive}")
noextract=("$_archive")
sha256sums=('44bc0cb757a5b4ec2901608a2340b6ba8e13b1b14be8b0245ae811c2453dc023')

package() {
  # The release asset can also be installed directly with pacman -U.
  bsdtar -xf "$srcdir/$_archive" -C "$pkgdir" usr
}
