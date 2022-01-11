sudo apt install jq curl wget git git gcc cmake extra-cmake-modules \
qttools5-dev qttools5-dev-tools libsdl2-dev \
libxi-dev libxtst-dev libx11-dev itstool gettext -y
get_release() {
curl --silent "https://api.github.com/repos/$1/releases/latest" | jq -r '.tag_name' | sed s/v//g
}
function validate_url(){
if command wget -q --spider "$1"; then
return 0
else
return 1
fi
}
echo "Checking URLs..."
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
echo "Done."
webVer=$(get_release AntiMicroX/antimicrox)
       
git clone --branch 3.2.1 https://github.com/AntiMicroX/antimicrox --depth 1
cd antimicrox
mkdir build && cd build
# Building
cmake ..
make -j$(nproc)
