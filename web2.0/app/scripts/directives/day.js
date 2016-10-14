'use strict';

/**
 * @ngdoc directive
 * @name bkitApp.directive:day
 * @description
 * # day
 */
angular.module('bkitApp')
  .directive('day', function () {
    return {
      templateUrl: 'scripts/directives/day.tmpl.html',
      restrict: 'E',
      link: function postLink(scope, element, iAttrs) {
        // console.log('iAttrs', iAttrs);
        // if (!iAttrs.date) throw new Error('Attr "date" is required for "Day" directive');
        // scope.date = iAttrs.date.format('DD');
      }
    };
  });
