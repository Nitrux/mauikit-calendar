#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt"
else
    APT_COMMAND="apt"
fi

BUILD_DEPS='
    appstream
    automake
    autotools-dev
    build-essential
    checkinstall
    cmake
    curl
    devscripts
    equivs
    extra-cmake-modules
    gettext
    git
    gnupg2
    libakonadi-dev
    libakonadi-dev-bin
    libakonadicalendar-dev
    libakonadicontact-dev
    libakonadimime-dev
    libakonadiserver-dev
    libkcalendarutils-dev
    libkf6config-dev
    libkf6contacts-dev
    libkf6coreaddons-dev
    libkf6i18n-dev
    libkf6kio-dev
    libkf6widgetsaddons-dev
    libkidentitymanagement-dev
    lintian
    qt6-5compat-dev
    qt6-base-dev
    qt6-declarative-dev
    qt6-declarative-private-dev
    qt6-svg-dev
'

$APT_COMMAND update -q
$APT_COMMAND install -qy --no-install-recommends $BUILD_DEPS
