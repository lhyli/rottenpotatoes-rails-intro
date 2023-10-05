class MoviesController < ApplicationController
  
  @title_class = ''
  @rdate_class = ''
  @ratings_to_show_hash = {}
  
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    if !params[:ratings]
      @all_ratings_hash = Hash[@all_ratings.collect {|x| [x, '1']}]
      redirect_to movies_path(:ratings => @all_ratings_hash) and return
    end

    @ratings_to_show = params[:ratings].keys
    @ratings_to_show_hash = Hash[@ratings_to_show.collect {|x| [x, '1']}]

    @movies = Movie.with_ratings(@ratings_to_show)

    case params[:sort]
    when "by_title"
      @movies = @movies.order(:title)
      @title_class = 'hilite bg-warning'
      @rdate_class = ''
      session[:sort] = params[:sort]
    when "by_rdate"
      @movies = @movies.order(:release_date)
      @title_class = ''
      @rdate_class = 'hilite bg-warning'
      session[:sort] = params[:sort]
    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
  

  def get_ratings_to_show_hash
    @ratings_to_show_hash = {}
    @ratings_to_show.each { |x| @ratings_to_show_hash[x] = '1' }
    return @ratings_to_show_hash
  end

end
