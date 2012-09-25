require 'goodreads_api'

class DiscussionsController < ApplicationController
  include API

  before_filter :create_connection, :only => [:show]
  
  def new
    @discussion = Discussion.new
  end

  def show
    @discussion = Discussion.find(params[:id])
    @user_1 = @discussion.users[0]
    @user_2 = @discussion.users[1]
    @book_id = @discussion.book_id
    @book_name = @discussion.book_name

    @status_1 = @gr_connection.get_user_book_status(@user_1.goodreads_id, @book_id)
    @status_2 = @gr_connection.get_user_book_status(@user_2.goodreads_id, @book_id)
    puts @status_1
    puts @status_2
  end

  def create

    begin
      user_1 = current_user
      user_2 = User.find_by(goodreads_id: params[:user_2].to_i)
    rescue
      flash[:error] = 'User does not exist, please invite them!'
      redirect_to friends_path
    end

    begin
      @discussion = Discussion.find_by(user_1: user_1.id, user_2: user_2.id, book_id: params[:book_id])
      puts 'discussion found!'
    rescue
      puts 'no discussion found'
      @discussion = Discussion.new

      @discussion.users.push(user_1)
      @discussion.users.push(user_2)
      @discussion.user_1 = user_1.id
      @discussion.user_2 = user_2.id

      # begin
      #   book = Book.find_by(goodreads_id: params[:book_id])
      # rescue
      #   flash[:error] = 'Book does not exist'
      #   redirect_to friends_path
      # end

      @discussion.book_id = params[:book_id]
      # @discussion.book_name = book.name
      # @discussion.book = book
      @discussion.save

    end
    redirect_to show_discussion_path(@discussion.id)
  end

  # def edit
  #   @discussion = Discussion.find(params[:id])
  # end

  # def update
  # end

  def destroy
    @discussion = Discussion.find(params[:id])
    if @discussion.destroy
      redirect_to discussions_url
    else
      render "show"
    end
  end

  private
    def create_connection
      @gr_connection = API::Goodreads.new(session[:access_token], session[:access_token_secret])
    end
end
