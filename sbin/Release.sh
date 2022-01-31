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

sed_app="sed -r"
timestampRegex="[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}"
jobNameBeginningRegex="([^_]*_){2}"

if [[ "$OSTYPE" == "darwin"* ]]
  then
    echo "Macos detected. Updated Java version to 11 and sed app to gsed."
    sed_app="gsed -r"
    export JAVA_HOME=$(/usr/libexec/java_home -v 11)
elif [[ "$OSTYPE" == "solaris"* ]]
  then
    echo "Solaris detected. Removing -r option from sed commands and adjusting regexs to compensate."
    sed_app="sed"
    timestampRegex="[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]"
    jobNameBeginningRegex="^[a-zA-Z0-9]*_[a-zA-Z0-9]*_"
fi

for file in testoutput/AQA_*
do
  echo "Processing $file";
  newName=$(echo "${file}" | ${sed_app} "s/${timestampRegex}/$TIMESTAMP/")
  echo "${newName}"
  if [ "${file}" != "${newName}" ]; then
    # Rename archive and checksum file with new timestamp
    echo "Renaming ${file} to ${newName}"
    mv "${file}" "${newName}"
  fi
done

counter=1
if [[ -z "$RESULTS_FILE_NAME" ]]
  then
    for file in testoutput/*_test_output.tar.gz
    do
      echo "File/s detected with default naming convention, like \"openjdk_test_output.tar.gz\"."
      echo "Correcting these to a job-specific naming format."
      nameInt=""
      if [ "${counter}" != "1" ]; then
        nameInt="_ResultsNum${counter}"
      fi
      jobNameSubstring=$(echo "${UPSTREAM_JOB_NAME}" | ${sed_app} "s/${jobNameBeginningRegex}//")
      newName="testoutput/AQA_${VERSION}_hotspot_${jobNameSubstring}_test_output${nameInt}_${TIMESTAMP}.tar.gz"
      echo "Renaming ${file} to ${newName}"
      mv "${file}" "${newName}"
      counter=$((counter+1))
    done
fi

counter=1
if [[ ! -z "$RESULTS_FILE_NAME" ]]
  then
    for file in testoutput/*.tar.gz
    do
      echo "Replacing test results file name with RESULTS_FILE_NAME value."
      nameInt=""
      if [ "${counter}" != "1" ]; then
        nameInt="_ResultsNum${counter}"
      fi
      newName="testoutput/AQA_${VERSION}_hotspot_${RESULTS_FILE_NAME}${nameInt}_${TIMESTAMP}.tar.gz"
      echo "Renaming ${file} to ${newName}"
      mv "${file}" "${newName}"
      counter=$((counter+1))
    done
fi

files=`echo $PWD/testoutput/AQA_*`
echo "Files to be uploaded: ${files}"
RELEASE_OPTION="--release"
description="The results files for tests associated with the release of ${TAG}"
cd $WORKSPACE/openjdk-website-backend/adopt-github-release
chmod +x gradlew
echo "./gradle-cache ./gradlew --no-daemon run --args=abc--version \"${VERSION}\" --tag \"${TAG}\" --description \"${description}\" --git_token \"${git_token}\" ${server} ${user_and_repo} $RELEASE_OPTION $files abc"
GRADLE_USER_HOME=./gradle-cache ./gradlew --no-daemon run --args="--version \"${VERSION}\" --tag \"${TAG}\" --description \"${description}\" --git_token \"${git_token}\" ${server} ${user_and_repo} $RELEASE_OPTION $files"
