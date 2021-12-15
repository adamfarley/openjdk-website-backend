#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
timestampRegex="[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}"

git_token = "notoken"
if [[ ! -z "$token" ]]
  then
	echo "debug12345"
    git_token = $token
fi

for file in testoutput/AQA_*
do
  echo "Processing $file";
  newName=$(echo "${file}" | sed -r "s/${timestampRegex}/$TIMESTAMP/")
  echo "${newName}"
  if [ "${file}" != "${newName}" ]; then
    # Rename archive and checksum file with new timestamp
    echo "Renaming ${file} to ${newName}"
    mv "${file}" "${newName}"
  fi
done

files=`ls $PWD/testoutput/AQA_*  | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g'`
echo "file si ${files}"
RELEASE_OPTION="--release"
description='testingrelease'
server=''
org='test'
cd adopt-github-release
chmod +x gradlew
GRADLE_USER_HOME=./gradle-cache ./gradlew --no-daemon run --args="--version \"${VERSION}\" --tag \"${TAG}\" --description \"${description}\" --git_token \"${git_token}\" ${server} ${org} $RELEASE_OPTION $files"
