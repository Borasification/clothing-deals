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

    const casualSizes = [
      { name: "XXS", id: "XXS" },
      { name: "XS", id: "XS" },
      { name: "S", id: "S" },
      { name: "M", id: "M" },
      { name: "L", id: "L" },
      { name: "XL", id: "XL" },
      { name: "2XL", id: "2XL" },
      { name: "3XL", id: "3XL" },
      { name: "4XL", id: "4XL" },
      { name: "5XL", id: "5XL" },
    ];

    this.sizeOuterwearOptions = range(42, 66, 2)
      .reduce((acc, value) => {
        return [...acc, { name: value.toString(), id: value }];
      }, [])
      .concat(casualSizes);

    this.sizeTopOptions = range(42, 66, 2)
      .reduce((acc, value) => {
        return [...acc, { name: value.toString(), id: value }];
      }, [])
      .concat(casualSizes);

    this.sizeKnitwearOptions = range(42, 66, 2)
      .reduce((acc, value) => {
        return [...acc, { name: value.toString(), id: value }];
      }, [])
      .concat(casualSizes);

    this.sizeTShirtOptions = casualSizes;

    this.sizeSweatshirtOptions = casualSizes;

    this.sizeShirtOptions = range(36, 48, 1)
      .reduce((acc, value) => {
        return [...acc, { name: value.toString(), id: value }];
      }, [])
      .concat(casualSizes);

    this.sizeShoesOptions = range(35, 50, 0.5).reduce((acc, value) => {
      return [...acc, { name: value.toString(), id: value }];
    }, []);

    this.sizeGlovesOptions = range(6, 12, 0.5)
      .reduce((acc, value) => {
        return [...acc, { name: value.toString(), id: value }];
      }, [])
      .concat(casualSizes);

    this.sizeJeansOptions = range(26, 44, 1).reduce((acc, value) => {
      return [...acc, { name: value.toString(), id: value }];
    }, []);

    this.sizeHatOptions = range(52, 63, 1)
      .reduce((acc, value) => {
        return [...acc, { name: value.toString(), id: value }];
      }, [])
      .concat(casualSizes)
      .concat([{ name: "OS", id: "OS" }]);
  },
});
