# Copyright 2018 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

WORKING_DIRECTORY=/home/vagrant
JDK_ARCHIVE=$1
PYTHON_MODULES=$2
PACKAGE_MANAGER=$3
IUS_RPM=$4

# check if the required software distributions have been added
if [ ! -f ${WORKING_DIRECTORY}/${JDK_ARCHIVE} ]; then
    echo "JDK archive not found. Please copy the ${JDK_ARCHIVE} to ${WORKING_DIRECTORY} folder and retry."
    exit 1
fi

# set ownership of the working directory to the default ssh user and group
chown -R ${DEFAULT_USER}:${DEFAULT_USER} ${WORKING_DIRECTORY}

# Install zip/unzip
sudo yum install zip unzip -y
if [ "$?" -eq "0" ];
then
  echo "Successfully installed zip."
else
  echo "Failed to install zip."
  exit 1
fi

# Install python3.6 and pip3
sudo rpm -Uvh $PACKAGE_MANAGER
sudo yum install -y $IUS_RPM
sudo yum install -y $PYTHON_MODULES

# Install virtualenv on pip3.6
sudo pip3.6 install virtualenv

# Install git
sudo yum install -y git

# Create jvm dir
java_dir="/usr/lib/jvm"
sudo mkdir -p $java_dir
chown -R ${DEFAULT_USER}:${DEFAULT_USER} $java_dir
sudo tar -xzvf ${WORKING_DIRECTORY}/${JDK_ARCHIVE} -C $java_dir
java_dist_dir_name=$(basename ${JDK_ARCHIVE})

# setup java
java_file_regex="jdk-([78])u([0-9]{1,3})-linux-(i586|x64)\.tar\.gz"
jdk_dir=$(echo $java_dist_dir_name | sed -nE "s/$java_file_regex/jdk1.\1.0_\2/p")
jdk_dir=$java_dir/$jdk_dir

declare -a packages=( "java" "javac" "javaws" )

for package in "${packages[@]}"
    do
        executable_path=$jdk_dir/bin/$package
        if [[ -f $executable_path ]]; then
            sudo update-alternatives --install /usr/bin/$package $package $executable_path 1
            sudo update-alternatives --set $package $executable_path
        fi
done

if [ "$?" -eq "0" ];
then
  echo "Setting up done."
  exit 0
else
  echo "Setting up failed."
  exit 1
fi
