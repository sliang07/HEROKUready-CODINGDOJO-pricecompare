class UsersController < ApplicationController
	def index
	end
	def new
		@user = User.new
	end
	def create
		@user = User.new(user_params)
		if @user.save
			sign_in @user
			redirect_to new_main_path
		else
			flash[:error] = @user.errors.full_messages
			redirect_to new_user_path
		end
	end
	private
	def user_params
		params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
	end
end
