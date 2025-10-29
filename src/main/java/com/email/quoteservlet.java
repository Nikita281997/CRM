package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.math.BigDecimal;

@WebServlet("/quoteservlet")
public class quoteservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession sessionVar = request.getSession();
        String companyIdStr = (String) sessionVar.getAttribute("company_id");

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

        String leadid = request.getParameter("leadid");
        String date = request.getParameter("date");
        String[] srNos = request.getParameterValues("srNo[]");
        String[] descriptions = request.getParameterValues("description[]");
        String[] prices = request.getParameterValues("price[]");
        String amt = request.getParameter("amount");

        BigDecimal amount;
        try {
            amount = new BigDecimal(amt != null ? amt : "0");
        } catch (NumberFormatException e) {
            response.getWriter().println(
                "<script type='text/javascript'>"
                + "alert('Invalid amount format. Please enter a valid number.');"
                + "window.location.href = 'quotes.jsp';"
                + "</script>");
            return;
        }

        Connection con = null;
        PreparedStatement checkPs = null;
        PreparedStatement psQuote = null;
        PreparedStatement psFinance = null;
        PreparedStatement psDescription = null;
        ResultSet rs = null;
        PreparedStatement leadDatePs = null;
        PreparedStatement leadStatusPs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            String leadStatusQuery = "SELECT status FROM leads WHERE lead_id = ? AND company_id = ?";
            leadStatusPs = con.prepareStatement(leadStatusQuery);
            leadStatusPs.setString(1, leadid);
            leadStatusPs.setInt(2, companyId);
            ResultSet leadStatusRs = leadStatusPs.executeQuery();

            if (leadStatusRs.next()) {
                String leadStatus = leadStatusRs.getString("status");
                if (!"Connected".equalsIgnoreCase(leadStatus)) {
                    response.getWriter().println(
                        "<script type='text/javascript'>"
                        + "alert('Cannot add quote: Lead status is not Connected.');"
                        + "window.location.href = 'quotes.jsp';"
                        + "</script>");
                    return;
                }
            } else {
                response.getWriter().println(
                    "<script type='text/javascript'>"
                    + "alert('Unauthorized access: This lead does not belong to your company!');"
                    + "window.location.href = 'quotes.jsp';"
                    + "</script>");
                return;
            }

            String leadCheckQuery = "SELECT in_date FROM leads WHERE lead_id = ? AND company_id = ?";
            leadDatePs = con.prepareStatement(leadCheckQuery);
            leadDatePs.setString(1, leadid);
            leadDatePs.setInt(2, companyId);
            ResultSet leadDateRs = leadDatePs.executeQuery();

            if (!leadDateRs.next()) {
                response.getWriter().println(
                    "<script type='text/javascript'>"
                    + "alert('Unauthorized access: This lead does not belong to your company!');"
                    + "window.location.href = 'quotes.jsp';"
                    + "</script>");
                return;
            }

            String leadInDateStr = leadDateRs.getString("in_date");
            
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date leadInDate = sdf.parse(leadInDateStr);
            Date quotationDate = sdf.parse(date);
            
            if (quotationDate.before(leadInDate)) {
                response.getWriter().println(
                    "<script type='text/javascript'>"
                    + "alert('Quotation date cannot be before the lead creation date (" + leadInDateStr + ").');"
                    + "window.location.href = 'quotes.jsp';"
                    + "</script>");
                return;
            }

            String checkQuoteQuery = "SELECT COUNT(*) FROM quotation WHERE lead_id = ? AND company_id = ?";
            checkPs = con.prepareStatement(checkQuoteQuery);
            checkPs.setString(1, leadid);
            checkPs.setInt(2, companyId);
            rs = checkPs.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                response.getWriter().println(
                    "<script type='text/javascript'>"
                    + "alert('Lead ID already has a quotation. Cannot add duplicate quotes!');"
                    + "window.location.href = 'quotes.jsp';"
                    + "</script>");
            } else {
                // Begin transaction
                con.setAutoCommit(false);

                try {
                    // Insert descriptions
                    String insertDesc = "INSERT INTO description (lead_id, company_id, sr_no, descriptions, price) VALUES (?, ?, ?, ?, ?)";
                    psDescription = con.prepareStatement(insertDesc);
                    for (int i = 0; i < srNos.length; i++) {
                        psDescription.setInt(1, Integer.parseInt(leadid));
                        psDescription.setInt(2, companyId);
                        psDescription.setInt(3, Integer.parseInt(srNos[i]));
                        psDescription.setString(4, descriptions[i]);
                        psDescription.setBigDecimal(5, new BigDecimal(prices[i]));
                        psDescription.executeUpdate();
                    }

                    // Insert quote with yesno_status
                    String insertQuote = "INSERT INTO quotation(lead_id, quotation_date, amount, orgamt, company_id, yesno_status) VALUES (?, ?, ?, ?, ?, 'yes')";
                    psQuote = con.prepareStatement(insertQuote);
                    psQuote.setString(1, leadid);
                    psQuote.setString(2, date);
                    psQuote.setBigDecimal(3, amount);
                    psQuote.setBigDecimal(4, amount);
                    psQuote.setInt(5, companyId);

                    int quoteResult = psQuote.executeUpdate();

                    if (quoteResult == 1) {
                        String insertFinance = "INSERT INTO financemanagement(lead_id, quotes_values, orgamt, company_id) VALUES (?, ?, ?, ?)";
                        psFinance = con.prepareStatement(insertFinance);
                        psFinance.setString(1, leadid);
                        psFinance.setBigDecimal(2, amount);
                        psFinance.setBigDecimal(3, amount);
                        psFinance.setInt(4, companyId);
                        int financeResult = psFinance.executeUpdate();

                        if (financeResult == 1) {
                            con.commit();
                            response.getWriter().write("Quote, descriptions, and financial record added successfully");
                            response.sendRedirect("quotes.jsp");
                        } else {
                            throw new SQLException("Failed to insert finance record");
                        }
                    } else {
                        throw new SQLException("Failed to insert quote");
                    }
                } catch (Exception e) {
                    con.rollback();
                    throw e;
                } finally {
                    con.setAutoCommit(true);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            if (e.getMessage().contains("Data truncation: Out of range value for column 'amount'")) {
                response.getWriter().println(
                    "<script type='text/javascript'>"
                    + "alert('The amount value is too large. Please enter a smaller value or contact support.');"
                    + "window.location.href = 'quotes.jsp';"
                    + "</script>");
            } else {
                response.getWriter().println(
                    "<script type='text/javascript'>"
                    + "alert('Database error: " + e.getMessage().replace("'", "\\'") + "');"
                    + "window.location.href = 'quotes.jsp';"
                    + "</script>");
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.getWriter().println(
                "<script type='text/javascript'>"
                + "alert('System configuration error. Please contact support.');"
                + "window.location.href = 'quotes.jsp';"
                + "</script>");
        } catch (ParseException e) {
            e.printStackTrace();
            response.getWriter().println(
                "<script type='text/javascript'>"
                + "alert('Invalid date format. Please use YYYY-MM-DD format.');"
                + "window.location.href = 'quotes.jsp';"
                + "</script>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (checkPs != null) checkPs.close();
                if (psQuote != null) psQuote.close();
                if (psFinance != null) psFinance.close();
                if (psDescription != null) psDescription.close();
                if (leadDatePs != null) leadDatePs.close();
                if (leadStatusPs != null) leadStatusPs.close();
                if (con != null) con.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}