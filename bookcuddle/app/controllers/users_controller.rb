require 'goodreads_api'

class UsersController < ApplicationController
  include API
  
  before_filter :authorize, :only => [:friends, :compare]
  before_filter :create_connection, :only => [:friends, :compare]
  
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end
  
  def new
    if params[:user]
      @user = User.new(:name => params[:user][:goodreads_name], :goodreads_id => params[:user][:goodreads_id])
    else
      @user = User.new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to @user, notice: "Thank you for signing up!"
    else
      render "new"
    end
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      redirect_to users_url
    else
      render "show"
    end
  end
  
  def friends
    @user = current_user
    @friends = @gr_connection.get_user_friends(current_user.goodreads_id.to_s)
    puts @friends
  end
  
  def compare
    @user = current_user
    @comparison = @gr_connection.get_unread_books(params[:friend_goodreads_id])
  end
  
  private
    def create_connection
      @gr_connection = API::Goodreads.new(session[:access_token], session[:access_token_secret])
    end
end
