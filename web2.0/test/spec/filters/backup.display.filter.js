'use strict';

describe('Filter: backup.display.filter', function () {

  // load the filter's module
  beforeEach(module('bkitApp'));

  // initialize a new instance of the filter before each test
  var backup.display.filter;
  beforeEach(inject(function ($filter) {
    backup.display.filter = $filter('backup.display.filter');
  }));

  it('should return the input prefixed with "backup.display.filter filter:"', function () {
    var text = 'angularjs';
    expect(backup.display.filter(text)).toBe('backup.display.filter filter: ' + text);
  });

});
