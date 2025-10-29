package com.email;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class RenewIntegrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String buyDateStr = request.getParameter("buyDate");
        String durationStr = request.getParameter("duration");
        int cost = Integer.parseInt(request.getParameter("cost"));
        

        // Get company_id from session and convert it to Integer
        HttpSession session = request.getSession();
        String companyIdStr = (String) session.getAttribute("company_id");
        
        if (companyIdStr == null || companyIdStr.isEmpty()) {
            request.setAttribute("message", "Error: Unauthorized access. Please log in again.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("integration.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        int companyId = Integer.parseInt(companyIdStr); // Convert company_id to Integer

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String message = "";

        try {
        	   DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
               LocalDate buyDate = LocalDate.parse(buyDateStr, formatter);
               int duration = Integer.parseInt(durationStr);
            //   double cost = Double.parseDouble(costStr);
               
               // Calculate expiry date by adding duration months to buy date
               LocalDate expiryDate = buyDate.plusMonths(duration);

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            // Check if the service belongs to the logged-in company
            String selectSQL = "SELECT expiry_date FROM integrations WHERE id = ? AND company_id = ?";
            pstmt = conn.prepareStatement(selectSQL);
            pstmt.setInt(1, id);
            pstmt.setInt(2, companyId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                Date expiryDateDb = rs.getDate("expiry_date");
                LocalDate expiryDateFromDb = expiryDateDb.toLocalDate();
                LocalDate currentDate = LocalDate.now();

                // Prevent renewal before expiry
                if (currentDate.isBefore(expiryDateFromDb) || currentDate.isEqual(expiryDateFromDb)) {
                    message = "You cannot renew before the expiry date: " + expiryDateFromDb;
                    request.setAttribute("message", message);
                    request.setAttribute("expiryDate", expiryDateFromDb.toString());
                    RequestDispatcher dispatcher = request.getRequestDispatcher("integration.jsp");
                    dispatcher.forward(request, response);
                    return;
                }
            } else {
                message = "Error: Service not found or unauthorized access.";
                request.setAttribute("message", message);
                RequestDispatcher dispatcher = request.getRequestDispatcher("integration.jsp");
                dispatcher.forward(request, response);
                return;
            }

            // Renew the integration
            LocalDate renewalDate = LocalDate.now();
            LocalDate newExpiryDate = renewalDate.plus(1, ChronoUnit.YEARS);

            String updateSQL = "UPDATE integrations SET renewal_charge = ?, renewal_date = ?, expiry_date = ? WHERE id = ? AND company_id = ?";
            pstmt = conn.prepareStatement(updateSQL);
            pstmt.setInt(1, cost);
            pstmt.setDate(2, Date.valueOf(buyDate)); // Using the user-provided buy date
            pstmt.setDate(3, Date.valueOf(expiryDate));
             pstmt.setInt(4, id);
            pstmt.setInt(5, companyId);

            int rowsUpdated = pstmt.executeUpdate();
            if (rowsUpdated > 0) {
                message = "Renewed Successfully!";
            } else {
                message = "Renewal Failed! Service may not belong to your company.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Error Occurred!";
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.setAttribute("message", message);
        RequestDispatcher dispatcher = request.getRequestDispatcher("integration.jsp");
        dispatcher.forward(request, response);
    }
}
