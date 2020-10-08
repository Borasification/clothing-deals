class ClothingDealConstraint
  def matches?(request)
    SiteSetting.clothing_deals_enabled
  end
end
