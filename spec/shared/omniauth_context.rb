shared_context "omniauth success" do
  let(:omniauth_uid) { 'test12345' }
  let(:omniauth_provider) { :twitter }
  let(:omniauth_name) { 'twitteruser' }
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
      'provider' => omniauth_provider,
      'uid' => omniauth_uid,
      'info' => {
          'name' => omniauth_name,
          'email' => 'hi@iamatwitteruser.com',
          'nickname' => 'SomeTwitterUser'
      }
    })
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:default] if defined?(request)
  end
end
shared_context "omniauth failure" do
  let(:omniauth_error) { :invalid_credentials }
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:default] = omniauth_error 
    OmniAuth.config.on_failure = Proc.new do |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    end
    
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:default] if defined?(request)
  end
end
