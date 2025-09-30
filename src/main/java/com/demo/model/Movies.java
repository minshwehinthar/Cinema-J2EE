package com.demo.model;

public class Movies {
	int movie_id;
	String title;
	String status;
	String duration;
	String director;
	String casts;
	String genres;
	String synopsis;
	String postertype;
	String trailertype;
	
	public Movies() {}

	public int getMovie_id() {
		return movie_id;
	}

	public void setMovie_id(int movie_id) {
		this.movie_id = movie_id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getDuration() {
		return duration;
	}

	public void setDuration(String duration) {
		this.duration = duration;
	}

	public String getDirector() {
		return director;
	}

	public void setDirector(String director) {
		this.director = director;
	}

	public String getCasts() {
		return casts;
	}

	public void setCasts(String casts) {
		this.casts = casts;
	}

	public String getGenres() {
		return genres;
	}

	public void setGenres(String genres) {
		this.genres = genres;
	}

	public String getSynopsis() {
		return synopsis;
	}

	public void setSynopsis(String synopsis) {
		this.synopsis = synopsis;
	}

	public String getPostertype() {
		return postertype;
	}

	public void setPostertype(String postertype) {
		this.postertype = postertype;
	}

	public String getTrailertype() {
		return trailertype;
	}

	public void setTrailertype(String trailertype) {
		this.trailertype = trailertype;
	}
	
	
}
