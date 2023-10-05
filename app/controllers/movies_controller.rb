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
    if params.has_key?(:ratings)
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = @ratings_to_show
    else
      if params.has_key?(:refresh)
        session[:ratings] = @all_ratings
      end
    end

    if params.has_key?(:sort)
      session[:sort] = params[:sort]
    end

    if !session.has_key?(:ratings) 
      @all_ratings_hash = Hash[@all_ratings.collect {|x| [x, '1']}]
      session[:ratings] = @all_ratings
      redirect_to movies_path(:ratings => @all_ratings_hash, :sort => session.has_key?(:sort) ? session[:sort] : '') and return
    end

    if !session.has_key?(:sort)
      session[:sort] = ''
      @ratings_hash = Hash[session[:ratings].collect {|x| [x, '1']}]
      redirect_to movies_path(:ratings => @ratings_hash, :sort => '') and return
    end

    if !params.has_key?(:ratings) || !params.has_key?(:sort)
      redirect_to movies_path(:ratings => Hash[session[:ratings].collect {|x| [x, '1']}], :sort => session[:sort]) and return
    end

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

end
