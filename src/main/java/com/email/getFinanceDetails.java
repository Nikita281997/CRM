package com.email;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.google.gson.Gson;


public class getFinanceDetails extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        String quoteIdStr = request.getParameter("quoteId");
        int quoteId;

        try {
            quoteId = Integer.parseInt(quoteIdStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid quoteId format");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Gson gson = new Gson();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            String sql = "SELECT fm.addifeature, fm.addirequirement, fm.installment1, fm.installment2, fm.installment3, " +
                         "fm.total, fm.balance, fm.status " +
                         "FROM financemanagement fm " +
                         "JOIN quotation q ON fm.lead_id = q.lead_id " +
                         "WHERE q.quote_id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, quoteId);
            rs = ps.executeQuery();

            if (rs.next()) {
                FinanceData data = new FinanceData(
                    rs.getString("addifeature"),
                    rs.getString("addirequirement"),
                    rs.getString("installment1"),
                    rs.getString("installment2"),
                    rs.getString("installment3"),
                    rs.getString("total"),
                    rs.getString("balance"),
                    rs.getString("status")
                );
                response.getWriter().write(gson.toJson(new ResponseWrapper(data)));
            } else {
                response.getWriter().write(gson.toJson(new ResponseWrapper(null)));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error occurred");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (ps != null) ps.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }

    // Static inner class for response data
    static class FinanceData {
        String addifeature, addirequirement, installment1, installment2, installment3, total, balance, status;

        FinanceData(String addifeature, String addirequirement, String installment1, String installment2,
                    String installment3, String total, String balance, String status) {
            this.addifeature = addifeature;
            this.addirequirement = addirequirement;
            this.installment1 = installment1;
            this.installment2 = installment2;
            this.installment3 = installment3;
            this.total = total;
            this.balance = balance;
            this.status = status;
        }
    }

    static class ResponseWrapper {
        FinanceData additionalData;

        ResponseWrapper(FinanceData data) {
            this.additionalData = data;
        }
    }
}
