

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
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Servlet implementation class qualifiedsentservlet
 */
public class qualifiedsentservlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
  
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
        response.setContentType("text/html");
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			Connection con=DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
			//select dat from the lead table
			PreparedStatement ps1=con.prepareStatement("select lead_id,project_name,customer_name from leads");
			ResultSet rs=ps1.executeQuery();
			//insert the data into the qualified
			PreparedStatement ps2=con.prepareStatement("insert into qualified(lead_id,project_name,customer_name) values(?,?,?)");
			//delete from proposalsent
			PreparedStatement ps3=con.prepareStatement("delete from proposalsent where lead_id=?");
			while(rs.next()){
				 int leadId = rs.getInt("lead_id");
                 String projectName = rs.getString("project_name");
                 String customerName = rs.getString("customer_name");
				 // Insert into qualified
               ps2.setInt(1, leadId);
                ps2.setString(2, projectName);
                ps2.setString(3, customerName);
                ps2.executeUpdate();
                //delete from proposalsent
                ps3.setInt(1, leadId);
                ps3.executeUpdate();

			}
			 out.println("<script>alert('Lead updated successfully!'); window.location='leadmanagement.jsp';</script>");
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}

}
