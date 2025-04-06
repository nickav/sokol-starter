if [[ "$OSTYPE" == "darwin"* ]]; then
    ./build_macos.sh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ./build_linux.sh
else
    echo "Error - Unsupported OS: $OSTYPE"
    exit 1
fi