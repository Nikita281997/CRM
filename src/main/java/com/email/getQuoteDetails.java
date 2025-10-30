package com.email;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.json.JSONObject;

import com.itextpdf.io.exceptions.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

//@WebServlet("/getQuoteDetails")
public class getQuoteDetails extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int quoteId = Integer.parseInt(request.getParameter("quoteId"));
        
        try {
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);
            String sql = "SELECT requirement, feature, amount FROM quotation WHERE quote_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, quoteId);
            ResultSet rs = ps.executeQuery();
            
            JSONObject json = new JSONObject();
            if (rs.next()) {
                json.put("requirement", rs.getString("requirement"));
                json.put("feature", rs.getString("feature"));
                json.put("amount", rs.getString("amount"));
            }
            
            response.setContentType("application/json");
            response.getWriter().write(json.toString());
        } catch (Exception e) {
            e.printStackTrace();
            try {
				response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			} catch (java.io.IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
        }
    }
}