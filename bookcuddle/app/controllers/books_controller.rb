require 'goodreads_api'

class BooksController < ApplicationController
  include API

  before_filter :create_connection, :only => [:show]

  def create
    #Get the book info from Goodreads
    puts 'creating a book!'
    book_id = params[:id]
    @gr_connection = API::Goodreads.new(session[:access_token], session[:access_token_secret])
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
  
  def add_quote
    book_goodreads_id = params[:book_id]
    body = params[:body]

    begin
      book = Book.find_by(:goodreads_id => book_goodreads_id)
    rescue
      puts 'book does not exist'
    end

    #Start creating params
    quote_params = {}
    quote_params[:author_name] = book.get_author['name']
    quote_params[:author_id] = book.get_author['id']
    quote_params[:body] = body
    quote_params[:book_id] = book_goodreads_id
    puts quote_params

    @gr_connection = API::Goodreads.new(session[:access_token], session[:access_token_secret])
    @gr_connection.add_quote(quote_params)

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
