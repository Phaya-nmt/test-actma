class SessionsController < ApplicationController
  skip_before_action :ensure_authenticated_user, only: %i( new create )

  def new
    @users = User.all
  end

  def create
    user = User.find_by(name: params[:name])
    if user and user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to admin_url
    else
      redirect_to admin_url, alert: "無効なユーザ・パスワードの組み合わせです"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to store_url, notice: "ログアウト"
  end
end

# class SessionsController < ApplicationController
#   skip_before_action :authorize
#   def new
#   end

#   def create
#     user = User.find_by(name: params[:name])
#     if user and user.authenticate(params[:password])
#       session[:user_id] = user.id
#       redirect_to admin_url
#     else
#       redirect_to admin_url, alert: "無効なユーザ・パスワードの組み合わせです"
#     end
#   end

#   def destroy
#     session[:user_id] = nil
#     redirect_to store_url, notice: "ログアウト"
#   end
# end
