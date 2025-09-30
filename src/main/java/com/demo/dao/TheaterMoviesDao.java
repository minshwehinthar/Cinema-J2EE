package com.demo.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;


import com.demo.model.Movies;
import com.demo.model.Theater;

public class TheaterMoviesDao {
	
	public int addMovieToTheater(int theaterId, int movieId, String startDate, String endDate) {
        int row = 0;
        MyConnection conObj = new MyConnection();
	    Connection con = conObj.getConnection();
	    	PreparedStatement pstm;
			try {
				pstm = con.prepareStatement("insert into theater_movies (theater_id, movie_id, start_date, end_date) " +
				             "values (?, ?, ?, ?)");
				pstm.setInt(1, theaterId);
	            pstm.setInt(2, movieId);
	            pstm.setString(3, startDate);
	            pstm.setString(4, endDate);
	            row = pstm.executeUpdate();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            
        
        return row;
    }

	public ArrayList<Movies> getAvailableMoviesForTheater(int theaterId) {
	    ArrayList<Movies> list = new ArrayList<>();
	    MyConnection conObj = new MyConnection();
	    Connection con = conObj.getConnection();
			try {
				PreparedStatement pstm = con.prepareStatement(
				    "select * from movies m where not exists (" +
				    "select 1 from theater_movies tm where tm.movie_id = m.movie_id and tm.theater_id = ?)");
				pstm.setInt(1, theaterId);
		        ResultSet rs = pstm.executeQuery();
		        while(rs.next()){
		            Movies m = new Movies();
		            m.setMovie_id(rs.getInt("movie_id"));
		            m.setTitle(rs.getString("title"));
		            m.setStatus(rs.getString("status"));
		            list.add(m);
		        }
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	        
	    
	    return list;
	}
	
	public ArrayList<Theater> getTheatersByMovie(int movieId) {
	    ArrayList<Theater> list = new ArrayList<>();
	    MyConnection conObj = new MyConnection();
	    Connection con = conObj.getConnection();
	    
	    try {
	        PreparedStatement pstm = con.prepareStatement(
	            "SELECT t.* FROM theaters t " +
	            "JOIN theater_movies tm ON t.theater_id = tm.theater_id " +
	            "WHERE tm.movie_id = ?"
	        );
	        pstm.setInt(1, movieId);
	        ResultSet rs = pstm.executeQuery();
	        
	        while(rs.next()) {
	            Theater t = new Theater();
	            t.setTheaterId(rs.getInt("theater_id"));
	            t.setName(rs.getString("name"));
	            t.setLocation(rs.getString("location"));
	            list.add(t);
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    
	    return list;
	}
	
	
	public ArrayList<Movies> getMoviesPickedByTheaters() {
	    ArrayList<Movies> list = new ArrayList<>();
	    MyConnection conObj = new MyConnection();
	    Connection con = conObj.getConnection();

	    try {
	        PreparedStatement pstm = con.prepareStatement(
	            "SELECT DISTINCT m.* FROM movies m " +
	            "INNER JOIN theater_movies tm ON m.movie_id = tm.movie_id"
	        );
	        ResultSet rs = pstm.executeQuery();
	        while(rs.next()){
	            Movies m = new Movies();
	            m.setMovie_id(rs.getInt("movie_id"));
	            m.setTitle(rs.getString("title"));
	            m.setStatus(rs.getString("status"));
	            list.add(m);
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }

	    return list;
	}


	
}
