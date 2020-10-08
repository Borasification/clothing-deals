require 'rails_helper'

describe ClothingDeals::ActionsController do
  before do
    Jobs.run_immediately!
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/clothing-deals/list.json"
    expect(response.status).to eq(200)
  end
end
