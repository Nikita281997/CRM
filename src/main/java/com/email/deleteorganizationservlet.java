package com.email;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/deleteorganizationservlet")
public class deleteorganizationservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

   

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
       // response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        // Get the quote ID to delete from the request
        String quoteId = request.getParameter("quoteid");

        // Check if the quote ID is provided
        if (quoteId == null || quoteId.isEmpty()) {
            out.println("<h3>Error: No Organizaton ID provided!</h3>");
            return;
        }

        
        

        try {
            // Load MySQL JDBC Driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Connect to the database
            Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            // SQL query to delete the record
            String sql = "DELETE FROM organization WHERE id = ?";
            PreparedStatement  stmt = con.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(quoteId));

            // Execute the delete query
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                out.println("<script>alert('Organization deleted successfully!'); window.location='organization.jsp';</script>");
            } else {
                out.println("<script>alert('No Organization found with the given ID.'); window.location='organization.jsp';</script>");
            }

        } catch (ClassNotFoundException e) {
            out.println("<h3>Error: Unable to load database driver!</h3>");
            e.printStackTrace();
        } catch (SQLException e) {
            out.println("<h3>Error: Database operation failed!</h3>");
            e.printStackTrace();
        } 
    }
}
