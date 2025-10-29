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
 * Servlet implementation class myservlet
 */
public class myservlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
  
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub;
		String myname2=request.getParameter("myname1");
		String mypass2=request.getParameter("mypass1");
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			Connection con=DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
			
			PreparedStatement ps=con.prepareStatement("insert into myinfo(myname,mypass) values(?,?)");
			//PreparedStatement ps=con.prepareStatement("insert into myinfo(myname,mypass) values(?,?)");
			ps.setString(1, myname2);
			ps.setString(2, mypass2);
			int i=ps.executeUpdate();
			if(i==1)
			{
				response.getWriter().println("success");
				
			}
			else
			{
				response.getWriter().println("failed");
			}
			
			
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
	}

}
