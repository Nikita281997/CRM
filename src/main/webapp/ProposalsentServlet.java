package main.webapp;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


/**
 * Servlet implementation class ProposalsentServlet
 */
@WebServlet("/ProposalsentServlet")
public class ProposalsentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int leadId = Integer.parseInt(request.getParameter("leadId"));

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {

            
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, pass);
            // Check if lead exists in the 'quotation' table
            String checkQuoteSql = "SELECT COUNT(*) AS count FROM quotation WHERE lead_id = ?";
            stmt = conn.prepareStatement(checkQuoteSql);
            stmt.setInt(1, leadId);
            rs = stmt.executeQuery();

            if (rs.next() && rs.getInt("count") > 0) {
                // Insert into 'proposalsent' table
                String insertSql = "INSERT INTO proposalsent (lead_id, project_name, customer_name) "
                        + "SELECT lead_id, project_name, customer_name FROM leads WHERE lead_id = ?";
                stmt = conn.prepareStatement(insertSql);
                stmt.setInt(1, leadId);
                int rowsAffected = stmt.executeUpdate();

                // Update proposal column in leads table
                String updateSql = "UPDATE leads SET proposal = 'yes' WHERE lead_id = ?";
                stmt = conn.prepareStatement(updateSql);
                stmt.setInt(1, leadId);
                stmt.executeUpdate();

                if (rowsAffected > 0) {
                    // Remove the lead from the connected stage
                    String deleteSql = "DELETE FROM connected WHERE lead_id = ?";
                    stmt = conn.prepareStatement(deleteSql);
                    stmt.setInt(1, leadId);
                    stmt.executeUpdate();

                    // Redirect to leadmanagement.jsp
                    response.sendRedirect("leadmanagement.jsp");
                } else {
                    // If insert fails, redirect to leadmanagement.jsp with failure message
                    response.sendRedirect("leadmanagement.jsp?error=Failed to move lead to Proposal stage.");
                }
            } else {
                // If the lead is not in the quotation table, send error message and redirect
                response.sendRedirect("quotes.jsp?error=Quotation is not available for this lead. Please add a quotation first.");
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}