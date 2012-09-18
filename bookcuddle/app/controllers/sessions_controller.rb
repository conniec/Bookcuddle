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
      session[:access_token_token] = @access_token.token
      session[:access_token_secret] = @access_token.secret
      
      @gr_connection.auth_user(@access_token.token, @access_token.secret)
      redirect_to users_path
    else
      flash[:notice] = "Did not authorize properly. Please try again."
      redirect_to signup_path
    end
  end

  private
    def create_connection
      @gr_connection = API::Goodreads.new
    end
end
