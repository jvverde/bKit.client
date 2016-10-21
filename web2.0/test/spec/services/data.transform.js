'use strict';

describe('Service: data.transform', function () {

  // load the service's module
  beforeEach(module('bkitApp'));

  // instantiate service
  var data.transform;
  beforeEach(inject(function (_data.transform_) {
    data.transform = _data.transform_;
  }));

  it('should do something', function () {
    expect(!!data.transform).toBe(true);
  });

});
