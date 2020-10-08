import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("ClothingDeals", { loggedIn: true });

test("ClothingDeals works", async assert => {
  await visit("/admin/plugins/clothing-deals");

  assert.ok(false, "it shows the ClothingDeals button");
});
