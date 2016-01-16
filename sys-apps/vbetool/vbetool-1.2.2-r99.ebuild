# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

inherit eutils autotools flag-o-matic pax-utils

DESCRIPTION="Run real-mode video BIOS code to alter hardware state (i.e. reinitialize video card)"
HOMEPAGE="http://www.codon.org.uk/~mjg59/vbetool/"
SRC_URI="http://cgit.freedesktop.org/~airlied/${PN}/snapshot/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-libs/zlib
	sys-apps/pciutils
	>=dev-libs/libx86-1.1-r99"
RDEPEND="${DEPEND}"

pkg_setup() {
	append-flags -nopie
}

src_prepare() {
#	eaclocal # temp fix for #439614
	eautoreconf
	eautomake
}

src_configure() {
	econf --with-x86emu
}

src_compile() {
	default_src_compile

	pax-mark m vbetool
}
