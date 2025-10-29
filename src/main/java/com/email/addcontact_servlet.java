package com.email;/**

package com.email;import jakarta.servlet.ServletException;
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
  Servlet implementation class addcontact_servlet
 
public class addcontact_servlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
 protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	 String name1=request.getParameter("name");
	 String email1=request.getParameter("email");
	 String phone1=request.getParameter("phone");
	 String address1=request.getParameter("address");
	 try {
		Class.forName("com.mysql.cj.jdbc.Driver");
		Connection con=DriverManager.getConnection("jdbc:mysql://localhost:3306/crmdb","root","pass@123");
		PreparedStatement ps=con.prepareStatement("insert into contactinfo(myname,myemail,myphone,myaddress) values(?,?,?,?)");
		//PreparedStatement ps=con.prepareStatement("insert into myinfo(myname,mypass) values(?,?)");
		ps.setString(1, name1);
		ps.setString(2, email1);
		ps.setString(3, phone1);
		ps.setString(4, address1);
		
		int i=ps.executeUpdate();
		if(i==1)
		{
			response.getWriter().println("success");
			
		}
		else
		{
			response.getWriter().println("failed");
		}
		
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	 catch (ClassNotFoundException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
		
	}

}*/import jakarta.servlet.ServletException;
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
@WebServlet("/addcontact_servlet") // Servlet Mapping
public class addcontact_servlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name1 = request.getParameter("name");
        String email1 = request.getParameter("email");
        String phone1 = request.getParameter("phone");
        String address1 = request.getParameter("address");

        try {
            // Load MySQL driver and connect
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            // Insert data
            PreparedStatement ps = con.prepareStatement("INSERT INTO contactinfo(name,email,contact,address)	 VALUES (?,?, ?, ?)");
            ps.setString(1, name1);
            ps.setString(2, email1);
            ps.setString(3, phone1);
            ps.setString(4, address1);

            int i = ps.executeUpdate();
            if (i == 1) {
                // Success - Redirect to contacts.jsp with a success messagex
               
                response.getWriter().println(
	                    "<script type='text/javascript'>"
	                    + "alert('contact add successfully!');"+ "window.location.href = 'contacts.jsp';"
	                    + "</script>");
               // request.getRequestDispatcher("contacts.jsp").forward(request, response);
            } else {
                // Failure - Redirect back with an error message
                request.setAttribute("error", "Failed to add contact. Please try again.");
                request.getRequestDispatcher("contacts.jsp").forward(request, response);
            }

            // Close resources
            ps.close();
            con.close();

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("contacts.jsp").forward(request, response);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            request.setAttribute("error", "Driver not found: " + e.getMessage());
            request.getRequestDispatcher("contacts.jsp").forward(request, response);
        }
    }
}

