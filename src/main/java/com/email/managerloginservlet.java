package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Servlet implementation class managerloginservlet
 */
public class managerloginservlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	        response.setContentType("text/html");

	        String companyId = request.getParameter("company_id");
	        String empId = request.getParameter("emp_id");

	        // Validate input (Ensure non-null and numeric values)
	        if (companyId == null || empId == null || !companyId.matches("\\d+") || !empId.matches("\\d+")) {
	            response.sendRedirect("dashemployeeLogin.jsp?error=Invalid Input");
	            return;
	        }

	        try {String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
						Connection conn = DriverManager.getConnection(url, user, pass);{
	                String query = "SELECT unique_id FROM emp WHERE company_id = ? AND unique_id = ?";
	                try (PreparedStatement pstmt = conn.prepareStatement(query)) {
	                    pstmt.setInt(1, Integer.parseInt(companyId));
	                    pstmt.setInt(2, Integer.parseInt(empId));

	                    try (ResultSet rs = pstmt.executeQuery()) {
	                        if (rs.next()) {
	                            // Store company_id and emp_id in session
	                            HttpSession session = request.getSession();
	                            session.setAttribute("company_id", companyId);
	                            session.setAttribute("emp_id", empId); // Using "emp_id" for consistency

	                            response.sendRedirect("dashmanager.jsp"); // Redirect to employee dashboard
	                        } else {
	                            response.sendRedirect("dashemployeeLogin.jsp?error=Invalid Credentials");
	                        }
	                    }
	                }
	            }
	        } catch (Exception e) {
	            e.printStackTrace();
	            response.sendRedirect("dashemployeeLogin.jsp?error=Database Error");
	        }
	    }


}
