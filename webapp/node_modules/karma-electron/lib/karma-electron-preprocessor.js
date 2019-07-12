// Load our dependencies
var fs = require('fs');
var path = require('path');
var minstache = require('minstache');
var jsStringEscape = require('js-string-escape');
var convertSourceMap = require('convert-source-map');

// Load our template
// DEV: We minify to remove impact of line numbers
//   To reproduce this, make a test fail and remove minification
//   Notice how the error line goes from 10 to 30 =(
// DEV: We should be using a minifier but the mustache template prevents this
var templateStr = fs.readFileSync(__dirname + '/node-integration-iframe.mustache.js', 'utf8');
var minifiedTemplateStr = templateStr.replace(/\/\/[^\n]+/g, '\n').replace(/\n/g, '');
// DEV: We inject a newline after content to prevent `//` comments from breaking our closure
minifiedTemplateStr = minifiedTemplateStr.replace(/(content}})/, '$1\n');
var template = minstache.compile(minifiedTemplateStr);

// Define our framework to inject our `node-integration`
var $inject = ['config.basePath'];
function createElectronPreprocessor(karmaBasePath) {
  // Generate our preprocessor function
  function electronPreprocessor(content, file, done) {
    // Render our content without a source map
    var sourceMap = convertSourceMap.fromSource(content);
    var output = template({
      content: convertSourceMap.removeComments(content),
      dirname: jsStringEscape(path.dirname(file.originalPath)),
      filename: jsStringEscape(file.originalPath),
      karmaBasePath: jsStringEscape(karmaBasePath),
      sep: jsStringEscape(path.sep)
    });

    // If there was a source map, add it back
    if (sourceMap) {
      output += '\n' + sourceMap.toComment();
    }

    // Callback with our content
    done(null, output);
  }

  // Return our preprocessor
  return electronPreprocessor;
}

// Define depenencies so our function can receive them
createElectronPreprocessor.$inject = $inject;

// Export our launcher
module.exports = {
  'preprocessor:electron': ['factory', createElectronPreprocessor]
};
