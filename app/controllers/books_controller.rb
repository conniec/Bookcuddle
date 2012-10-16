require 'goodreads_api'

class BooksController < ApplicationController
  include API

  before_filter :create_connection, :only => [:show, :create]

  def create
    #Get the book info from Goodreads
    puts 'creating a book!'
    book_id = params[:id]
    book_info = @gr_connection.get_book_info(book_id)

    return false if book_info == {}
    
    #Create a book in model
    @book = Book.new(book_info)
    @book.goodreads_id = book_id
    @book.save
    respond_to do |format|
      format.json {
        render :json => @book.to_json
    }
    end
  end

  def show
    begin
      @book = Book.find_by(:goodreads_id => params[:id].to_i)
    rescue
      @book = @gr_connection.get_book_info(params[:id])
    end
    
    respond_to do |format|
      format.html {
        render :layout => false, :partial => 'show'
      }
    end
  end

  private
    def create_connection
      @gr_connection = API::Goodreads.new(session[:access_token], session[:access_token_secret])
    end
end
