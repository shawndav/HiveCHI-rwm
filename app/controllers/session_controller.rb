class SessionController < ApplicationController
  def new
    @user = User.new
    render '_login'
  end

  def create
    puts "WORD"
    @user = User.find_by(email: params[:user][:email])
    if @user && @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id
      redirect_to dashboard_path
    else
      @errors = ["Invalid email or password"]
      redirect_to login_path
    end
  end

  def destroy
    session.clear
    redirect_to '/'
  end

  private
    def user_params
     params.require(:user).permit(:email, :password)
    end
end
