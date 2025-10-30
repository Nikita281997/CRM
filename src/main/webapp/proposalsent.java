import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/proposalsent")
public class proposalsent extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int leadId = Integer.parseInt(request.getParameter("leadId"));
      

        Connection conn = null;
        PreparedStatement pstmtFetch = null;
        PreparedStatement pstmtInsert = null;
        PreparedStatement pstmtDelete = null;

        try {
           String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, pass);
            // Fetch lead details from 'connected' table
            String fetchSql = "SELECT * FROM connected WHERE lead_id = ?";
            pstmtFetch = conn.prepareStatement(fetchSql);
            pstmtFetch.setInt(1, leadId);
            ResultSet rs = pstmtFetch.executeQuery();

            if (rs.next()) {
                String projectName = rs.getString("project_name");
                String customerName = rs.getString("customer_name");

                // Insert lead into 'proposalsent' table
                String insertSql = "INSERT INTO proposalsent (lead_id, project_name, customer_name) VALUES (?, ?, ?)";
                pstmtInsert = conn.prepareStatement(insertSql);
                pstmtInsert.setInt(1, leadId);
                pstmtInsert.setString(2, projectName);
                pstmtInsert.setString(3, customerName);
               
                pstmtInsert.executeUpdate();
            }

            // Delete lead from 'connected' table
            String deleteSql = "DELETE FROM connected WHERE lead_id = ?";
            pstmtDelete = conn.prepareStatement(deleteSql);
            pstmtDelete.setInt(1, leadId);
            pstmtDelete.executeUpdate();

            response.sendRedirect("leadmanagement.jsp");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (pstmtFetch != null) pstmtFetch.close();
                if (pstmtInsert != null) pstmtInsert.close();
                if (pstmtDelete != null) pstmtDelete.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
