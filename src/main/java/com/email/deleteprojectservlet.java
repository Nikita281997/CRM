package com.email;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/deleteprojectservlet")
public class deleteprojectservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        // ✅ Get session variable for company_id
        HttpSession session = request.getSession();
        String companyIdStr = (String) session.getAttribute("company_id");
        Integer companyId = null;

        if (companyIdStr != null) {
            try {
                companyId = Integer.parseInt(companyIdStr);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // ✅ Redirect to login if company_id is missing
        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        // ✅ Get the lead ID to delete from the request
        String quoteId = request.getParameter("quoteid");

        // ✅ Check if the lead ID is provided
        if (quoteId == null || quoteId.isEmpty()) {
            out.println("<script>alert('Error: No project ID provided!'); window.location='projects.jsp';</script>");
            return;
        }

        try {
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);

            // ✅ SQL query to delete the record only if company_id matches
            String sql = "DELETE FROM project WHERE lead_id = ? AND company_id = ?";
            PreparedStatement stmt = con.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(quoteId));
            stmt.setInt(2, companyId);

            // ✅ Execute the delete query
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                out.println("<script>alert('Project deleted successfully!'); window.location='projects.jsp';</script>");
            } else {
                out.println("<script>alert('No project found with the given ID for your company.'); window.location='projects.jsp';</script>");
            }

            // ✅ Close resources
            stmt.close();
            con.close();

        } catch (ClassNotFoundException e) {
            out.println("<script>alert('Error: Unable to load database driver!'); window.location='projects.jsp';</script>");
            e.printStackTrace();
        } catch (SQLException e) {
            out.println("<script>alert('Error: Database operation failed!'); window.location='projects.jsp';</script>");
            e.printStackTrace();
        }
    }
}
