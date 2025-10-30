package com.email;

import java.io.IOException;
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

public class EmployeeLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");

        String emailId = request.getParameter("email");
        String password = request.getParameter("password");

        // Validate input (Ensure non-null and numeric values)
       /* if (companyId == null || empId == null || !companyId.matches("\\d+") || !empId.matches("\\d+")) {
            response.sendRedirect("dashemployeeLogin.jsp?error=Invalid Input");
            return;
        }*/

        try {
           String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String query = "SELECT * FROM emp WHERE email = ? AND password = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                    pstmt.setString(1,emailId);
                    pstmt.setString(2, password);

                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            // Store company_id and emp_id in session
                        	 int companyId = rs.getInt("company_id");
                        	 int empId = rs.getInt("unique_id");
                        	
                            HttpSession session = request.getSession();
                            session.setAttribute("company_id", String.valueOf(companyId));
                          //  session.setAttribute("company_id", companyId);
                            session.setAttribute("emp_id",String.valueOf( empId)); // Using "emp_id" for consistency

                            response.sendRedirect("empdashboared.jsp"); // Redirect to employee dashboard
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
