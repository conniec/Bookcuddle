require 'goodreads_api'

class DiscussionsController < ApplicationController
  include API

  before_filter :create_connection, :only => [:show]
  
  def index
    id = current_user.id
    @user = User.find_by(id: id)
    @discussions = @user.discussions
  end

  def new
    @discussion = Discussion.new
  end

  def quote
    if request.xhr?
      begin
        #Start posting quote to Goodreads
        puts 'posting quote!!'
      rescue
      end
    end
  end

  def show
    if request.xhr?
      begin
        puts 'looking for book'
        current_user_id = current_user.id.to_s
        friend_id = User.find_by(:goodreads_id => params[:friend_id]).id
        book_id = params[:id]
        users = [current_user_id, friend_id]
        discussion_id = Discussion.where(:book_goodreads_id => book_id, 
                                         :user_1.in => users,
                                         :user_2.in => users).first.id
        puts 'found discussion'
        @discussion = { :discussion_id => discussion_id }
      rescue
        puts 'did not discussion'
        @discussion = { :discussion_id => nil }
      end
    else
      puts 'show discussion'
      @discussion = Discussion.find(params[:id])
      puts '*' * 50
      puts @discussion.inspect
      @user_1 = @discussion.users[0]
      @user_2 = @discussion.users[1]
      @book_id = @discussion.book_goodreads_id

      @status_1 = @gr_connection.get_user_book_status(@user_1.goodreads_id, @book_id)
      @status_2 = @gr_connection.get_user_book_status(@user_2.goodreads_id, @book_id)
      puts @status_1
      puts @status_2
    end
    respond_to do |format|
      format.html
      format.json {
        render :json => @discussion.to_json
      }
    end
  end

  def create
    begin
      user_1 = current_user
      user_2 = User.find_by(goodreads_id: params[:user_2].to_i)
    rescue
      flash[:error] = 'User does not exist, please invite them!'
      redirect_to friends_path
    end
    @discussion = Discussion.new
    
    @discussion.users.push(user_1)
    @discussion.users.push(user_2)
    @discussion.user_1 = user_1.id
    @discussion.user_2 = user_2.id
    @discussion.user_1_name = user_1.name
    @discussion.user_2_name = user_2.name
    @discussion.book_goodreads_id = params[:book_id]
    @discussion.book_name = params[:book_name]

    book = Book.find_or_create_by_goodreads(session[:access_token], session[:access_token_secret], params[:book_id])
    @discussion.book = book
    
    if @discussion.save
      flash[:success] = "New discussion created!"
      redirect_to discussion_path(@discussion)
    else
      flash.now[:notice] = "Try again."
      redirect_to friends_path
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

  private
    def create_connection
      @gr_connection = API::Goodreads.new(session[:access_token], session[:access_token_secret])
    end
end
