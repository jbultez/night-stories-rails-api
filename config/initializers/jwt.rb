class JwtService
  SECRET_KEY = ENV['JWT_SECRET']

  def self.encode(payload, exp = 30.minutes.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    nil
  end
end