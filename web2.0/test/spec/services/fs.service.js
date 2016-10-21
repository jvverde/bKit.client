'use strict';

describe('Service: fs.service', function () {

  // load the service's module
  beforeEach(module('bkitApp'));

  // instantiate service
  var fs.service;
  beforeEach(inject(function (_fs.service_) {
    fs.service = _fs.service_;
  }));

  it('should do something', function () {
    expect(!!fs.service).toBe(true);
  });

});
