'use strict';

/**
 * @ngdoc service
 * @name bkitApp.fs.service
 * @description
 * # fs.service
 * Service in the bkitApp.
 */
angular.module('bkitApp')
  .service('fs', ['home.requests', function ($request) {
    // AngularJS will instantiate a singleton by calling "new" on this function
    var self = this;
    var root = {
      name: 'root',
      parent: null,
      folders: [],
      files: []
    };


    this.loadData = function (computer, drive, bak, path) {

      return $request.getBackup(computer, drive, bak, path)
        .then(function (data) {

          var folder = root;

          if (path !== '') {
            folder = self.resolveFolder(path);
          }

          folder.files = data.files;
          data.folders.forEach(function (f) {
            folder.folders.push({
              name: f,
              parent: folder,
              folders: [],
              files: []
            });
          });

          return root;
        });
    }


    this.resolvePath = function (folder) {

      var path = '';
      var current = folder;
      while (current.parent !== null) {

        path = current.name + '/' + path;
        current = current.parent;
      }

      return path;
    }

    this.resolveFolder = function (path) {

      var current = root;
      var steps = path.split('/');

      steps.forEach(function (step) {
        current.folders.some(function (folder) {
          if (folder.name === step) {
            current = folder;
            return true;
          }
        });
      })

      return current;
    }






  }]);
