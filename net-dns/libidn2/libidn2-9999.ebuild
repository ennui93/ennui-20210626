# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools eutils multilib-minimal

DESCRIPTION="An implementation of the IDNA2008 specifications (RFCs 5890, 5891, 5892, 5893)"
HOMEPAGE="https://www.gnu.org/software/libidn/#libidn2 https://gitlab.com/jas/libidn2"

if [[ ${PV} == "9999" ]]; then
        inherit git-r3
        EGIT_REPO_URI="https://gitlab.com/libidn/libidn2.git"
else
	SRC_URI="
		mirror://gnu-alpha/libidn/${P}.tar.gz
	"
        S=${WORKDIR}/v${PV}
fi



LICENSE="GPL-2+ LGPL-3+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static-libs"

RDEPEND="
	dev-libs/libunistring[${MULTILIB_USEDEP}]
"
DEPEND="
	${RDEPEND}
	dev-lang/perl
	sys-apps/help2man
	dev-util/gengetopt
"

PATCHES=(
)

src_prepare() {
	default

	./bootstrap || die

	multilib_copy_sources
}

multilib_src_configure() {
	econf \
		$(use_enable static-libs static) \
		$(use_enable nls) \
		--disable-doc
}

multilib_src_install() {
	default

	prune_libtool_files
}
