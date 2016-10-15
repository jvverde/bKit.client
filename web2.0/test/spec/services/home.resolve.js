'use strict';

describe('Service: home.resolve', function () {

  // load the service's module
  beforeEach(module('bkitApp'));

  // instantiate service
  var home.resolve;
  beforeEach(inject(function (_home.resolve_) {
    home.resolve = _home.resolve_;
  }));

  it('should do something', function () {
    expect(!!home.resolve).toBe(true);
  });

});
