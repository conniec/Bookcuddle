class UsersController < ApplicationController
  def index
      @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end
  
  def new
    if params[:user]
      @user = User.new(:name => params[:user][:name], :goodreads_id => params[:user][:goodreads_id])
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
end
