import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class negotiateQuoteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        int quoteId = Integer.parseInt(request.getParameter("quoteId"));
        double newAmount = Double.parseDouble(request.getParameter("newAmount").replaceAll("[^0-9.]", ""));

        Connection con = null;
        PreparedStatement psQuote = null;
        PreparedStatement psFinance = null;

        try {
            
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);
            

            // Update quotation table
            String sqlQuote = "UPDATE quotation SET amount = ? WHERE quote_id = ? AND lead_id IN (SELECT lead_id FROM leads WHERE company_id = ?)";
            psQuote = con.prepareStatement(sqlQuote);
            psQuote.setDouble(1, newAmount);
            psQuote.setInt(2, quoteId);
            psQuote.setInt(3, companyId);
            psQuote.executeUpdate();

            // Update financemanagement table
            String sqlFinance = "UPDATE financemanagement SET quotes_values = ? WHERE lead_id IN (SELECT lead_id FROM quotation WHERE quote_id = ?)";
            psFinance = con.prepareStatement(sqlFinance);
            psFinance.setDouble(1, newAmount);
            psFinance.setInt(2, quoteId);
            psFinance.executeUpdate();

            response.sendRedirect("quotes.jsp?success=true");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("quotes.jsp?error=true");
        } finally {
            try {
                if (psQuote != null) psQuote.close();
                if (psFinance != null) psFinance.close();
                if (con != null) con.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}