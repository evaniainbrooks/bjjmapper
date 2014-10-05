shared_context "omniauth" do
  let(:omniauth_uid) { 'testuid12345' }
  let(:omniauth_provider) { :twitter }
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
      'provider' => omniauth_provider,
      'uid' => omniauth_uid,
      'info' => {
          'name' => 'twitteruser',
          'email' => 'hi@iamatwitteruser.com',
          'nickname' => 'SomeTwitterUser'
      }
    })
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:default]
  end
end
