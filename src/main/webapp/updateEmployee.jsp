<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.demo.dao.MyConnection, java.io.*, jakarta.servlet.http.Part, com.demo.model.User"%>

<%
    // Admin session check
    User admin = (User) session.getAttribute("user");
    if (admin == null || !"admin".equals(admin.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    request.setCharacterEncoding("UTF-8");

    // Get employee ID
    String empIdParam = request.getParameter("id");
    if (empIdParam == null || empIdParam.isEmpty()) {
        response.sendRedirect("employees.jsp");
        return;
    }
    int empId = Integer.parseInt(empIdParam);

    // Get form data
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String role = request.getParameter("role");
    String status = request.getParameter("status");
    String gender = request.getParameter("gender");
    String birthDate = request.getParameter("birth_date");

    Connection conn = MyConnection.getConnection();

    // Handle profile image upload
    Part profilePart = request.getPart("image");
    String profileFileName = null;
    if (profilePart != null && profilePart.getSize() > 0) {
        String uploadDir = application.getRealPath("/uploads/users/");
        new File(uploadDir).mkdirs();
        profileFileName = empId + "_" + profilePart.getSubmittedFileName();
        profilePart.write(uploadDir + File.separator + profileFileName);
    }

    // Update user info
    String sqlUser = profileFileName != null ?
        "UPDATE users SET name=?, email=?, phone=?, role=?, status=?, gender=?, birth_date=?, image=? WHERE id=?" :
        "UPDATE users SET name=?, email=?, phone=?, role=?, status=?, gender=?, birth_date=? WHERE id=?";

    PreparedStatement psUser = conn.prepareStatement(sqlUser);
    psUser.setString(1, name);
    psUser.setString(2, email);
    psUser.setString(3, phone);
    psUser.setString(4, role);
    psUser.setString(5, status);
    psUser.setString(6, gender);
    psUser.setString(7, birthDate);
    if (profileFileName != null) {
        psUser.setString(8, "uploads/users/" + profileFileName);
        psUser.setInt(9, empId);
    } else {
        psUser.setInt(8, empId);
    }
    psUser.executeUpdate();
    psUser.close();

    // Update theaters
    PreparedStatement psTheater = conn.prepareStatement("SELECT * FROM theaters WHERE user_id=?");
    psTheater.setInt(1, empId);
    ResultSet rsTheater = psTheater.executeQuery();

    while (rsTheater.next()) {
        int theaterId = rsTheater.getInt("id");
        String tName = request.getParameter("theater_name_" + theaterId);
        String tLocation = request.getParameter("theater_location_" + theaterId);

        Part theaterPart = request.getPart("theater_image_" + theaterId);
        String theaterFileName = null;
        if (theaterPart != null && theaterPart.getSize() > 0) {
            String uploadDir = application.getRealPath("/uploads/theaters/");
            new File(uploadDir).mkdirs();
            theaterFileName = theaterId + "_" + theaterPart.getSubmittedFileName();
            theaterPart.write(uploadDir + File.separator + theaterFileName);
        }

        String sqlTheater = theaterFileName != null ?
            "UPDATE theaters SET name=?, location=?, image=? WHERE id=?" :
            "UPDATE theaters SET name=?, location=? WHERE id=?";

        PreparedStatement psUpdateTheater = conn.prepareStatement(sqlTheater);
        psUpdateTheater.setString(1, tName);
        psUpdateTheater.setString(2, tLocation);
        if (theaterFileName != null) {
            psUpdateTheater.setString(3, "uploads/theaters/" + theaterFileName);
            psUpdateTheater.setInt(4, theaterId);
        } else {
            psUpdateTheater.setInt(3, theaterId);
        }
        psUpdateTheater.executeUpdate();
        psUpdateTheater.close();
    }

    rsTheater.close();
    psTheater.close();
    conn.close();

    // Redirect back to employee details page
    response.sendRedirect("employeeDetails.jsp?id=" + empId);
%>
