class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      session[:sort_key] = params[:sort_key] if params[:sort_key]
      session[:ratings] = params[:ratings] if params[:ratings] 

      if (!params[:sort_key] && !params[:ratings]) && (session[:sort_key] && session[:ratings])
        flash.keep
        return redirect_to movies_path(sort_key: session[:sort_key], ratings: session[:ratings])
      elsif !params[:sort_key] && session[:sort_key]
        flash.keep
        return redirect_to movies_path(sort_key: session[:sort_key], ratings: params[:ratings])
      elsif !params[:ratings] && session[:ratings]
        flash.keep
        return redirect_to movies_path(sort_key: params[:sort_key], ratings: session[:ratings])
      end

      @all_ratings = Movie.all_ratings
      if params[:ratings]
        @ratings_to_show = params[:ratings].keys
        @movies = Movie.where(rating: @ratings_to_show)
      else
        @ratings_to_show = Hash[@all_ratings.collect {|key| [key, '1']}]
        @movies = Movie.all
      end

      if params[:sort_key] 
        @movies = @movies.order(params[:sort_key]) 
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