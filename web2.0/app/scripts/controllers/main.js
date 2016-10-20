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
      self.onSelectBackup = onSelectBackup;
      self.processSelection = processSelection;
      self.backups = [];


      function query(search) {
        console.log('query', self.computers);
        return $filter('filter')(self.computers, search);
      }

      function processSelection(drive) {
        self.selectedDrive = drive;
        self.backups = organizeBackupsByDate(self.selectedComputer, drive);

        self.selectedBackup = self.backups[self.backups.length - 1].id;
        self.openExplorer(self.selectedComputer.id, drive.id, self.selectedBackup);
      }

      function organizeBackupsByDate(computer, drive) {

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

      function openExplorer(computer, drive, bak) {

        $request.getBackup(computer, drive, bak)
          .then(function (data) {
            self.explorer = data;

            console.log('explorer', self.explorer);
          });
      }

      function onSelectBackup(event, bak) {
        self.selectedBackup = bak.id;
      }

      //self.backups = organizeBackupsByDate($computers[0]);
      //console.log('main ctrl', $computers);
    }
  ]);
