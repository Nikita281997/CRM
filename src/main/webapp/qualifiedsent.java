import java.io.IOException; 
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/qualifiedsent")
public class qualifiedsent extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Retrieve the leadId parameter from the request
        String leadIdParam = request.getParameter("leadId");

        if (leadIdParam != null && !leadIdParam.isEmpty()) {
            int leadId = Integer.parseInt(leadIdParam);

            
            
            Connection conn = null;
            PreparedStatement pstmtFetch = null;
            PreparedStatement pstmtInsertQualified = null;
            PreparedStatement pstmtInsertProject = null;
            PreparedStatement pstmtDelete = null;
            PreparedStatement pstmtUpdateLeads = null;

            try {
                String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, pass);

                // Fetch lead details from 'proposalsent' table
                String fetchSql = "SELECT * FROM proposalsent WHERE lead_id = ?";
                pstmtFetch = conn.prepareStatement(fetchSql);
                pstmtFetch.setInt(1, leadId);
                ResultSet rs = pstmtFetch.executeQuery();

                if (rs.next()) {
                    String projectName = rs.getString("project_name");
                    String customerName = rs.getString("customer_name");

                    // Insert lead into 'qualified' table
                    String insertSqlQualified = "INSERT INTO qualified (lead_id, project_name, customer_name) VALUES (?, ?, ?)";
                    pstmtInsertQualified = conn.prepareStatement(insertSqlQualified);
                    pstmtInsertQualified.setInt(1, leadId);
                    pstmtInsertQualified.setString(2, projectName);
                    pstmtInsertQualified.setString(3, customerName);
                    pstmtInsertQualified.executeUpdate();

                    // Insert data into 'project' table
                    String insertSqlProject = "INSERT INTO project (lead_id, project_name, customer_name) VALUES ( ?, ?, ?)";
                    pstmtInsertProject = conn.prepareStatement(insertSqlProject);
                    pstmtInsertProject.setInt(1, leadId);
                    pstmtInsertProject.setString(2, projectName);
                    pstmtInsertProject.setString(3, customerName);
                    
                    String insertSqlfinance = "update financemanagement set project_name=?, customer_name=? where lead_id=?";
                    pstmtInsertQualified = conn.prepareStatement(insertSqlfinance);
                    
                    pstmtInsertQualified.setString(1, projectName);
                    pstmtInsertQualified.setString(2, customerName);
                    pstmtInsertQualified.setInt(3, leadId);
                    pstmtInsertQualified.executeUpdate();
                   
                    pstmtInsertProject.executeUpdate();

                    // Update leads table to mark as qualified
                    String updateLeadsSql = "UPDATE leads SET qualified = TRUE WHERE lead_id = ?";
                    pstmtUpdateLeads = conn.prepareStatement(updateLeadsSql);
                    pstmtUpdateLeads.setInt(1, leadId);
                    pstmtUpdateLeads.executeUpdate();
                }

                // Delete lead from 'proposalsent' table
                String deleteSql = "DELETE FROM proposalsent WHERE lead_id = ?";
                pstmtDelete = conn.prepareStatement(deleteSql);
                pstmtDelete.setInt(1, leadId);
                pstmtDelete.executeUpdate();

                // Redirect to lead management page
                response.sendRedirect("leadmanagement.jsp");

            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while processing the request.");
            } finally {
                try {
                    if (pstmtFetch != null) pstmtFetch.close();
                    if (pstmtInsertQualified != null) pstmtInsertQualified.close();
                    if (pstmtInsertProject != null) pstmtInsertProject.close();
                    if (pstmtDelete != null) pstmtDelete.close();
                    if (pstmtUpdateLeads != null) pstmtUpdateLeads.close();
                    if (conn != null) conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } else {
            // Handle missing leadId parameter
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Lead ID is required.");
        }
    }
}