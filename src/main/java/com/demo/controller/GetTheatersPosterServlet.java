package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.demo.dao.MyConnection;

@WebServlet("/GetTheatersPosterServlet")
public class GetTheatersPosterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("theater_id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing theater_id");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            MyConnection conobj = new MyConnection();
            Connection con = conobj.getConnection();

            PreparedStatement pstm = con.prepareStatement("SELECT image, imgtype FROM theaters WHERE theater_id=?");
            pstm.setInt(1, id);
            ResultSet rs = pstm.executeQuery();

            if (rs.next()) {
                response.setContentType(rs.getString("imgtype"));
                OutputStream out = response.getOutputStream();
                out.write(rs.getBytes("image"));
                out.close();
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
            }

            rs.close();
            pstm.close();
            con.close();

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid theater_id");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
