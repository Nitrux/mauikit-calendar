#! /bin/bash

set -eu

### Update sources

mkdir -p /etc/apt/keyrings

curl -fsSL https://packagecloud.io/nitrux/mauikit/gpgkey | gpg --dearmor -o /etc/apt/keyrings/nitrux_mauikit-archive-keyring.gpg

cat <<EOF > /etc/apt/sources.list.d/nitrux-mauikit.list
deb [signed-by=/etc/apt/keyrings/nitrux_mauikit-archive-keyring.gpg] https://packagecloud.io/nitrux/mauikit/debian/ trixie main
EOF

apt -q update

### Install Package Build Dependencies #2

apt -qq -yy install --no-install-recommends \
	mauikit-git

### Download Source

git clone --depth 1 --branch $MAUIKIT_CALENDAR_BRANCH https://invent.kde.org/maui/mauikit-calendar.git

rm -rf mauikit-calendar/{LICENSE,README.md,licenses}

### Compile Source

mkdir -p build && cd build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu ../mauikit-calendar/

make -j"$(nproc)"

make install

### Run checkinstall and Build Debian Package

>> description-pak printf "%s\n" \
	'A free and modular front-end framework for developing user experiences.' \
	'' \
	'Calendar support components for Maui applications.' \
	'' \
	'Maui stands for Multi-Adaptable User Interface and allows ' \
	'any Maui app to run on various platforms + devices,' \
	'like Linux Desktop and Phones, Android, or Windows.' \
	'' \
	'This package contains the MauiKit calendar shared library, the MauiKit calendar QML module' \
	'and the MauiKit calendar development headers.' \
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=mauikit-calendar-git \
	--pkgversion=$PACKAGE_VERSION \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=libs \
	--pkgsource=mauikit-calendar \
	--pakdir=. \
	--maintainer=uri_herrera@nxos.org \
	--provides=mauikit-calendar-git \
	--requires="libc6,libkf6calendarcore6,libkf6configcore6,libkf6contacts6,libkf6coreaddons6,libkf6i18n6,libkf6kiocore6,libkf6widgetsaddons6,libkpim6akonadiagentbase6,libkpim6akonadicontactcore6,libkpim6akonadicontactwidgets6,libkpim6akonadicore6,libkpim6akonadimime6,libkpim6akonadiprivate6,libkpim6akonadiwidgets6,libkpim6akonadixml6,libkpim6calendarutils6,libkpim6identitymanagementcore6,libkpim6identitymanagementquick6,libkpim6identitymanagementwidgets6,libqt6core5compat6,libqt6core6t64,libqt6qml6,libqt6sql6,libqt6svg6,mauikit-git \(\>= 4.0.1\),qml6-module-org-kde-calendarcore,qml6-module-org-kde-contacts,qml6-module-org-kde-kidentitymanagement,qml6-module-org-kde-kirigami,qml6-module-qtquick-controls,qml6-module-qtquick-shapes" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
