require 'goodreads_api'

class DiscussionsController < ApplicationController
  
  def new
    @discussion = Discussion.new
  end

  def create
    puts 'params'
    puts params

    begin
      user_1 = current_user
      #user_1 = User.find_by(goodreads_id: params[:user_1])
      user_2 = User.find_by(goodreads_id: 1234)
    rescue
      flash[:error] = 'User does not exist, please invite them!'
      redirect_to friends_path
    end
    puts 'users!'
    puts user_1.inspect
    puts user_2.inspect

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

      puts @discussion.inspect

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

end
