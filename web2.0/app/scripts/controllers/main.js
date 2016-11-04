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

      // self.showComputersGrid = true;
      // self.showDrivesGrid = false;

      self.computers = $filter('name.display.filter')($computers);
      self.backups = [];
      self.path = '';

      self.querySearch = query;
      self.onSelectBackup = onSelectBackup;
      self.selectComputer = selectComputer;
      self.processSelection = processSelection;
      self.reset = reset;

      self.loadContent = loadContent;
      self.buildUrl = buildUrl;

      function query(search) {
        console.log('query', self.computers);
        return $filter('filter')(self.computers, search);
      }

      function selectComputer(pc) {
        self.selectedComputer = pc;

        if (pc.drives.length === 1) processSelection(pc.drives[0]);
      }



      function reset(pc) {

        self.selectedComputer = pc;

        self.backups = [];
        self.selectedBackup = null;
        self.selectedDrive = null;
        self.explorer = null;


      }

      function processSelection(drive) {

        if (!drive) return;
        // self.showDrivesGrid = false;
        self.selectedDrive = drive;
        console.log('drive', drive);
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

        if ((!folder.opened && folder.folders.length === 0) || bak) {
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
          folder.folders.forEach(function (f) {
            clearFolderSelection(f);
          });
        }
      }


      function buildUrl(file, action) {

        return $request.buildUrl('/' + action, [
          self.selectedComputer.id,
          self.selectedDrive.id,
          self.selectedBackup.id,
          self.path
        ]);
      }
    }
  ]);
