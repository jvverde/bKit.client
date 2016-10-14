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
      dayFormat: 'd',
      firstDayOfWeek: 1
    },
    logo: {
      path: 'images/logo/',
      name: function (size, extension) {

        if (!extension) extension = 'png';
        if (size % 32 !== 0) size = 512;

        return size + 'x' + size + '.' + extension;
      }
    }
  });
