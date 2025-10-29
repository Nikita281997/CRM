package com.email;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import org.json.JSONObject;

//@WebServlet("/paymentWebhook")
public class paymentWebhook extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Read the webhook payload
        StringBuilder payload = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                payload.append(line);
            }
        }

        // Parse the payload (example structure, adjust based on Cashfree's actual webhook format)
        JSONObject json = new JSONObject(payload.toString());
        String orderId = json.getString("order_id");
        String paymentStatus = json.getString("payment_status");

        if ("SUCCESS".equalsIgnoreCase(paymentStatus)) {
            try {
                // Database connection
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

                // Update payment_status to 1 (paid)
                String sql = "UPDATE company_registration1 SET payment_status = 1 WHERE company_name = (SELECT company_name FROM company_registration1 WHERE company_name = ? LIMIT 1)";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1, orderId.replace("ORDER_", "")); // Assuming order_id was set as ORDER_<companyName>
                ps.executeUpdate();

                con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.setStatus(HttpServletResponse.SC_OK);
    }
}