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

public class ChatServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String message = request.getParameter("message");
        int companyId = Integer.parseInt(request.getParameter("company_id"));
        int leadId = Integer.parseInt(request.getParameter("lead_id"));

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // Load the MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Establish a connection to the database
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            // Fetch the team lead's unique_id
            ps = con.prepareStatement("SELECT unique_id FROM emp WHERE company_id = ? AND position = 'team lead' LIMIT 1");
            ps.setInt(1, companyId);
            rs = ps.executeQuery();

            if (rs.next()) {
                int uniqueId = rs.getInt("unique_id");

                // Insert the chat message using unique_id
                ps = con.prepareStatement("INSERT INTO chat_messages (company_id, lead_id, unique_id, message) VALUES (?, ?, ?, ?)");
                ps.setInt(1, companyId);
                ps.setInt(2, leadId);
                ps.setInt(3, uniqueId); // Use unique_id instead of emp_id
                ps.setString(4, message);
                ps.executeUpdate();

                // Send a success response
                response.getWriter().write("Message sent successfully!");
            } else {
                // Send an error response if no team lead is found
                response.getWriter().write("No team lead found for the company.");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error sending chat message: " + e.getMessage());
        } finally {
            // Close database resources
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}