class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :refresh_tokens, dependent: :destroy
  has_one :active_refresh_token, -> { where(revoked: false) }, 
          class_name: 'RefreshToken'

  validates :email, presence: true, uniqueness: true

  # Pour l'authentification Google
  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.avatar_url = auth.info.image
      user.provider = auth.provider
      user.uid = auth.uid
    end
  end

  def create_refresh_token!(device_info = nil)
    # Révoquer tous les anciens refresh tokens (un seul appareil)
    refresh_tokens.update_all(revoked: true)
    
    # Créer le nouveau
    refresh_tokens.create!(
      token: SecureRandom.hex(32),
      expires_at: 6.months.from_now,
      device_info: device_info
    )
  end

  def generate_jwt
    JwtService.encode(user_id: id)
  end
end