'use strict';

/**
 * @ngdoc function
 * @name bkitApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the bkitApp
 */
angular.module('bkitApp')
  .controller('MainCtrl', ['$scope', '$filter', '$timeout', 'config', 'computers', 'home.requests', 'transform', 'fs',
    function ($scope, $filter, $timeout, $config, $computers, $request, $transform, $fs) {
      var self = this;

      self.showComputersGrid = true;
      self.showDrivesGrid = false;
      self.computers = $computers;
      self.backups = [];
      self.path = '';

      self.querySearch = query;
      self.onSelectBackup = onSelectBackup;
      self.selectComputer = selectComputer;
      self.processSelection = processSelection;
      self.loadContent = loadContent;

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
        self.backups = $transform.backupsByDate(self.selectedComputer, drive);

        //we've just updated self.backups so we need to wait for angular's $digest cycle to finish before we can syncronize the selection
        $timeout(function () {
          $scope.syncronizeSelection(self.backups[0], 'id');
        }, 10);
      }

      function onSelectBackup(event, bak) {
        if (self.selectedBackup && self.selectedBackup.id === bak.id) return;

        self.selectedBackup = bak;
        loadContent(self.path, bak.computer.id, bak.drive.id, bak.id);
      }

      function loadContent(obj, computer, drive, bak) {

        var folder;
        if (typeof obj === 'string') { //it's a path
          self.path = obj;
          folder = $fs.resolveFolder(obj);
        } else {  //it's a folder
          self.path = $fs.resolvePath(obj);
          folder = obj;
        }

        if (!folder.opened && folder.folders.length === 0) {
          self.loading = true;
          $fs.loadData(
            computer || self.selectedComputer.id,
            drive || self.selectedDrive.id,
            bak || self.selectedBackup.id,
            self.path)
            .then(function (fs) {

              self.explorer = fs;
              openFolder($fs.resolveFolder(self.path));
              self.loading = false;
            });
        } else openFolder(folder);
      }

      function openFolder(folder) {

        self.currentFolder = folder;
        self.currentFolder.opened = true;

        clearFolderSelection(self.explorer);
        self.currentFolder.selected = true;

      }

      function clearFolderSelection(folder) {
        folder.selected = false;
        if (folder.opened) {
          folder.folders.forEach(function(f) {
            clearFolderSelection(f);
          });
        }
      }
    }
  ]);
