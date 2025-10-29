package com.email;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class adminloginservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        String emailId = request.getParameter("email");
        String password = request.getParameter("password");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
            
            String query1 = "SELECT * FROM company_registration1 WHERE email = ? AND password = ?";
            String query2 = "SELECT * FROM emp WHERE email = ? AND password = ?";
            String query3 = "SELECT * FROM project WHERE email = ? AND password = ?";
           
            PreparedStatement pstmt1 = conn.prepareStatement(query1);
            pstmt1.setString(1, emailId);
            pstmt1.setString(2, password);
           
            ResultSet rs = pstmt1.executeQuery();
            
            if (rs.next()) {  
                // ✅ Company Login Successful
                int companyId = rs.getInt("company_id"); 

                HttpSession session = request.getSession();
                session.setAttribute("company_id", String.valueOf(companyId));

                response.sendRedirect("Dashboard.jsp"); 
            } 
            else {
                // ✅ Check Employee Login
                PreparedStatement pstmt2 = conn.prepareStatement(query2);
                pstmt2.setString(1, emailId);
                pstmt2.setString(2, password);
                
                ResultSet rs1 = pstmt2.executeQuery();
                
                if (rs1.next()) {
                    // ✅ Employee Login Successful
                    int companyId = rs1.getInt("company_id");
                    int uniqueId = rs1.getInt("unique_id"); // ✅ Retrieve unique_id from the emp table
                    String position = rs1.getString("position"); // ✅ Fixed ResultSet reference

                    HttpSession session = request.getSession();
                    session.setAttribute("company_id", String.valueOf(companyId));
                    session.setAttribute("unique_id", String.valueOf(uniqueId)); // ✅ Set unique_id in session

                    if (position.equalsIgnoreCase("team lead") || position.equalsIgnoreCase("project manager")) {
                        response.sendRedirect("dashmanager.jsp"); // Redirect team leads & project managers
                    } else {
                        response.sendRedirect("empdashboared.jsp"); // ✅ Fixed typo here
                    }
                } 
                else {
                    // ✅ Check Project Login
                    PreparedStatement pstmt3 = conn.prepareStatement(query3);
                    pstmt3.setString(1, emailId);
                    pstmt3.setString(2, password);
                    ResultSet rs2 = pstmt3.executeQuery();
                    
                    if (rs2.next()) {
                        // ✅ Project Login Successful
                        int companyId = rs2.getInt("company_id"); 
                        int leadId = rs2.getInt("lead_id");

                        HttpSession session = request.getSession();
                        session.setAttribute("company_id", String.valueOf(companyId));
                        session.setAttribute("lead_id", String.valueOf(leadId));

                        response.sendRedirect("dashcustomer.jsp"); 
                    }
                    else {
                        // ❌ Invalid Credentials
                        out.println("<script type='text/javascript'>");
                        out.println("alert('Invalid Email or Password');");
                        out.println("location='dashadminLogin.jsp';");
                        out.println("</script>");
                    }
                    
                    // Close project resources
                    rs2.close();
                    pstmt3.close();
                }
                
                // Close employee resources
                rs1.close();
                pstmt2.close();
            }
            
            // Close company resources
            rs.close();
            pstmt1.close();
            conn.close();
        } 
        catch (Exception e) {
            e.printStackTrace();
            out.println("Error occurred: " + e.getMessage());
        }
    }
}
