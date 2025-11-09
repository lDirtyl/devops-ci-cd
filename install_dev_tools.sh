#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt update

APT_PACKAGES="docker.io docker-compose python3 python3-pip"

#apt packages
for prog in $APT_PACKAGES; do
    if dpkg -s "$prog" &> /dev/null; then
        echo "$prog is already installed."
    else
        echo "Installing $prog..."
        sudo apt install -y "$prog"
    fi
done

# Django
if ! python3 -m django --version &> /dev/null; then
    echo "Installing Django..."
    sudo apt install python3-venv -y
    python3 -m venv venv
    source venv/bin/activate
    pip3 install django
else
    echo "Django is already installed."
fi

echo "✅ Installing finished!"
echo ""

echo ""
echo "Display installed versions:"
docker --version
docker-compose --version
python3 --version
python3 -m django --version