package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.google.gson.Gson;

//@WebServlet("/getQuoteDetails")
public class GetQuoteDetailsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
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
            out.print("{\"error\": \"Unauthorized\"}");
            return;
        }

        String quoteId = request.getParameter("quoteId");
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            String sql = "SELECT lead_id, quotation_date, amount FROM quotation WHERE quote_id = ? AND company_id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(quoteId));
            ps.setInt(2, companyId);
            rs = ps.executeQuery();

            if (rs.next()) {
                Gson gson = new Gson();
                QuoteDetails details = new QuoteDetails();
                details.setLeadId(rs.getInt("lead_id"));
                details.setQuotationDate(rs.getString("quotation_date"));
                details.setAmount(rs.getString("amount"));
                out.print(gson.toJson(details));
            } else {
                out.print("{\"error\": \"Quote not found\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\": \"Server error\"}");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private static class QuoteDetails {
        private int leadId;
        private String quotationDate;
        private String amount;

        public void setLeadId(int leadId) {
            this.leadId = leadId;
        }

        public void setQuotationDate(String quotationDate) {
            this.quotationDate = quotationDate;
        }

        public void setAmount(String amount) {
            this.amount = amount;
        }
    }
}