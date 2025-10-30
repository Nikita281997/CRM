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

@WebServlet("/editfinance")
public class editfinance extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        response.setContentType("text/html");

        // ✅ Get session and company_id
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

        // ✅ Redirect if company_id is missing
        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        // ✅ Retrieve form data
        String installment = request.getParameter("installment");
        String value = request.getParameter("value");
        String date = request.getParameter("date");
        String recordId = request.getParameter("quoteid");

        if (recordId == null || recordId.isEmpty()) {
            out.println("<script>alert('Error: Record ID is required.'); window.history.back();</script>");
            return;
        }

        try {
            int id = Integer.parseInt(recordId);
            double installmentValue = Double.parseDouble(value);

            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);

            // ✅ Check if record exists and belongs to the logged-in company, fetch orgamt and previous dates
            String selectQuery = "SELECT installment1, installment2, installment3, quotes_values, addiamt, orgamt, total, date1, date2, " +
                                "(SELECT MAX(date3) FROM installment3_logs WHERE finance_id = ?) AS latest_date3 " +
                                "FROM financemanagement WHERE lead_id = ? AND company_id = ?";
            PreparedStatement ps = con.prepareStatement(selectQuery);
            ps.setInt(1, id);
            ps.setInt(2, id);
            ps.setInt(3, companyId);
            ResultSet rs = ps.executeQuery();

            double installment1 = 0, installment2 = 0, installment3 = 0, quotesValues = 0, addiamt = 0, orgamt = 0, currentTotal = 0;
            String date1 = null, date2 = null, latestDate3 = null;
            if (rs.next()) {
                installment1 = rs.getDouble("installment1");
                installment2 = rs.getDouble("installment2");
                installment3 = rs.getDouble("installment3");
                quotesValues = rs.getDouble("quotes_values");
                addiamt = rs.getDouble("addiamt");
                orgamt = rs.getDouble("orgamt");
                currentTotal = rs.getDouble("total");
                date1 = rs.getString("date1");
                date2 = rs.getString("date2");
                latestDate3 = rs.getString("latest_date3");
            } else {
                out.println("<script>alert('Error: No matching record found for your company!'); window.history.back();</script>");
                return;
            }

            // ✅ Validate date restriction
            java.sql.Date newDate = java.sql.Date.valueOf(date);
            java.sql.Date[] previousDates = {date1 != null ? java.sql.Date.valueOf(date1) : null,
                                           date2 != null ? java.sql.Date.valueOf(date2) : null,
                                           latestDate3 != null ? java.sql.Date.valueOf(latestDate3) : null};
            java.sql.Date latestPreviousDate = null;
            for (java.sql.Date d : previousDates) {
                if (d != null && (latestPreviousDate == null || d.after(latestPreviousDate))) {
                    latestPreviousDate = d;
                }
            }
            if (latestPreviousDate != null && !newDate.after(latestPreviousDate)) {
                // Trigger popup on JSP with date validation error
                response.sendRedirect("financemanagement.jsp?error=dateValidation&message=The selected date (" + newDate + ") must be after the latest previous date (" + latestPreviousDate + ")!");
                return;
            }

            // ✅ Validate installment sequence
            if (installment.equals("installment1") && installment1 > 0) {
                out.println("<script>alert('Installment 1 is already set. Cannot overwrite!'); window.history.back();</script>");
                return;
            } else if (installment.equals("installment2") && installment1 == 0) {
                out.println("<script>alert('You must complete Installment 1 before Installment 2!'); window.history.back();</script>");
                return;
            } else if (installment.equals("installment3") && installment2 == 0) {
                out.println("<script>alert('You must complete Installment 2 before Installment 3!'); window.history.back();</script>");
                return;
            }

            // ✅ Adjust installment value for installment3 (add to existing)
            if (installment.equals("installment3")) {
                installmentValue += installment3; // Add new value to existing installment3
            }

            // ✅ Calculate totalPaid including the new installment value
            double totalPaid = installment1 + installment2 + installment3;
            if (installment.equals("installment1")) {
                totalPaid = installmentValue; // Reset total for first installment
            } else if (installment.equals("installment2")) {
                totalPaid = installment1 + installmentValue;
            } else if (installment.equals("installment3")) {
                totalPaid = installment1 + installment2 + installmentValue;
            }

            // ✅ Check if installment value exceeds orgamt
            if (totalPaid > orgamt) {
                out.println("<script>alert('Installment value exceeds the original amount (orgamt)!'); window.history.back();</script>");
                return;
            }

            // ✅ Update the specified installment in financemanagement
            String updateQuery = "UPDATE financemanagement SET " + installment + " = ? WHERE lead_id = ? AND company_id = ?";
            ps = con.prepareStatement(updateQuery);
            ps.setDouble(1, installmentValue);
            ps.setInt(2, id);
            ps.setInt(3, companyId);
            ps.executeUpdate();

            // ✅ Recalculate totals and update balance as orgamt - totalPaid
            double balance = orgamt - totalPaid;
            String totalBalanceStatusQuery = "UPDATE financemanagement SET total = ?, balance = ?, status = ? WHERE lead_id = ? AND company_id = ?";
            ps = con.prepareStatement(totalBalanceStatusQuery);
            ps.setDouble(1, totalPaid);
            ps.setDouble(2, balance);
            ps.setString(3, (balance == 0) ? "Completed" : "Pending");
            ps.setInt(4, id);
            ps.setInt(5, companyId);
            ps.executeUpdate();

            // ✅ Insert into installment3_logs for installment3 with date and company_id
            if (installment.equals("installment1")) {
                PreparedStatement psDate = con.prepareStatement("UPDATE financemanagement SET date1 = ? WHERE lead_id = ? AND company_id = ?");
                psDate.setString(1, date);
                psDate.setInt(2, id);
                psDate.setInt(3, companyId);
                psDate.executeUpdate();
            } else if (installment.equals("installment2")) {
                PreparedStatement psDate = con.prepareStatement("UPDATE financemanagement SET date2 = ? WHERE lead_id = ? AND company_id = ?");
                psDate.setString(1, date);
                psDate.setInt(2, id);
                psDate.setInt(3, companyId);
                psDate.executeUpdate();
            } else if (installment.equals("installment3")) {
                PreparedStatement psLog = con.prepareStatement("INSERT INTO installment3_logs (finance_id, amount, date3, company_id) VALUES (?, ?, ?, ?)");
                psLog.setInt(1, id);
                psLog.setDouble(2, Double.parseDouble(value)); // Use only the entered amount
                psLog.setString(3, date);
                psLog.setInt(4, companyId);
                psLog.executeUpdate();
            }

            out.println("<script>alert('Installment updated successfully!'); window.location='financemanagement.jsp';</script>");
            
            // ✅ Close resources
            rs.close();
            ps.close();
            con.close();
        } catch (NumberFormatException e) {
            out.println("<script>alert('Error: Invalid number format for record ID or installment value.'); window.history.back();</script>");
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error: " + e.getMessage() + "'); window.history.back();</script>");
        }
    }
}