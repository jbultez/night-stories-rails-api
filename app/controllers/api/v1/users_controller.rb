class Api::V1::UsersController < ApplicationController
  # GET /api/v1/users/me
  def show
    render json: {
      user: {
        id: current_user.id,
        email: current_user.email,
        name: current_user.name,
        avatar_url: current_user.avatar_url
      }
    }
  end

  # PUT /api/v1/users/me
  def update
    if current_user.update(user_update_params)
      render json: { user: current_user }
    else
      render json: { errors: current_user.errors }, status: 422
    end
  end

  private

  def user_update_params
    params.require(:user).permit(:name, :email)
  end
end