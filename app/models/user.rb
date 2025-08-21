class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :refresh_tokens, dependent: :destroy
  has_one :active_refresh_token, -> { where(revoked: false) }, 
          class_name: 'RefreshToken'

  validates :email, presence: true, uniqueness: true

  # Méthode pour créer un utilisateur depuis Google
  def self.from_google_token(google_payload)
    email = google_payload['email']
    
    # Chercher ou créer l'utilisateur
    user = find_or_initialize_by(email: email)
    
    if user.new_record?
      user.assign_attributes(
        name: google_payload['name'],
        avatar_url: google_payload['picture'],
        provider: 'google',
        uid: google_payload['sub'],
        password: Devise.friendly_token[0, 20] # Mot de passe aléatoire
      )
      user.save!
    else
      # Mettre à jour les infos Google si l'utilisateur existe déjà
      user.update!(
        name: google_payload['name'] || user.name,
        avatar_url: google_payload['picture'] || user.avatar_url,
        provider: 'google',
        uid: google_payload['sub']
      )
    end
    
    user
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