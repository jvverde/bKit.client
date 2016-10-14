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
      link: function postLink(scope, element, attrs) {
        element.text('this is the calendar directive');
      }
    };
  });
