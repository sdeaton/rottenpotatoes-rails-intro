class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.uniq.pluck(:rating) #get all possible values for movie ratings
    # Initially sort by title
    session[:sortedby] ||= 'title'
    # Use all ratings initially, otherwise use the selected
    session[:selected_ratings] ||= @all_ratings
    session[:selected_ratings] = params[:ratings] ? params[:ratings].keys : session[:selected_ratings]
    # for use in checking the correct boxes - all checked initially
    session[:ratings_boxes] ||= Hash[@all_ratings.map {|tmp| [tmp, true]}]
    session[:ratings_boxes] = params[:ratings] ? params[:ratings] : session[:ratings_boxes]
    # sort by a selected column and highlight the heading
    session[:sortedby] = params[:sortedby] ? params[:sortedby] : session[:sortedby]
    # maintain the proper URI if any parameters are not specified (and flash message)
    flash.keep if (params[:sortedby] == nil) or (params[:ratings] == nil)
    redirect_to movies_path(:sortedby => session[:sortedby], :ratings => session[:ratings_boxes]) if 
       (params[:sortedby] == nil) or (params[:ratings] == nil)
    @hl_title = session[:sortedby] == 'title' ? 'hilite' : "" #highlight if sorting by title
    @hl_date = session[:sortedby] == 'release_date' ? 'hilite' : "" #highlight if sorting by date
    @movies = Movie.where(rating: session[:selected_ratings]).order(session[:sortedby])
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

end
