'use strict';

/**
 * @ngdoc overview
 * @name bkitApp
 * @description
 * # bkitApp
 *
 * Main module of the application.
 */
angular
  .module('bkitApp', [
    'ngRoute',
    'ngSanitize',
    'ngMaterial',
    'ui.router'
  ])
  .config(["$routeProvider", "$stateProvider", "$locationProvider", "$urlRouterProvider", function ($routeProvider, $stateProvider, $locationProvider, $urlRouterProvider) {

    $stateProvider
      .state('home', {
        name: 'home',
        url: '/',
        templateUrl: 'views/main.html',
        controller: 'MainCtrl',
        controllerAs: 'main',
        resolve: {
          computers: ['home.requests', function ($home) {
            return $home.loadComputers();
          }]
        }
      });

    $routeProvider.otherwise({
        redirectTo: '/#/'
    });

    $urlRouterProvider.when('', '/#/');
    $urlRouterProvider.otherwise('/#/');
  }]);

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

      function processSelection(drive,pc) {
        if (!drive) return;
        self.selectedComputer = pc || self.selectedComputer;
        // self.showDrivesGrid = false;
        self.selectedDrive = drive;
        console.log('drive', drive);
        self.backups = $transform.backupsByDate(self.selectedComputer, drive);

        //we've just updated self.backups so we need to wait for angular's $digest cycle to finish before we can syncronize the selection
        $scope.syncronizeSelection && $timeout(function () {
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

      self.querySearch = query;
      self.onSelectBackup = onSelectBackup;
      self.selectComputer = selectComputer;
      self.processSelection = processSelection;
      self.reset = reset;

      self.loadContent = loadContent;
      self.buildUrl = buildUrl;

    }
  ]);

'use strict';

/**
 * @ngdoc directive
 * @name bkitApp.directive:calendar
 * @description
 * # calendar
 */
angular.module('bkitApp')
  .directive('calendar', ['config', function ($config) {
    return {
      templateUrl: 'views/calendar.tmpl.html',
      restrict: 'E',
      scope: false,
      replace: true,
      link: function postLink(scope, iElement, iAttrs) {

        //if (!iAttrs.month || !iAttrs.year) throw new Error('Missing required attributes');

        scope.handleCellClick = handleCellClick;
        scope.syncronizeSelection = syncronizeSelection;
        scope.increment = $config.calendar.cell.width / 2;

        function handleCellClick(event, index, item) {
          scope.selectedCell = index;
          scope.$eval(iAttrs.onCellClick)(event, item);
        }

        function syncronizeSelection(item, field) {

          if (!item) return;
          for (var i = 0; i < scope.content.length; i++) {
            if (scope.content[i][field] === item[field]) {
              //scope.scrollTo(1 - i / scope.content.length);
              handleCellClick(null, scope.content.length -1 -i, item);
              break;
            }
          }
        }

        scope.$watchCollection(iAttrs.content, function (newArr, old) {

          scope.content = scope.$eval(iAttrs.content);
          scope.overflowedElemWidth = scope.content.length * $config.calendar.cell.width;
          //console.log('content', scope.content);
        });
      }
    };
  }]);

'use strict';

/**
 * @ngdoc service
 * @name bkitApp.config
 * @description
 * # config
 * Constant in the bkitApp.
 */
angular.module('bkitApp')
  .constant('config', {
    calendar: {
      cell: {
        width: 100
      }
    },
    logo: {
      path: 'images/logo/',
      name: function (size, extension) {

        if (!extension) extension = 'png';
        if (size % 32 !== 0) size = 512;

        return size + 'x' + size + '.' + extension;
      }
    },
    server: {
      url: ''
    }
  });

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

    this.buildUrl = url;
    function url(path, ids) {

      if (ids && Array.isArray(ids)) {
        ids.forEach(function (id) {
          path += '/' + id;
        });
      }
      return $config.server.url + path;
    }

    function mapPairToArray(obj, name, value) {
      return Object.keys(obj).map(function (k) {

        var ret = {};
        ret[name] = k;
        ret[value] = obj[k];

        return ret;
      });
    }
    function mapComputerProps(computers){
      return Object.keys(computers).map(function(k) {
        var comps = (computers[k] || '').split('.');
        var uuid = comps.pop();
        comps.shift();                    //discard name
        var domain = comps.join('.') 
        return {
          name: k,
          id:  computers[k],
          uuid: uuid,
          domain: domain
        };
      })
    }

    this.loadComputers = function () {
      return $http.get(url('/computers'))
        .then(function (res) {
          var computers = mapComputerProps(res.data);
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
          (res.data.files || []).forEach(function(file){
            file.datetime = moment(1000*file.datetime)
          })  
          return res.data;
        }, function (err) {
          console.error('http err', err);
        }).catch(function (e) {
          console.error('exception', e);
        });
    }

    this.restore = function (path, computer, drive, bak) {
      return $http.get(url('/bkit', [computer, drive, bak, path]))
        .then(function (res) {
          return res;
        }, function (err) {
          console.error('http err', err);
        }).catch(function (e) {
          console.error('exception', e);
        });
    }

    this.view = function (path, computer, drive, bak) {
      return $http.get(url('/view', [computer, drive, bak, path]))
        .then(function (res) {
          return res;
        }, function (err) {
          console.error('http err', err);
        }).catch(function (e) {
          console.error('exception', e);
        });
    }

    this.download = function (path, computer, drive, bak) {
      return $http.get(url('/download', [computer, drive, bak, path]))
        .then(function (res) {
          return res;
        }, function (err) {
          console.error('http err', err);
        }).catch(function (e) {
          console.error('exception', e);
        });
    }

  }]);

'use strict';

/**
 * @ngdoc service
 * @name bkitApp.error.logger
 * @description
 * # error.logger
 * Service in the bkitApp.
 */
angular.module('bkitApp')
  .service('error.logger', function () {
    // AngularJS will instantiate a singleton by calling "new" on this function
  });

'use strict';

/**
 * @ngdoc directive
 * @name bkitApp.directive:scroll.control
 * @description
 * # scroll.control
 */
angular.module('bkitApp')
  .directive('scrollControl', function () {
    return {
      restrict: 'A',
      link: function postLink(scope, element, attrs) {

        element.on('scroll', function (event) {
           console.log('onScroll', this.scrollLeft);
         });

        // element.on('dragstart', function (event) {
        //   console.log('onDragStart', event);
        // });

        // element.on('dragend', function (event) {
        //   console.log('onDragEnd', event);
        // });

        scope.scroll = function (direction, increment) {

          if (direction === 'left') {
            element[0].scrollLeft -= increment;
          } else if (direction === 'right') {
            element[0].scrollLeft += increment;
          } else throw new Error('Unknown direction');
        };

        scope.scrollTo = function (percentage) {

          var width = element[0].clientWidth;
          var maxScrollValue = scope.overflowedElemWidth - width;

          element[0].scrollLeft = maxScrollValue * percentage;
        }
      }
    };
  });

'use strict';

/**
 * @ngdoc directive
 * @name bkitApp.directive:mouse.hold
 * @description
 * # mouse.hold
 */
angular.module('bkitApp')
  .directive('mouseHold', ['$interval', 'config', function ($interval, $config) {
    return {
      restrict: 'A',
      link: function (scope, iElement, iAttrs) {

        var promise;
        iElement.on('mousedown', function (event) {
          scope.$eval(iAttrs.mouseHold);
          promise = $interval(function () {
            scope.$eval(iAttrs.mouseHold);
          }, 100);
        });

        iElement.on('mouseup', function (event) {
          $interval.cancel(promise);
        });
      }
    };
  }]);

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
        date.utc();
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

'use strict';

/**
 * @ngdoc filter
 * @name bkitApp.filter:name.display.filter
 * @function
 * @description
 * # name.display.filter
 * Filter in the bkitApp.
 */
angular.module('bkitApp')
  .filter('name.display.filter', function () {


    return function (computers) {

      function checkRepeats(input, repeats) {

        if (!input) return '';

        var index = input.indexOf('.'), i = 0;
        if (index === -1) return input;

        var str = input.substring(0, index);
        var exists = repeats.some(function (elem, ind) {
          i = ind;
          return elem.name === str;
        });


        if (exists) {
          str += ' (' + ++(repeats[i].count) + ')';
        } else repeats.push({
          name: str,
          count: 1
        });

        return str;
      }

      if (computers) {
        var pcRepeats = [];
        computers.forEach(function (elem, ind, arr) {
          arr[ind].name = checkRepeats(elem.name, pcRepeats);
          var driveRepeats = [];
          elem.drives.forEach(function (e, i, a) {
            a[i].name = checkRepeats(e.id, driveRepeats);
          });
        });
      }

      return computers;
    };
  });

'use strict';

/**
 * @ngdoc filter
 * @name bkitApp.filter:backup.display.filter
 * @function
 * @description
 * # backup.display.filter
 * Filter in the bkitApp.
 */
angular.module('bkitApp')
  .filter('bakDisplay', function () {
    return function (input) {
      return input;
    };
  });
