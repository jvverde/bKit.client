'use strict';

/**
 * @ngdoc service
 * @name bkitApp.home.resolve
 * @description
 * # home.resolve
 * Service in the bkitApp.
 */
angular.module('bkitApp')
  .service('home.requests', ['$http', '$q', 'config', function ($http, $q, $config) {

    var self = this;

    function url(path, ids) {

      if (ids && Array.isArray(ids)) {
        ids.forEach(function(id) {
          path += '/' + id;
        });
      }
      return $config.server.url + path;
    }

    function mapPairToArray(obj, key, value) {
      return Object.keys(obj).map(function (k) {

        var ret = {};
        ret[key] = k;
        ret[value] = obj[k];

        return ret;
      });
    }

    this.loadComputers = function () {
      return $http.get(url('/computers'))
        .then(function (res) {
          var computers = mapPairToArray(res.data, 'name', 'id');
          var promises = [];

          computers.forEach(function (pc, ind, arr) {
            var promise = self.loadDrives(pc.id).then(function (drives) {
              drives = mapPairToArray(drives, 'id', 'backups');
              arr[ind].drives = drives;
              return arr[ind];
            });

            promises.push(promise);
          });

          return $q.all(promises);

        }).catch(function (e) {
          console.error('exception', e);
        });
    };

    this.loadDrives = function (computer) {
      return $http.get(url('/backups', [computer]))
        .then(function (res) {
          return res.data;
        }, function (err) {
          console.error('http err', err);
        }).catch(function (e) {
          console.error('exception', e);
        });
    }


    this.getBackup = function (computer, drive, bak, path) {

        return $http.get(url('/folder', [computer, drive, bak, path]))
        .then(function (res) {
          return res.data;
        }, function (err) {
          console.error('http err', err);
        }).catch(function (e) {
          console.error('exception', e);
        });
    }




  }]);
