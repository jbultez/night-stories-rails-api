class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [:login, :register, :google, :refresh]

  # POST /api/v1/auth/login
  def login
    user = User.find_by(email: params[:email])
    
    if user&.valid_password?(params[:password])
      render_auth_success(user)
    else
      render json: { error: 'Invalid credentials' }, status: 401
    end
  end

  # POST /api/v1/auth/register
  def register
    user = User.new(user_params)
    
    if user.save
      render_auth_success(user)
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  # POST /api/v1/auth/google
  def google
    # Le token Google sera envoyé depuis React Native
    google_token = params[:google_token]
    
    begin
      # Vérifier le token Google (vous devrez implémenter cette méthode)
      user_info = verify_google_token(google_token)
      user = User.from_omniauth_info(user_info)
      
      render_auth_success(user)
    rescue => e
      render json: { error: e.message }, status: 401
    end
  end

  # POST /api/v1/auth/refresh
  def refresh
    refresh_token = RefreshToken.find_by(token: params[:refresh_token])
    
    if refresh_token&.active?
      access_token = refresh_token.user.generate_jwt
      render json: { 
        access_token: access_token,
        expires_in: 30.minutes.to_i
      }
    else
      render json: { error: 'Invalid or expired refresh token' }, status: 401
    end
  end

  # DELETE /api/v1/auth/logout
  def logout
    refresh_token = current_user.active_refresh_token
    refresh_token&.revoke!
    
    render json: { message: 'Logged out successfully' }
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name)
  end

  def render_auth_success(user)
    device_info = request.headers['User-Agent'] # ou params[:device_info]
    refresh_token = user.create_refresh_token!(device_info)
    access_token = user.generate_jwt
    
    render json: {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        avatar_url: user.avatar_url
      },
      access_token: access_token,
      refresh_token: refresh_token.token,
      expires_in: 30.minutes.to_i
    }
  end

  def verify_google_token(token)
    # Implémentation de la vérification du token Google
    # Vous pouvez utiliser la gem 'google-id-token' ou faire un appel API
    require 'net/http'
    require 'json'
    
    uri = URI("https://oauth2.googleapis.com/tokeninfo?id_token=#{token}")
    response = Net::HTTP.get_response(uri)
    
    if response.code == '200'
      JSON.parse(response.body)
    else
      raise "Invalid token"
    end
  end
end