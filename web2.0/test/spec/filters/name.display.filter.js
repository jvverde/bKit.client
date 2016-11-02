'use strict';

describe('Filter: name.display.filter', function () {

  // load the filter's module
  beforeEach(module('bkitApp'));

  // initialize a new instance of the filter before each test
  var name.display.filter;
  beforeEach(inject(function ($filter) {
    name.display.filter = $filter('name.display.filter');
  }));

  it('should return the input prefixed with "name.display.filter filter:"', function () {
    var text = 'angularjs';
    expect(name.display.filter(text)).toBe('name.display.filter filter: ' + text);
  });

});
