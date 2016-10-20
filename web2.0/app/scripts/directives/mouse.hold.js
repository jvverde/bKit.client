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
