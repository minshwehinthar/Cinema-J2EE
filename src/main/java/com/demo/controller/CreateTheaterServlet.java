package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.util.Base64;

import com.demo.dao.MyConnection;
import com.demo.dao.TheaterDAO;
import com.demo.model.Theater;

@WebServlet("/CreateTheaterServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class CreateTheaterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try (Connection con = MyConnection.getConnection()) {

            // ===== 1️⃣ Create Admin User =====
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String password = request.getParameter("password");

            Part adminImagePart = request.getPart("admin_image");
            byte[] adminImageBytes = null;
            String adminImgType = null;

            if (adminImagePart != null && adminImagePart.getSize() > 0) {
                try (InputStream is = adminImagePart.getInputStream()) {
                    adminImageBytes = is.readAllBytes();
                }
                String contentType = adminImagePart.getContentType(); // e.g. image/png
                if (contentType != null && contentType.contains("/")) {
                    adminImgType = contentType.substring(contentType.indexOf("/") + 1); // → png
                }
            }

            String insertUserSQL = """
                INSERT INTO users (name, email, phone, password, role, status, image, imgtype)
                VALUES (?, ?, ?, ?, 'theateradmin', 'active', ?, ?)
            """;

            int adminId = -1;
            try (PreparedStatement ps = con.prepareStatement(insertUserSQL, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, phone);
                ps.setString(4, password);

                if (adminImageBytes != null) ps.setBytes(5, adminImageBytes);
                else ps.setNull(5, Types.BLOB);

                ps.setString(6, adminImgType);

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    ResultSet rs = ps.getGeneratedKeys();
                    if (rs.next()) adminId = rs.getInt(1);
                }
            }

            if (adminId == -1) {
                request.setAttribute("error", "❌ Failed to create admin user.");
                request.getRequestDispatcher("create-theater-admin.jsp").forward(request, response);
                return;
            }

            // ===== 2️⃣ Create Theater =====
            String theaterName = request.getParameter("theater_name");
            String street = request.getParameter("street");
            String fullLocation = request.getParameter("full_location");

            Part theaterImagePart = request.getPart("image");
            String theaterImgBase64 = null;
            String theaterImgType = null;

            if (theaterImagePart != null && theaterImagePart.getSize() > 0) {
                try (InputStream is = theaterImagePart.getInputStream()) {
                    byte[] imageBytes = is.readAllBytes();
                    theaterImgBase64 = Base64.getEncoder().encodeToString(imageBytes);
                }
                String contentType = theaterImagePart.getContentType();
                if (contentType != null && contentType.contains("/")) {
                    theaterImgType = contentType.substring(contentType.indexOf("/") + 1);
                }
            }

            Theater theater = new Theater();
            theater.setName(theaterName);
            theater.setLocation(street + ", " + fullLocation);
            theater.setImage(theaterImgBase64);
            theater.setImgtype(theaterImgType);
            theater.setUserId(adminId);

            TheaterDAO theaterDAO = new TheaterDAO();
            int theaterId = theaterDAO.createTheater(theater);

            if (theaterId != -1) {
                HttpSession session = request.getSession();
                session.setAttribute("theater_id", theaterId);

                response.sendRedirect("addSeats.jsp");
            } else {
                request.setAttribute("error", "❌ Failed to create theater record.");
                request.getRequestDispatcher("create-theater-admin.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "⚠️ Exception: " + e.getMessage());
            request.getRequestDispatcher("create-theater-admin.jsp").forward(request, response);
        }
    }
}
