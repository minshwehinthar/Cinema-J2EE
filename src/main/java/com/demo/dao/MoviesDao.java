package com.demo.dao;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import com.demo.model.Movies;


import jakarta.servlet.http.Part;

public class MoviesDao {

	public int addMovies(String title, String status, String duration, String director, String casts, String genres,String synopsis,Part posterPart,Part trailerPart) throws IOException {
		int row =0;
		MyConnection conObj = new MyConnection();
		Connection con= conObj.getConnection();
		InputStream posterStream = null;
		InputStream trailerStream = null;
		if(posterPart !=null )
			posterStream = posterPart.getInputStream();
		if(trailerPart !=null)
			trailerStream = trailerPart.getInputStream();
		
		try {
			PreparedStatement pstm = con.prepareStatement
("insert into movies (title,status,duration,director,casts,genres,synopsis,poster,trailer,postertype,trailertype) values(?,?,?,?,?,?,?,?,?,?,?)");
			pstm.setString(1, title);
			pstm.setString(2, status);
			pstm.setString(3, duration);
			pstm.setString(4, director);
			pstm.setString(5, casts);
			pstm.setString(6, genres);
			pstm.setString(7, synopsis);
			pstm.setBlob(8, posterStream);
			pstm.setBlob(9, trailerStream);
			pstm.setString(10, posterPart.getContentType());
			pstm.setString(11, trailerPart.getContentType());
			row = pstm.executeUpdate();
			
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
		return row;
	}
	
	
	public ArrayList<Movies> getAllMovies(){
		ArrayList<Movies> list = new ArrayList<Movies>();
		MyConnection conobj = new MyConnection();
		Connection con = conobj.getConnection();
		try {
			PreparedStatement pstm = con.prepareStatement("select * from movies");
			ResultSet rs= pstm.executeQuery();
			while(rs.next()) {
				Movies m = new Movies();
				m.setMovie_id(rs.getInt(1));
				m.setTitle(rs.getString(2));
				m.setStatus(rs.getString(3));
				m.setDuration(rs.getString(4));
				m.setDirector(rs.getString(5));
				m.setCasts(rs.getString(6));
				m.setGenres(rs.getString(7));
				m.setSynopsis(rs.getString(8));
				m.setPostertype(rs.getString(11));
				m.setTrailertype(rs.getString(12));
				list.add(m);
			}
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return list;
	}
	
	public Movies getMovieById(int movie_id) {
		Movies mov = new Movies();
	    MyConnection conobj = new MyConnection();
		Connection con = conobj.getConnection();
		PreparedStatement pstm;
		try {
			pstm = con.prepareStatement("select * from movies where movie_id=?");
			pstm.setInt(1, movie_id);
		    ResultSet rs = pstm.executeQuery();
		        if (rs.next()) {
		        	Movies m = new Movies();
					m.setMovie_id(rs.getInt(1));
					m.setTitle(rs.getString(2));
					m.setStatus(rs.getString(3));
					m.setDuration(rs.getString(4));
					m.setDirector(rs.getString(5));
					m.setCasts(rs.getString(6));
					m.setGenres(rs.getString(7));
					m.setSynopsis(rs.getString(8));
					m.setPostertype(rs.getString(11));
					m.setTrailertype(rs.getString(12));
					mov = m;
		        }
		    
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	    
	    return mov;
	}


	
}
