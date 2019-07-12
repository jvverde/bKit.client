// Karma configuration
// Generated on Thu Mar 03 2016 19:57:50 GMT-0600 (CST)
var Set = require('collections/set');
module.exports = function (config) {
  // Set up default files to test against
  var karmaTest = 'karma-test.js';
  var successTest = 'success-test.js';
  var phantomJsTest = 'phantomjs-test.js';
  var eofCommentTest = 'eof-comment-test.js';
  var failureTest = 'failure-test.js';
  var sourceMapTest = 'source-map-test.js';
  var uncaughtExceptionTest = 'uncaught-exception-test.js';
  var testFiles = ['*-test.js'];
  var excludeFiles = new Set([failureTest, karmaTest, phantomJsTest, sourceMapTest, uncaughtExceptionTest]);

  // If we are testing uncaught exceptions, then update our tests
  if (process.env.TEST_TYPE === 'UNCAUGHT_EXCEPTION') {
    testFiles = [uncaughtExceptionTest];
    excludeFiles.delete(uncaughtExceptionTest);
  } else if (process.env.TEST_TYPE === 'EOF_COMMENT') {
    testFiles = [eofCommentTest];
    excludeFiles.delete(eofCommentTest);
  } else if (process.env.TEST_TYPE === 'FAILURE') {
    testFiles = [failureTest];
    excludeFiles.delete(failureTest);
  } else if (process.env.TEST_TYPE === 'KARMA') {
    testFiles = [karmaTest];
    excludeFiles.delete(karmaTest);
  } else if (process.env.TEST_TYPE === 'PHANTOMJS') {
    testFiles = [successTest, phantomJsTest];
    excludeFiles = new Set();
  } else if (process.env.TEST_TYPE === 'SOURCE_MAP') {
    testFiles = [sourceMapTest];
    excludeFiles.delete(sourceMapTest);
  } else if (process.env.TEST_TYPE) {
    throw new Error('Unrecognized test type "' + process.env.TEST_TYPE + '"');
  }

  // Define our config
  config.set({
    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['mocha'],

    // list of files / patterns to load in the browser
    files: testFiles,

    // list of files to exclude
    exclude: excludeFiles.toArray(),

    browserNoActivityTimeout: 2000,
    client: {
      useIframe: false
    },

    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      '*-test.js': ['electron']
    },

    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],

    // web server port
    port: 9876,

    // enable / disable colors in the output (reporters and logs)
    colors: true,

    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,

    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,

    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Electron'],

    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false,

    // Concurrency level
    // how many browser should be started simultaneous
    concurrency: Infinity,

    // Load in our module as a plugin
    // https://github.com/karma-runner/karma-chrome-launcher/blob/v0.2.2/examples/simple/karma.conf.js
    plugins: [
        require('../../'),
        'karma-mocha',
        'karma-phantomjs-launcher'
    ]
  });
};
