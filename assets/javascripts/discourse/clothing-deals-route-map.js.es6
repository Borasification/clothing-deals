export default function() {
  this.route("clothing-deals", function() {
    this.route("actions", function() {
      this.route("show", { path: "/:id" });
    });
  });
};
