class GoogleTokenVerifier
  require 'google-id-token'

  def self.verify(token)
    begin
      # Vérifier le token avec Google
      validator = GoogleIDToken::Validator.new
      payload = validator.check(token, ENV['GOOGLE_CLIENT_ID'])
      
      if payload
        payload
      else
        raise 'Invalid Google token'
      end
    rescue => e
      Rails.logger.error "Google token verification failed: #{e.message}"
      nil
    end
  end
end