'use strict';

describe('Directive: mouse.hold', function () {

  // load the directive's module
  beforeEach(module('bkitApp'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<mouse.hold></mouse.hold>');
    element = $compile(element)(scope);
    expect(element.text()).toBe('this is the mouse.hold directive');
  }));
});
