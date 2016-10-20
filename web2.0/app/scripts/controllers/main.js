'use strict';

/**
 * @ngdoc function
 * @name bkitApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the bkitApp
 */
angular.module('bkitApp')
  .controller('MainCtrl', ['$scope', '$filter', '$timeout', 'config', 'computers', 'home.requests',
    function ($scope, $filter, $timeout, $config, $computers, $request) {
      var self = this;

      self.showComputersGrid = true;
      self.showDrivesGrid = false;
      self.computers = $computers;
      self.backups = [];

      self.querySearch = query;
      self.onSelectBackup = onSelectBackup;
      self.selectComputer = selectComputer;
      self.processSelection = processSelection;

      function query(search) {
        console.log('query', self.computers);
        return $filter('filter')(self.computers, search);
      }

      function selectComputer(pc) {
        self.selectedComputer = pc;
        self.showComputersGrid = false;
        self.showDrivesGrid = true;
      }

      function processSelection(drive) {

        if (!drive) return;
        self.showDrivesGrid = false;
        self.selectedDrive = drive;
        self.backups = organizeBackupsByDate(self.selectedComputer, drive);

        //we've just updated self.backups so we need to wait for angular's $digest cycle to finish before we can syncronize the selection
        $timeout(function () {
          $scope.syncronizeSelection(self.backups[0], 'id');
        }, 10);

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
        if (self.selectedBackup && self.selectedBackup.id === bak.id) return;

        self.selectedBackup = bak;
        openExplorer(bak.computer.id, bak.drive.id, bak.id);
      }

      //self.backups = organizeBackupsByDate($computers[0]);
      //console.log('main ctrl', $scope);

    }
  ]);
