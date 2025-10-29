package com.email;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Servlet implementation class Editcontactservlet
 */
public class editorganizationservlet extends HttpServlet {
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		response.setContentType("text/html");

		// Retrieve parameters from the request
		String ContactId = request.getParameter("quoteid");
		 String name1 = request.getParameter("name");
	        String type1 = request.getParameter("type");
	        String date1 = request.getParameter("date");
	        String customer1 = request.getParameter("customer");
	        String balance1 = request.getParameter("balance");
	        String total1 = request.getParameter("total");
	        String status1 = request.getParameter("status");
	      //  String quotevalue1 = request.getParameter("quotevalue");
        // Validate ContactId
        if (ContactId == null || ContactId.isEmpty()) {
            out.println("<h3>Error: No Contact ID provided!</h3>");
            return;
        }

		Connection con = null;
		PreparedStatement ps = null;

		try {
			// Load the MySQL JDBC driver
			Class.forName("com.mysql.cj.jdbc.Driver");

			// Establish a connection to the database
			con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

			// Prepare the SQL query
			String sql = "UPDATE organization SET myname=?, mytype=? ,   mydate=?, mycustomer=?,mybalance=?, mytotal=? , mystatus=? WHERE id = ?";
			ps = con.prepareStatement(sql);

			// Set the parameters
			 ps.setString(1, name1);
	            ps.setString(2, type1);
	            ps.setString(3, date1);
	            ps.setString(4, customer1);
	            ps.setString(5, balance1);
	            ps.setString(6, total1);
	            ps.setString(7, status1);
			//ps.setString(5, quotevalue1);
			
			ps.setInt(8, Integer.parseInt(ContactId)); // Use ContactId only in WHERE clause

			// Execute the update query
			int rowsUpdated = ps.executeUpdate();

			// Check the result of the update operation
			if (rowsUpdated > 0) {
				out.println("<script>alert('Organization updated successfully!'); window.location='organization.jsp';</script>");
			} else {
				out.println("<script>alert('No Project found with the given ID.'); window.location='organization.jsp';</script>");
			}

		} catch (ClassNotFoundException e) {
			e.printStackTrace();
			out.println("<h3>Error: Unable to load the database driver!</h3>");
		} catch (SQLException e) {
			e.printStackTrace();
			out.println("<h3>Error: Unable to execute the SQL query!</h3>");
		} finally {
			// Close resources
			try {
				if (ps != null) ps.close();
				if (con != null) con.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
}
