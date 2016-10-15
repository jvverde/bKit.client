'use strict';

/**
 * @ngdoc function
 * @name bkitApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the bkitApp
 */
angular.module('bkitApp')
  .controller('MainCtrl', ['$scope', 'config', '$filter', 'computers', 'home.requests',
    function ($scope, $config, $filter, $computers, $request) {
      var self = this;

      self.computers = $computers;
      self.querySearch = query;
      self.openExplorer = openExplorer;


      function query(search) {
        return $filter('filter')(self.computers, search);
      }

      function organizeBackupsByDate(computers) {

        //var date = moment('2016.09.16-23.35.54', 'YYYY.MM.DD-HH.mm.ss');

        var days = [];
        computers.forEach(function (computer) {
          computer.drives.forEach(function (drive) {
            drive.backups.forEach(function (bak) {

              var ind;
              var date = moment(bak.substring(5), 'YYYY.MM.DD-HH.mm.ss'); //TODO all tz
              var newBak = {
                computer: computer,
                drive: drive,
                time: date,
                id: bak
              };
              var exists = days.some(function (day, i) {
                if (day.moment.isSame(date.startOf('day'))) {
                  ind = i;
                  return true;
                }
              });

              if (exists) {
                days[ind].backups.push(newBak);
                days[ind].count++;
              } else {
                days.push({
                  moment: date.startOf('day'),
                  backups: [newBak],
                  count: 1
                });
              }
            });
          });
        });
        days.sort(function (first, second) {
          if (first.moment.isAfter(second.moment)) {
            return -1;
          } else return 1;
        })
        console.log('days', days);
        return days;
      }

      function openExplorer(computer, drive, bak) {

        $request.getBackup(computer, drive, bak)
          .then(function (data) {
            self.explorer = data;
            console.log('explorer', self.explorer);
          });
      }

      organizeBackupsByDate($computers);
      console.log('main ctrl', $computers);
    }
  ]);
