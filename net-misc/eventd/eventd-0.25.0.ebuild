# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit linux-info meson systemd xdg-utils

DESCRIPTION="A small daemon to act on remote or local events"
HOMEPAGE="https://www.eventd.org/"
SRC_URI="https://www.eventd.org/download/eventd/${P}.tar.xz"

LICENSE="GPL-3+ LGPL-3+ MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug fbcon +introspection ipv6 libcanberra libnotify +notification
	pulseaudio purple speech systemd test upnp wayland webhook websocket +X zeroconf"

REQUIRED_USE="
	X? ( notification )
	fbcon? ( notification )
	notification? ( || ( X fbcon ) )
	test? ( websocket )
"

COMMON_DEPEND="
	>=dev-libs/glib-2.40:2
	sys-apps/util-linux
	x11-libs/libxkbcommon
	introspection? ( >=dev-libs/gobject-introspection-1.42 )
	libcanberra? ( media-libs/libcanberra )
	libnotify? ( x11-libs/gdk-pixbuf:2 )
	notification? (
		x11-libs/cairo
		x11-libs/pango
		x11-libs/gdk-pixbuf:2
		X? (
			x11-libs/cairo[xcb]
			x11-libs/libxcb:=
			x11-libs/xcb-util
			x11-libs/xcb-util-wm
		)
	)
	pulseaudio? (
		media-libs/libsndfile
		media-sound/pulseaudio
	)
	purple? ( net-im/pidgin )
	speech? ( >=app-accessibility/speech-dispatcher-0.8.7 )
	systemd? ( sys-apps/systemd:= )
	upnp? ( net-libs/gssdp:= )
	webhook? ( >=net-libs/libsoup-2.42:2.4 )
	websocket? ( >=net-libs/libsoup-2.50:2.4 )
	zeroconf? ( net-dns/avahi[dbus] )
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/meson-0.44.1
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	virtual/pkgconfig
	fbcon? ( virtual/os-headers )
"
RDEPEND="${COMMON_DEPEND}
	net-libs/glib-networking[ssl]
"

pkg_setup() {
	if use ipv6; then
		CONFIG_CHECK=$(usex test 'IPV6' '~IPV6')
		linux-info_pkg_setup
	fi
}

src_prepare() {
	default_src_prepare

	# Prevent access violations from introspection metadata generation.
	xdg_environment_reset
}

eventd_use_feature() {
	echo "-D${2:-${1}}=$(usex ${1} 'enabled' 'disabled')" || die
}

eventd_use_boolean() {
	echo "-D${2:-${1}}=$(usex ${1} 'true' 'false')" || die
}

src_configure() {
	local emesonargs=(
		-Dsystemduserunitdir="$(systemd_get_userunitdir)"
		-Dsystemdsystemunitdir="$(systemd_get_systemunitdir)"
		-Ddbussessionservicedir="${EPREFIX}/usr/share/dbus-1/services"
		$(eventd_use_feature websocket)
		$(eventd_use_feature zeroconf dns-sd)
		$(eventd_use_feature upnp ssdp)
		$(eventd_use_boolean ipv6)
		$(eventd_use_boolean systemd)
		$(eventd_use_boolean notification notification-daemon)
		#broken, depends on wayland-wall (defunct project?)
		#$(eventd_use_boolean wayland nd-wayland)
		$(eventd_use_boolean X nd-xcb)
		$(eventd_use_boolean fbcon nd-fbdev)
		$(eventd_use_boolean purple im)
		$(eventd_use_boolean pulseaudio sound)
		$(eventd_use_boolean speech tts)
		$(eventd_use_boolean webhook)
		$(eventd_use_boolean libnotify)
		$(eventd_use_boolean libcanberra)
		$(eventd_use_boolean introspection gobject-introspection)
		$(eventd_use_boolean debug debug-output)
	)
	meson_src_configure
}

src_test() {
	EVENTD_TESTS_TMP_DIR="${T}" meson_src_test
}

pkg_postinst() {
	if { use notification || use libnotify; } && ! has_version 'gnome-base/librsvg'; then
		elog
		elog "For SVG icons in notifications, please install 'gnome-base/librsvg'."
		elog
	fi
}
