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
      link: function postLink(scope, iElement, iAttrs) {

        //if (!iAttrs.month || !iAttrs.year) throw new Error('Missing required attributes');
        scope.onCellClick = scope.$eval(iAttrs.onDaySelect);
        scope.$watchCollection(iAttrs.content, function (newArr, old) {

          scope.content = scope.$eval(iAttrs.content);
          scope.increment = $config.calendar.cell.width;
          scope.overflowedElemWidth = scope.content.length * scope.increment;

          //console.log('content', scope.content);
        });

      }
    };
  }]);
