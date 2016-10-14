'use strict';

/**
 * @ngdoc directive
 * @name bkitApp.directive:calendar
 * @description
 * # calendar
 */
angular.module('bkitApp')
  .directive('calendar', function () {
    return {
      templateUrl: 'scripts/directives/calendar.tmpl.html',
      restrict: 'E',
      link: function postLink(scope, iElement, iAttrs) {

        //if (!iAttrs.month || !iAttrs.year) throw new Error('Missing required attributes');


        scope.week = [];

        for (var i = 0; i < 7; i++){
          var mom = moment().startOf('day');
          scope.week.push(mom.subtract(i, 'days'));
        }

        console.log('week', scope.week);
        scope.onDayClick = function (event) {
          console.log('on click event');
        };

      }
    };
  });
