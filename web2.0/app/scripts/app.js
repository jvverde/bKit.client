'use strict';

/**
 * @ngdoc overview
 * @name bkitApp
 * @description
 * # bkitApp
 *
 * Main module of the application.
 */
angular
  .module('bkitApp', [
    'ngRoute',
    'ngSanitize',
    'ngMaterial',
    'ui.router'
  ])
  .config(function ($routeProvider, $stateProvider, $locationProvider) {

    $stateProvider
      .state('home', {
        name: 'home',
        url: '/',
        templateUrl: 'views/main.html',
        controller: 'MainCtrl',
        controllerAs: 'main',
        resolve: {
          computers: ['home.requests', function ($home) {
            return $home.loadComputers();
          }]
        }
      });

    $routeProvider.otherwise({
        redirectTo: '/'
    });

    $locationProvider.html5Mode({
      enabled: true,
      requireBase: false
    });
  });
