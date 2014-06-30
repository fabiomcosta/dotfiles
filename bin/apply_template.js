#!/usr/bin/env node

var fs = require('fs');
var path = require('path');
var _ = require('lodash');
var platform = require('platform');

var destPath = path.normalize(process.argv[2]);
var origPath = path.normalize(process.argv[3]);

// TODO be safe and check for the existance of the @DOTFILE marker on the
// `path` first.

var template = fs.readFileSync(origPath);
var renderedTemplate = _.template(template, {
  isOSX: platform.os.family === 'Darwin'
});
fs.writeFileSync(destPath, renderedTemplate);
