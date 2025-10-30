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
@WebServlet("/addprojectservlet") // Servlet Mapping
public class addprojectservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String project1 = request.getParameter("project");
        String date1 = request.getParameter("date");
        String team1 = request.getParameter("team");
        String status1 = request.getParameter("status");

        try {
            
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Load MySQL driver and connect
            Connection con = DriverManager.getConnection(url, user, pass);

            // Insert data
            PreparedStatement ps = con.prepareStatement("INSERT INTO projectsinfo(myprojects, myduedate, myteamname, mystatus) VALUES (?, ?, ?, ?)");
            ps.setString(1, project1);
            ps.setString(2, date1);
            ps.setString(3, team1);
            ps.setString(4, status1);

            int i = ps.executeUpdate();
            if (i == 1) {
                // Success - Redirect to contacts.jsp with a success messagex
               
                response.getWriter().println(
	                    "<script type='text/javascript'>"
	                    + "alert('Project add successfully!');"+ "window.location.href = 'projects.jsp';"
	                    + "</script>");
               // request.getRequestDispatcher("contacts.jsp").forward(request, response);
            } else {
                // Failure - Redirect back with an error message
                request.setAttribute("error", "Failed to add Project. Please try again.");
                request.getRequestDispatcher("projects.jsp").forward(request, response);
            }

            // Close resources
            ps.close();
            con.close();

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("projects.jsp").forward(request, response);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            request.setAttribute("error", "Driver not found: " + e.getMessage());
            request.getRequestDispatcher("projects.jsp").forward(request, response);
        }
    }
}

