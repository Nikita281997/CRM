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

@WebServlet("/deletecontctservlet")
public class deletecontactservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

   

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
       // response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        // Get the Quote ID to delete from the request
        String QuoteId = request.getParameter("contactid");

        // Check if the Quote ID is provided
        if (QuoteId == null || QuoteId.isEmpty()) {
            out.println("<h3>Error: No Contact ID provided!</h3>");
            return;
        }

        
        

        try {  String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);
           

           
           
            

          

            // SQL query to delete the record
            String sql = "DELETE FROM contactinfo WHERE contact_id = ?";
            PreparedStatement  stmt = con.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(QuoteId));

            // Execute the delete query
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                out.println("<script>alert('Contact deleted successfully!'); window.location='contacts.jsp';</script>");
            } else {
                out.println("<script>alert('No Contact found with the given ID.'); window.location='contacts.jsp';</script>");
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
