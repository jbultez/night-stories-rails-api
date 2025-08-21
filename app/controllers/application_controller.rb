class ApplicationController < ActionController::API
  before_action :authenticate_request
  
  private

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    if header
      decoded = JwtService.decode(header)
      @current_user = User.find(decoded[:user_id]) if decoded
    end
    
    render json: { error: 'Unauthorized' }, status: 401 unless @current_user
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Unauthorized' }, status: 401
  end

  def current_user
    @current_user
  end

  # Skip authentication for specific actions
  def skip_authentication
    # Utilisez skip_before_action :authenticate_request dans les controllers qui en ont besoin
  end
end