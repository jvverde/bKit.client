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
      var selectedDay = null;


      self.computers = $computers;
      self.querySearch = query;
      self.openExplorer = openExplorer;
      self.onSelectDay = onSelectDay;
      self.selectComputer = selectComputer;
      self.backups = [];


      function query(search) {
        console.log('query', self.computers);
        return $filter('filter')(self.computers, search);
      }

      function organizeBackupsByDate(computer) {

        var backups = [];

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

            backups.push(newBak);
          });
        });

        backups.sort(function (first, second) {
          if (first.time.isAfter(second.time)) {
            return -1;
          } else return 1;
        })

        return backups;
      }

      function selectComputer(pc) {
        self.selectedComputer = pc;
        self.backups = organizeBackupsByDate(pc);
      }

      function openExplorer(computer, drive, bak) {

        $request.getBackup(computer, drive, bak)
          .then(function (data) {
            self.explorer = data;
            console.log('explorer', self.explorer);
          });
      }

      function onSelectDay(event) {

        var day = event.day;
        var pcs = [];

        day.backups.forEach(function (bak) {
          var exists = pcs.some(function (pc) {
            return pc.id === bak.computer.id;
          });

          if (!exists) pcs.push(bak.computer);
        });

        self.selectedComputer = null;
        self.computers = pcs;
        if (pcs.length === 1) self.selectedComputer = pcs[0];
      }

      //self.backups = organizeBackupsByDate($computers[0]);
      console.log('main ctrl', $computers);
    }
  ]);
