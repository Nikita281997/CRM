package com.email;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

public class LogoutServlet extends HttpServlet {

    // Handle GET requests (e.g., when users click logout link)
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        logout(request, response);
    }

    // Handle POST requests (e.g., form-based logout)
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        logout(request, response);
    }

    // Common logout logic
    private void logout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false); // Get session without creating a new one
        if (session != null) {
            session.invalidate(); // Destroy session
        }
        response.sendRedirect("login1.jsp"); // Redirect to login page
    }
}
