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

git_token="notoken"
if [[ ! -z "$token" ]]
  then
    git_token=$token
fi

server=''
if [[ ! -z "$SERVER" ]]
  then
    server="--server \"${SERVER}\""
fi

user_and_repo=''
if [[ ! -z "$USER_AND_REPO" ]]
  then
    user_and_repo="--user_and_repo \"${USER_AND_REPO}\""
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

counter=0
if [[ -z "$RESULTS_FILE_NAME" ]]
  then
    for file in testoutput/*_test_output.tar.gz
    do
      echo "File/s detected with default naming convention, like \"openjdk_test_output.tar.gz\"."
      echo "Correcting these to a job-specific naming format."
      nameInt=""
      if [ "${counter}" != "0" ]; then
        nameInt="_${counter}"
      fi
      jobNameSubstring=$(echo "${UPSTREAM_JOB_NAME}" | sed -r 's/([^_]*_){2}//')
      newName="AQA_${VERSION}_hotspot_${jobNameSubstring}_test_output_${TIMESTAMP}.tar.gz"
      echo "Renaming ${file} to ${newName}"
      mv "${file}" "${newName}"
    done
fi

counter=0
if [[ ! -z "$RESULTS_FILE_NAME" ]]
  then
    for file in testoutput/*.tar.gz
    do
      echo "Replacing test results file name with RESULTS_FILE_NAME value."
      nameInt=""
      if [ "${counter}" != "0" ]; then
        nameInt="_${counter}"
      fi
      newName="AQA_${VERSION}_hotspot_${RESULTS_FILE_NAME}${nameInt}_${TIMESTAMP}.tar.gz"
      echo "Renaming ${file} to ${newName}"
      mv "${file}" "${newName}"
      counter=$((counter+1))
    done
fi

files=`ls $PWD/testoutput/AQA_*  | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g'`
echo "file si ${files}"
RELEASE_OPTION="--release"
description="The results files for tests associated with the release of ${TAG}"
cd $WORKSPACE/openjdk-website-backend/adopt-github-release
chmod +x gradlew
GRADLE_USER_HOME=./gradle-cache ./gradlew --no-daemon run --args="--version \"${VERSION}\" --tag \"${TAG}\" --description \"${description}\" --git_token \"${git_token}\" ${server} ${user_and_repo} $RELEASE_OPTION $files"
