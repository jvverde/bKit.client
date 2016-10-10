'use strict';

/**
 * @ngdoc function
 * @name bkitApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the bkitApp
 */
angular.module('bkitApp')
  .controller('MainCtrl', ['$scope', 'config',
    function ($scope, $config) {
      var self = this;

      self.img = $config.logo.path + $config.logo.name(512, 'png');

      self.dayFormat = $config.calendar.dayFormat;
      self.firstDayOfWeek = $config.calendar.firstDayOfWeek;
    }
  ]);
