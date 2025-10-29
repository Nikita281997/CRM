package com.email;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;


public class SendChatMessageServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false); // Get the session without creating a new one

        if (session == null || session.getAttribute("unique_id") == null) {
            // Redirect to login page or handle the error
            response.sendRedirect("login.jsp");
            return;
        }

        int leadId = Integer.parseInt(request.getParameter("lead_id"));
        String message = request.getParameter("message");

        try {
            // Load the MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Establish a connection to the database
            Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            // Fetch unique_id from the session
            String uniqueIdStr = (String) session.getAttribute("unique_id");
            if (uniqueIdStr == null) {
                throw new ServletException("unique_id is not set in the session.");
            }
            int uniqueId = Integer.parseInt(uniqueIdStr); // Convert String to int

            // Debugging: Print the unique_id to verify its value
            System.out.println("unique_id from session: " + uniqueId);

            // Convert the company_id from String to Integer
            String companyIdStr = (String) session.getAttribute("company_id");
            if (companyIdStr == null) {
                throw new ServletException("company_id is not set in the session.");
            }
            int companyId = Integer.parseInt(companyIdStr); // Convert String to int

            // Debugging: Print the company_id to verify its value
            System.out.println("company_id from session: " + companyId);

            // Verify if unique_id exists in the emp table
            String checkUniqueIdQuery = "SELECT COUNT(*) FROM emp WHERE unique_id = ?";
            PreparedStatement checkUniqueIdStmt = con.prepareStatement(checkUniqueIdQuery);
            checkUniqueIdStmt.setInt(1, uniqueId);
            ResultSet rs = checkUniqueIdStmt.executeQuery();
            if (rs.next() && rs.getInt(1) == 0) {
                throw new ServletException("unique_id " + uniqueId + " does not exist in the emp table.");
            }

            // Insert the chat message using unique_id
            String query = "INSERT INTO chat_messages (company_id, lead_id, unique_id, message) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setInt(1, companyId);
            ps.setInt(2, leadId);
            ps.setInt(3, uniqueId); // Use unique_id instead of emp_id
            ps.setString(4, message);
            ps.executeUpdate();

            // Close the database connection
            ps.close();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error sending chat message: " + e.getMessage(), e);
        }
    }
}