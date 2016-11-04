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
      cell: {
        width: 100
      }
    },
    logo: {
      path: 'images/logo/',
      name: function (size, extension) {

        if (!extension) extension = 'png';
        if (size % 32 !== 0) size = 512;

        return size + 'x' + size + '.' + extension;
      }
    },
    server: {
      url: ''
    }
  });
