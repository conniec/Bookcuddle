require_relative '../concerns/goodreads_api.rb'

class UsersController < ApplicationController
  include API

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
    @gr_connection = API::Goodreads.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_url, notice: "Thank you for signing up!"
    else
      render "new"
    end
  end
  
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        redirect_to @user, notice: 'User was successfully updated.'
      else
        render "edit"
      end
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

  def authorized
    puts params
    puts 'yup!'
  end
end
