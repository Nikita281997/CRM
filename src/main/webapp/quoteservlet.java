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

@WebServlet("/quoteservlet") // Servlet Mapping
public class quoteservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String leadid = request.getParameter("leadid");
        String requirements = request.getParameter("requirements");
        String date = request.getParameter("date");
        String features = request.getParameter("features");
        String amt = request.getParameter("amount");

        try {
            // Load MySQL driver and connect
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);

            // Step 1: Check if the lead_id already exists in the Quotation table
            PreparedStatement checkPs = con.prepareStatement("SELECT COUNT(*) FROM Quotation WHERE lead_id = ?");
            checkPs.setString(1, leadid);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                // lead_id already exists, show error message
                response.getWriter().println(
                    "<script type='text/javascript'>"
                    + "alert('Lead ID already exists in the quotation. Cannot add duplicate quotes!');"
                    + "window.location.href = 'quotes.jsp';"
                    + "</script>");
            } else {
                // Step 2: Insert the new quote into Quotation table
                String insertQuote = "INSERT INTO Quotation(lead_id, requirement, quotation_date, feature, amount) VALUES (?, ?, ?, ?, ?)";
                PreparedStatement psQuote = con.prepareStatement(insertQuote);
                psQuote.setString(1, leadid);
                psQuote.setString(2, requirements);
                psQuote.setString(3, date);
                psQuote.setString(4, features);
                psQuote.setString(5, amt);

                int quoteResult = psQuote.executeUpdate();

                // If the quote was inserted successfully, insert into financemanagement table
                if (quoteResult == 1) {
                    String insertFinance = "INSERT INTO financemanagement(lead_id,quotes_values) VALUES (?,?)";
                    PreparedStatement psFinance = con.prepareStatement(insertFinance);
                    psFinance.setString(1, leadid);
                    psFinance.setString(2, amt);
                    int financeResult = psFinance.executeUpdate();
                    if (financeResult == 1) {
                        // Success - Redirect to quotes.jsp with a success message
                        response.getWriter().println(
                            "<script type='text/javascript'>"
                            + "alert('Quote added successfully!');"
                            + "window.location.href = 'quotes.jsp';"
                            + "</script>");
                    } else {
                        // Failure - Redirect back with an error message
                        response.getWriter().println(
                            "<script type='text/javascript'>"
                            + "alert('Failed to add finance record. Please try again.');"
                            + "window.location.href = 'quotes.jsp';"
                            + "</script>");
                    }
                    psFinance.close();
                } else {
                    // Failure - Redirect back with an error message
                    response.getWriter().println(
                        "<script type='text/javascript'>"
                        + "alert('Failed to add quote. Please try again.');"
                        + "window.location.href = 'quotes.jsp';"
                        + "</script>");
                }
                psQuote.close();
            }

            // Close resources
            checkPs.close();
            con.close();

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println(
                "<script type='text/javascript'>"
                + "alert('Database error: " + e.getMessage() + "');"
                + "window.location.href = 'quotes.jsp';"
                + "</script>");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.getWriter().println(
                "<script type='text/javascript'>"
                + "alert('Driver not found: " + e.getMessage() + "');"
                + "window.location.href = 'quotes.jsp';"
                + "</script>");
        }
    }
}