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

        // element.on('scroll', function (event) {
        //   console.log('onScroll', this.scrollLeft);
        // });

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
      }
    };
  });
