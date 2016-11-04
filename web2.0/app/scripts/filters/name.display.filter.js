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
