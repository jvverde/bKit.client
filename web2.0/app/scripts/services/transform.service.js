'use strict';

/**
 * @ngdoc service
 * @name bkitApp.data.transform
 * @description
 * # data.transform
 * Service in the bkitApp.
 */
angular.module('bkitApp')
  .service('transform', function () {
    // AngularJS will instantiate a singleton by calling "new" on this function

    this.backupsByDate = function (computer, drive) {
      var backups = [];

      drive.backups.forEach(function (bak) {

        var ind;
        var date = moment(bak.substring(5), 'YYYY.MM.DD-HH.mm.ss'); //TODO all tz
        var newBak = {
          computer: computer,
          drive: drive,
          time: date,
          id: bak
        };

        backups.push(newBak);
      });

      backups.sort(function (first, second) {
        if (first.time.isAfter(second.time)) {
          return -1;
        } else return 1;
      })

      return backups;
    }

  });
