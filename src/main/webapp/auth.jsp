<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Google Authentication</title>
</head>
<body>

<%
    HttpSession userSession = request.getSession(false); // Do not create a new session

    if (userSession != null && userSession.getAttribute("userEmail") != null) {
        // User is already logged in, redirect to Dashboard
        response.sendRedirect("Dashboard.jsp");
        return;
    }

    String email = request.getParameter("email");
    String name = request.getParameter("name");
    String oauthProvider = "google"; 
    String oauthId = request.getParameter("oauth_id");

    if (email != null && name != null && oauthId != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
             
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, pass);

            // Insert user data
            String sql = "INSERT INTO users (email, name, oauth_provider, oauth_id) VALUES (?, ?, ?, ?) "
                       + "ON DUPLICATE KEY UPDATE name = VALUES(name), oauth_provider = VALUES(oauth_provider), oauth_id = VALUES(oauth_id)";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setString(2, name);
            pstmt.setString(3, oauthProvider);
            pstmt.setString(4, oauthId);
            pstmt.executeUpdate();

            // Store session
            userSession = request.getSession(true); // Create session
            userSession.setAttribute("userEmail", email);
            userSession.setAttribute("userName", name);

            // Redirect to dashboard
            response.sendRedirect("Dashboard.jsp");
            return;

        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    } else {
        // If authentication details are missing, redirect to login page
        response.sendRedirect("Login.jsp");
    }
%>

</body>
</html>
