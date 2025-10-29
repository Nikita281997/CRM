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
public class Editcontactservlet extends HttpServlet {
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		response.setContentType("text/html");

		// Retrieve parameters from the request
		String ContactId = request.getParameter("contactid");
		String name1 = request.getParameter("name");
		String email1 = request.getParameter("email");
		String phone1 = request.getParameter("phone");
		String address1 = request.getParameter("address");

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
			String sql = "UPDATE contactinfo SET myname = ?, myemail = ?, myphone = ?, myaddress = ? WHERE ID = ?";
			ps = con.prepareStatement(sql);

			// Set the parameters
			ps.setString(1, name1);
			ps.setString(2, email1);
			ps.setString(3, phone1);
			ps.setString(4, address1);
			ps.setInt(5, Integer.parseInt(ContactId)); // Use ContactId only in WHERE clause

			// Execute the update query
			int rowsUpdated = ps.executeUpdate();

			// Check the result of the update operation
			if (rowsUpdated > 0) {
				out.println("<script>alert('Contact updated successfully!'); window.location='contacts.jsp';</script>");
			} else {
				out.println("<script>alert('No Contact found with the given ID.'); window.location='contacts.jsp';</script>");
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
