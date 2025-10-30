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
 * Servlet implementation class addorgservlet
 */
public class addorgservlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	   String orgname=request.getParameter("orgname");
    	   String proname=request.getParameter("proname");
    	   String balance=request.getParameter("balance");
    	   PrintWriter out=response.getWriter();
    	   try {
			 String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;

			Class.forName("com.mysql.cj.jdbc.Driver");
			Connection con=DriverManager.getConnection(url, user, pass);
           
			String queryinsert="insert into organization(orgname,proname,balance) values(?,?,?)";
			PreparedStatement ps=con.prepareStatement(queryinsert);
			ps.setString(1,orgname);
			ps.setString(2, proname);
			ps.setString(3, balance);
			int count=ps.executeUpdate();
			
			if(count>0) {
				request.getRequestDispatcher("Organizations.jsp").forward(request, response);
			}else {
				out.println("failed");
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
