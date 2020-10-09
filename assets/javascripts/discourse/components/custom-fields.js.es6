function range(start, stop, step = 1) {
  if (typeof stop == "undefined") {
    // one param defined
    stop = start;
    start = 0;
  }

  if ((step > 0 && start >= stop) || (step < 0 && start <= stop)) {
    return [];
  }

  let result = [];
  for (let i = start; step > 0 ? i < stop : i > stop; i += step) {
    result.push(i);
  }

  return result;
}

export default Ember.Component.extend({
  init() {
    this._super(...arguments);

    this.sizeTopOptions = range(42, 66, 2).reduce((acc, value) => {
      return [...acc, { name: value.toString(), id: value }];
    }, []);

    this.sizeShirtOptions = range(36, 48, 1).reduce((acc, value) => {
      return [...acc, { name: value.toString(), id: value }];
    }, []);

    this.sizeShoesOptions = range(35, 50, 0.5).reduce((acc, value) => {
      return [...acc, { name: value.toString(), id: value }];
    }, []);

    this.sizeGlovesOptions = range(6, 12, 0.5).reduce((acc, value) => {
      return [...acc, { name: value.toString(), id: value }];
    }, []);

    this.sizeHatOptions = range(52, 63, 1).reduce((acc, value) => {
      return [...acc, { name: value.toString(), id: value }];
    }, []);
  },
});
