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
      
      user = @gr_connection.get_user_by_goodreads(@access_token.token, @access_token.secret)
      if user.new_record?
        user.save
        #login_user(user.id)
        redirect_to signup_path
      else
        #login_user(user.id)
        redirect_to users_path
      end
    else
      flash[:notice] = "Did not authorize properly. Please try again."
      redirect_to signup_path
    end
  end

  def login_user(user_id)
    session[:user_id] = user_id
  end

  private
    def create_connection
      @gr_connection = API::Goodreads.new
    end
end
