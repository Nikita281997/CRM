package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Servlet implementation class addcontact_servlet
 */
@WebServlet("/addorganizationservlet") // Servlet Mapping
public class addorganizationservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name1 = request.getParameter("name");
        String type1 = request.getParameter("type");
        String date1 = request.getParameter("date");
        String customer1 = request.getParameter("customer");
        String balance1 = request.getParameter("balance");
        String total1 = request.getParameter("total");
        String status1 = request.getParameter("status");
        try {
             String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Connection con = DriverManager.getConnection(url, user, pass);
            // Load MySQL driver and connect
            Class.forName("com.mysql.cj.jdbc.Driver");
           
            // Insert data
            PreparedStatement ps = con.prepareStatement("INSERT INTO organization( myname, mytype ,   mydate, mycustomer,mybalance, mytotal , mystatus) VALUES (?, ?, ?, ?,?,?,?)");
            ps.setString(1, name1);
            ps.setString(2, type1);
            ps.setString(3, date1);
            ps.setString(4, customer1);
            ps.setString(5, balance1);
            ps.setString(6, total1);
            ps.setString(7, status1);
            int i = ps.executeUpdate();
            if (i == 1) {
                // Success - Redirect to contacts.jsp with a success messagex
               
                response.getWriter().println(
	                    "<script type='text/javascript'>"
	                    + "alert('Organization add successfully!');"+ "window.location.href = 'organization.jsp';"
	                    + "</script>");
               // request.getRequestDispatcher("contacts.jsp").forward(request, response);
            } else {
                // Failure - Redirect back with an error message
                request.setAttribute("error", "Failed to add organization. Please try again.");
                request.getRequestDispatcher("organization.jsp").forward(request, response);
            }

            // Close resources
            ps.close();
            con.close();

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("organization.jsp").forward(request, response);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            request.setAttribute("error", "Driver not found: " + e.getMessage());
            request.getRequestDispatcher("organization.jsp").forward(request, response);
        }
    }
}

