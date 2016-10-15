'use strict';

/**
 * @ngdoc function
 * @name bkitApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the bkitApp
 */
angular.module('bkitApp')
  .controller('MainCtrl', ['$scope', 'config', '$filter', 'computers',
    function ($scope, $config, $filter, $computers) {
      var self = this;

      self.computers = $computers;

      self.querySearch = function (search) {
        var arr = $filter('filter')(self.computers, search);
        console.log('search', arr);
        return arr;
      }

      console.log('main ctrl', $computers);
    }
  ]);
