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
      templateUrl: 'scripts/directives/calendar.tmpl.html',
      restrict: 'E',
      scope: false,
      link: function postLink(scope, iElement, iAttrs) {

        //if (!iAttrs.month || !iAttrs.year) throw new Error('Missing required attributes');

        scope.handleCellClick = handleCellClick;
        scope.syncronizeSelection = syncronizeSelection;

        function handleCellClick(event, index, item) {
          scope.selectedCell = index;
          scope.$eval(iAttrs.onCellClick)(event, item);
        }

        function syncronizeSelection(item, field) {

          if (!item) return;
          for (var i = 0; i < scope.content.length; i++) {
            if (scope.content[i][field] === item[field]) {
              scope.scrollTo(1 - i / scope.content.length);
              handleCellClick(null, scope.content.length -1 -i, item);
              break;
            }
          }
        }

        scope.$watchCollection(iAttrs.content, function (newArr, old) {

          scope.content = scope.$eval(iAttrs.content);
          scope.increment = $config.calendar.cell.width;
          scope.overflowedElemWidth = scope.content.length * scope.increment;

          //console.log('content', scope.content);
        });
      }
    };
  }]);
