require 'goodreads_api'

class SessionsController < ApplicationController
  include API

  before_filter :create_connection, :only => [:create, :authorized]
  
  def new
  end

  def create
    session[:request_token] = @gr_connection.get_request_token
    redirect_to @gr_connection.authorize_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end

  def authorized
    if params[:authorize] == '1'
      @request_token = session[:request_token]
      @access_token = @request_token.get_access_token
      
      session[:access_token] = @access_token.token
      session[:access_token_secret] = @access_token.secret
      
      user_info = @gr_connection.get_auth_user_goodreads(@access_token.token, @access_token.secret)

      #If unable to fetch user_info from Goodreads API, try again
      if user_info.empty?
        flash[:error] = "Error authorizing account, please try again."
        redirect_to signup_path
      end

      #Try to fetch the existing user or prompt to create new
      begin
        @user = User.find_by(goodreads_id: user_info[:goodreads_id])
        login_user(@user.id)
        flash[:success] = "You have logged in successfully."
        redirect_to @user
      rescue
        redirect_to signup_path(:user => user_info)
      end
    else
      flash[:notice] = "Did not authorize properly. Please try again."
      redirect_to signup_path
    end
  end

  private
    def login_user(user_id)
      session[:user_id] = user_id
    end
  
    def create_connection
      @gr_connection = API::Goodreads.new
    end
end
