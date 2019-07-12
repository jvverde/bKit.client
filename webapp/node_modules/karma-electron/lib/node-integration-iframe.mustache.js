(function () {
  // Set up local filename and dirname
  // DEV: `__filename` would be a path to Electron since we are loading an HTTP URL
  //   Once we perform a `require`, it will be using our `require's` context :+1:
  // DEV: Ignore JSHint so we can override `__filename` in our closure
  // DEV: We use `window.require` sniffing to prevent emulating a Node.js environment in a non-Node.js one
  var __filename = window.require ? '{{!filename}}' : undefined; // jshint ignore:line
  var __dirname = window.require ? '{{!dirname}}' : undefined;

  // Save original require/require.resolve
  if (window.require) {
    var __require = window.require;
    var __requireResolve = __require.resolve;

    // Add our base directory as the path to find node modules from
    if (!window.__karmaBasePathAddedToModule) {
      module.paths = module.paths.concat(__require('module')._nodeModulePaths('{{!karmaBasePath}}'));
      window.__karmaBasePathAddedToModule = true;
    }

    // Define our patched require/require.resolve
    var __requireFilepath = function (filepath) {
      // If the filepath is relative, prepend the filename
      // e.g. `./submodule` -> `/home/todd/.../integration-test/./submodule`
      if (filepath && filepath[0] === '.') {
        filepath = __dirname + '{{!sep}}' + filepath;
      }

      // Return our filepath
      return filepath;
    };
    // Define our require/resolve.resolve
    window.require = function (filepath) {
      return __require(__requireFilepath(filepath));
    };
    window.require.resolve = function (filepath) {
      return __requireResolve(__requireFilepath(filepath));
    };
  }

  // Inject our content
  // jscs:disable
  // jshint ignore:start
  {{!content}}
  // jshint ignore:end
  // jscs:enable
}());
