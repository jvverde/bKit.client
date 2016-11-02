'use strict';

describe('Service: error.logger', function () {

  // load the service's module
  beforeEach(module('bkitApp'));

  // instantiate service
  var error.logger;
  beforeEach(inject(function (_error.logger_) {
    error.logger = _error.logger_;
  }));

  it('should do something', function () {
    expect(!!error.logger).toBe(true);
  });

});
