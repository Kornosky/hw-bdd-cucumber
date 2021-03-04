class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  #@ vars (instance variables) are automatically shared with the associated view (in this case index.html.erb)

 #Index method to retrieve correct sorting information
  def index
    if request.path == '/' #For a default path
      reset_session
    end
    
    #########---------------- Figuring out what to sort -------------------############
    @ratings_to_show =!session[:ratings_to_show].nil? ? session[:ratings_to_show]:[]
    
    if !session[:sort_by].nil? #sort by rating
      if !params[:sort].nil? and params[:sort] != session[:sort_by] #If the params are changed then update the session's.
        session[:sort_by] = params[:sort]
      end
      @sort = session[:sort_by]
    else #sort columns
      @sort = params[:sort] 
    end
    
    #Handle when user leaves all empty and presses refresh
    if !params[:ratings].nil?
      @ratings_to_show = params[:ratings].keys
      session[:ratings_to_show] = @ratings_to_show #record
    else
       @ratings_to_show = []
      session[:ratings_to_show] = @ratings_to_show #record
    end
    
    @movies = Movie.with_ratings(@ratings_to_show)
    
    @all_ratings = Movie.distinct.pluck(:rating).sort
   
   #########---------------- Sorting  -------------------###########

    if @sort
      
      #Sort movies
      if @sort != session[:sort_by]
        @movies = @movies.order(@sort)
      else
        @movies = @movies.order(@sort).reverse
      end
      #Change css for column headers
      case @sort
      when "title"
        @title_header = 'bg-warning'    
        @title_header = 'hilite'        
      when "release_date"
        @release_date_header = 'bg-warning'
        @release_date_header = 'hilite'
      end
    end
    
     # Records the current sort information to the sessions hash
    session[:sort_by] = @sort  
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