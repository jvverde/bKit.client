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
