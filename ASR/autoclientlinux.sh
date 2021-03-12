#!/bin/bash
<<COMMENTS
        This is demo code to setup the Azure site recovery client on linux and it will also select the correct linux distro since asr uses different client depending of the distro used, it was used by me so i can set up a test lab while doing tasks.
        It does expect the auto.ps1 was run on the Configuration sever as that script will create two smb shares used by this script to get the installer and the connection.passphrase
COMMENTS


read -p "Enter CS IP: " ipCs 
read -p "Enter windows username: " user
read  -s -p "Enter windows password: " pass

cd ~/Downloads
susspress=$(mkdir ASR)

cd ASR

susspress=$(mkdir ASRAgent)

susspress=$(sudo mount -o username=$user,password=$pass //$ipCs/ASRAgent ~/Downloads/ASR/ASRAgent)

susspress=$(mkdir ASRPass)

susspress=$(sudo mount -t cifs -o username=$user,password=$pass //$ipCs/ASRPass ~/Downloads/ASR/ASRPass)

if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    OS="Red Hat Enterprise Linux Server"
    VER="$(sudo cat /etc/redhat-release | cut -d' ' -f7)"
elif [ -f /etc/oracle-release ]; then
    OS="Oracle Linux Server"
    VER="$(sudo cat /etc/oracle-release | cut -d' ' -f5)"
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi


if [ $OS == "Ubuntu" ] && [ $VER == "16.04" ]; then
        find . -name "*UBUNTU-16.04-64_GA*" | xargs cp -t ~/Downloads/ASR/  
        rename=$(find . -name "*UBUNTU-16.04-64_GA*")
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz
        echo "Downloaded $OS $VER ASR Client"
elif [ $OS == "Ubuntu" ] && [ $VER == "14.04" ]; then
        find . -name "*UBUNTU-14.04-64_GA*" | xargs cp -t ~/Downloads/ASR/
        rename=find . -name "*UBUNTU-14.04-64_GA*"
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz
        echo "Downloaded $OS $VER ASR Client"
elif [ $OS == "SLES" ] && [ $VER =~ 12 ]; then
        find . -name "*SLES12-64_GA*" | xargs cp -t ~/Downloads/ASR/
        rename=$(find . -name "*SLES12-64_GA*") 
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz
        echo "Downloaded $OS $VER ASR Client"
elif [ $OS == "SLES" ] && [ [ $VER == "11.4" ]; then   
        find . -name "*SLES11-SP4-64_GA*" | xargs cp -t ~/Downloads/ASR/
        rename=$(find . -name "*SLES11-SP4-64_GA*")
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz
        echo "Downloaded $OS $VER ASR Client"
elif [ $OS == "SLES" ] && [ $VER == "11.3" ]; then   
        find . -name "*SLES11-SP3-64_GA*" | xargs cp -t ~/Downloads/ASR/
        rename=$(find . -name "*SLES11-SP3-64_GA*")
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz
        echo "Downloaded $OS $VER ASR Client"
elif [ $OS == "Red Hat Enterprise Linux Server" ] && [ "$VER" =~ 7] ; then
        find . -name "*RHEL7-64_GA*" | xargs cp -t ~/Downloads/ASR/
        rename=$(find . -name "*RHEL7-64_GA*")
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz
        echo "Downloaded $OS $VER ASR Client"
elif [ $OS == "Red Hat Enterprise Linux Server" ] && [ "$VER" =~ 6]; then
        find . -name "*RHEL6-64_GA*" | xargs cp -t ~/Downloads/ASR/
        rename=$(find . -name "*RHEL6-64_GA*")
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz
        echo "Downloaded $OS $VER ASR Client"
elif [ $OS == "Red Hat Enterprise Linux Server" ] && [ "$VER" =~ 5 ]; then
        find . -name "*RHEL5-64_GA*" | xargs cp -t ~/Downloads/ASR/
        rename=$(find . -name "*RHEL5-64_GA*")
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz
        echo "Downloaded $OS $VER ASR Client"
elif [ $OS == "Oracle Linux Server"] && [ "$VER" =~  7]; then
        find . -name "*OL7-64_GA*" | xargs cp -t ~/Downloads/ASR/
        rename=$(find . -name "*OL7-64_GA*")
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz
        echo "Downloaded $OS $VER ASR Client"
elif [ $OS == "Oracle Linux Server"] && [ "$VER" =~  6]; then
        find . -name "*OL6-64_GA*" | xargs cp -t ~/Downloads/ASR/ASRAgent.tar.gz
        rename=$(find . -name "*OL6-64_GA*")
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz
        echo "Downloaded $OS $VER ASR Client"
elif [ "$OS" == "Debian GNU/Linux"] && [ $VER ==  8]; then
        find . -name "*DEBIAN8-64_GA*" | xargs cp -t ~/Downloads/ASR/
        rename=$(find . -name "*DEBIAN8-64_GA*")
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz
        echo "Downloaded $OS $VER ASR Client"
elif [ "$OS" == "Debian GNU/Linux"] && [ $VER ==  7]; then
        find . -name "*DEBIAN7-64_GA*" | xargs cp -t ~/Downloads/ASR/
        rename=$(find . -name "*DEBIAN7-64_GA*")
        line=$(echo $rename | cut -d ' ' -f2)
        mv $line ASRAgent.tar.gz        
        echo "Downloaded $OS $VER ASR Client"
else
        echo "$OS $VER is not supported"
        exit 0
fi

find . -name  "*connection*" | xargs cp -t ~/Downloads/ASR/

susspress=$(tar -xvf ASRAgent.tar.gz)

sudo ./install -r MS -v VmWare -q
sudo /usr/local/ASR/Vx/bin/UnifiedAgentConfigurator.sh -i $ipCs -P ~/Downloads/ASR/connection.passphrase