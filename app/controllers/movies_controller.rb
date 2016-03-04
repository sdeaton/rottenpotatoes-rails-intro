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
    # if nothing is selected, use all ratings, otherwise use the selected
    selected_ratings = params[:ratings] ? params[:ratings].keys : @all_ratings
    # for use in checking the correct boxes - all checked initially
    @ratings_hash = params[:ratings] ? params[:ratings] : Hash.new(true)
    # sort by a selected column and highlight the heading
    sortedby = params[:sortedby]
    @hl_title = sortedby == 'title' ? 'hilite' : "" #highlight if sorting by title
    @hl_date = sortedby == 'release_date' ? 'hilite' : "" #highlight if sorting by date
    @movies = Movie.where(rating: selected_ratings).order(sortedby)
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
