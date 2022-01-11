sudo apt install jq curl wget git gcc cmake extra-cmake-modules \
qttools5-dev qttools5-dev-tools libsdl2-dev \
libxi-dev libxtst-dev libx11-dev itstool gettext -y
get_release() {
curl --silent "https://api.github.com/repos/$1/releases/latest" | jq -r '.tag_name' | sed s/v//g
}
validate_url(){
if command wget -q --spider "$1"; then
return 0
else
return 1
fi
}

validate_url "https://api.github.com/repos/AntiMicroX/antimicrox/releases/latest"
if [ "$?" == "1" ]; then
echo "Got a bad response from 'https://api.github.com/repos/AntiMicroX/antimicrox/releases/latest'"
exit 1
else
validate_url "https://github.com/AntiMicroX/antimicrox"
if [ "$?" == "1" ]; then
echo "Got a bad response from 'https://github.com/AntiMicroX/antimicrox'"
exit 1
fi
fi
webVer=$(get_release AntiMicroX/antimicrox)
if [ -d "antimicrox" ]; then
rm -rf antimicrox/
fi
git clone --branch ${webVer} https://github.com/AntiMicroX/antimicrox --depth 1
cd antimicrox
mkdir build && cd build
# Building
cmake ..
make -j$(nproc) || echo "Something bad happened during building!"
# deb creation
cd ..
mkdir antimicrox_${webVer}_armhf 
mkdir antimicrox_${webVer}_armhf/DEBIAN
mkdir -p antimicrox_${webVer}_armhf/usr/bin/
mkdir -p antimicrox_${webVer}_armhf/usr/share/applications
mkdir -p antimicrox_${webVer}_armhf/usr/share/icons
mkdir -p antimicrox_${webVer}_armhf/usr/share/
cp build/bin/antimicrox antimicrox_${webVer}_armhf/usr/bin/antimicrox
touch antimicrox_${webVer}_armhf/DEBIAN/control
echo "Package: antimicrox
Version: ${webVer}
Section: games
Priority: optional
Architecture: armhf
Depends: qtbase5-dev (>= 5.8), libsdl2-2.0-0 (>= 2.0.6), libc6
Maintainer: Crilum - contact on github
Description: Program used to map keyboard keys and mouse controls to a gamepad.
 AntiMicroX is a graphical program used to map gamepad buttons to keyboard, mouse, scripts and macros.
 .
 It is a new fork of discontinued AntiMicro." > antimicrox_${webVer}_armhf/DEBIAN/control
chmod 775 antimicrox_${webVer}_armhf/DEBIAN/control
touch antimicrox_${webVer}_armhf/DEBIAN/postinst
echo "#!/bin/bash
sudo chmod 775 /usr/bin/antimicrox
exit 0" > antimicrox_${webVer}_armhf/DEBIAN/postinst
chmod 775 antimicrox_${webVer}_armhf/DEBIAN/postinst
# Build it
dpkg-deb --build antimicrox_${webVer}_armhf
