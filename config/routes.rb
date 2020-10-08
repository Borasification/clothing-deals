require_dependency "clothing_deals_constraint"

ClothingDeal::Engine.routes.draw do
  get "/" => "clothing_deals#index", constraints: ClothingDealConstraint.new
  get "/actions" => "actions#index", constraints: ClothingDealConstraint.new
  get "/actions/:id" => "actions#show", constraints: ClothingDealConstraint.new
end
