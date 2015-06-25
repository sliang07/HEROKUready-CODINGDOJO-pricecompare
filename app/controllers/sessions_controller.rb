class SessionsController < ApplicationController
	def new
	end

	def create
		# this is how to var dump/die: render :html => "abc"
		user = User.authenticate(params[:session][:email], params[:session][:password])
 		if user.nil?
			flash[:error] = "Invalid email/password combination!"
			redirect_to new_session_path
		else
			sign_in user
			redirect_to new_main_path
		end
	end
	def destroy
		sign_out
		redirect_to root_path
	end
end
