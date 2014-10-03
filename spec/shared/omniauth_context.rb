shared_context "omniauth" do
  before do
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:default] 
  end
end
