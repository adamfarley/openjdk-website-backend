var Git = require("nodegit");
var path = require('path');
var colors = require('colors');
var emoji = require('node-emoji')
var rimraf = require('rimraf');
console.log("OpenJDK 8 with Hotspot"
var totalEver = 0;
rimraf('./releases', function() {
  Git.Clone("https://github.com/AdoptOpenJDK/openjdk8-releases.git", "./releases")
    .then(function(run) {
      var release = require('./releases/releases.json');

      for (var version in release) {
        total = 0
        console.log(release[version].tag_name.green)
        tag = release[version].tag_name
        for (var attributename in release[version].assets) {
          filename = release[version].assets[attributename].name
          extension = path.extname(filename)
          if (extension === ".gz" || extension === ".zip") {
            name = filename.split('_');
            arch = name[1]
            os = name[2]
            console.log(os + "-" + arch + ": " + release[version].assets[attributename].download_count);
            total += release[version].assets[attributename].download_count
            totalEver += release[version].assets[attributename].download_count
          }
        }
        console.log("Total downloads for " + tag + ": " + total + "\n")
      }
      console.log("Total Downloads Ever: " + totalEver + " " + emoji.get('trophy'))
    });
});

console.log("OpenJDK 9 with Hotspot"
var totalEver = 0;
rimraf('./releases', function() {
  Git.Clone("https://github.com/AdoptOpenJDK/openjdk9-releases.git", "./releases")
    .then(function(run) {
      var release = require('./releases/releases.json');

      for (var version in release) {
        total = 0
        console.log(release[version].tag_name.green)
        tag = release[version].tag_name
        for (var attributename in release[version].assets) {
          filename = release[version].assets[attributename].name
          extension = path.extname(filename)
          if (extension === ".gz" || extension === ".zip") {
            name = filename.split('_');
            arch = name[1]
            os = name[2]
            console.log(os + "-" + arch + ": " + release[version].assets[attributename].download_count);
            total += release[version].assets[attributename].download_count
            totalEver += release[version].assets[attributename].download_count
          }
        }
        console.log("Total downloads for " + tag + ": " + total + "\n")
      }
      console.log("Total Downloads Ever: " + totalEver + " " + emoji.get('trophy'))
    });
});

console.log("OpenJDK 9 with OpenJ9"
var totalEver = 0;
rimraf('./releases', function() {
  Git.Clone("https://github.com/AdoptOpenJDK/openjdk9-openj9-releases.git", "./releases")
    .then(function(run) {
      var release = require('./releases/releases.json');

      for (var version in release) {
        total = 0
        console.log(release[version].tag_name.green)
        tag = release[version].tag_name
        for (var attributename in release[version].assets) {
          filename = release[version].assets[attributename].name
          extension = path.extname(filename)
          if (extension === ".gz" || extension === ".zip") {
            name = filename.split('_');
            arch = name[1]
            os = name[2]
            console.log(os + "-" + arch + ": " + release[version].assets[attributename].download_count);
            total += release[version].assets[attributename].download_count
            totalEver += release[version].assets[attributename].download_count
          }
        }
        console.log("Total downloads for " + tag + ": " + total + "\n")
      }
      console.log("Total Downloads Ever: " + totalEver + " " + emoji.get('trophy'))
    });
});
