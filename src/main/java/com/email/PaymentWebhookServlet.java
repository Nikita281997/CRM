package com.email;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

//@WebServlet("/PaymentWebhookServlet")
public class PaymentWebhookServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Read the webhook payload
        StringBuilder payload = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                payload.append(line);
            }
        }

        System.out.println("Webhook Payload Received: " + payload.toString());

        Connection con = null;
        try {
            // Parse the payload
            JSONObject jsonPayload = new JSONObject(payload.toString());
            if (!jsonPayload.has("event")) {
                System.out.println("Webhook Error: 'event' field missing in payload");
                response.setStatus(HttpServletResponse.SC_OK);
                return;
            }

            String event = jsonPayload.getString("event");
            System.out.println("Webhook Event: " + event);

            // Check if payment was successful
            if (!event.equals("PAYMENT_SUCCESS")) {
                System.out.println("Payment not successful. Event: " + event);
                response.setStatus(HttpServletResponse.SC_OK);
                return;
            }

            // Extract link_id from the payload
            // The payload structure might be different; let's inspect it carefully
            if (!jsonPayload.has("data")) {
                System.out.println("Webhook Error: 'data' field missing in payload");
                response.setStatus(HttpServletResponse.SC_OK);
                return;
            }
            JSONObject data = jsonPayload.getJSONObject("data");

            String linkId = null;
            // Cashfree webhook payload might have link_id in a different structure
            // Based on Cashfree's documentation, it might be under data.order.link_id or similar
            if (data.has("order") && data.getJSONObject("order").has("link_id")) {
                linkId = data.getJSONObject("order").getString("link_id");
            } else if (data.has("link_id")) {
                linkId = data.getString("link_id");
            } else {
                System.out.println("Webhook Error: 'link_id' field missing in data");
                response.setStatus(HttpServletResponse.SC_OK);
                return;
            }
            System.out.println("Processing payment for link_id: " + linkId);

            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
             String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);
            System.out.println("PaymentWebhookServlet: Database connection established successfully");

            // Start a transaction to ensure atomicity
            con.setAutoCommit(false);
            System.out.println("Transaction started");

            // Retrieve the record from pending_registrations
            String selectSql = "SELECT * FROM pending_registrations WHERE link_id = ?";
            PreparedStatement selectPs = con.prepareStatement(selectSql);
            selectPs.setString(1, linkId);
            ResultSet rs = selectPs.executeQuery();

            if (!rs.next()) {
                System.out.println("No record found in pending_registrations for link_id: " + linkId);
                con.rollback();
                response.setStatus(HttpServletResponse.SC_OK);
                return;
            }

            // Extract data from pending_registrations
            String fullName = rs.getString("full_name");
            String email = rs.getString("email");
            String companyName = rs.getString("company_name");
            String phoneNumber = rs.getString("phone_number");
            String country = rs.getString("country");
            int companySize = rs.getInt("company_size");
            String password = rs.getString("password");
            String address = rs.getString("address");
            String website = rs.getString("website");

            System.out.println("Data retrieved from pending_registrations: " +
                "full_name=" + fullName + ", email=" + email + ", company_name=" + companyName +
                ", phone_number=" + phoneNumber + ", country=" + country + ", company_size=" + companySize);

            // Insert into company_registration1 with payment_status = 1
            String insertSql = "INSERT INTO company_registration1 (full_name, email, company_name, phone_number, country, company_size, password, address, website, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement insertPs = con.prepareStatement(insertSql);
            insertPs.setString(1, fullName);
            insertPs.setString(2, email);
            insertPs.setString(3, companyName);
            insertPs.setString(4, phoneNumber);
            insertPs.setString(5, country);
            insertPs.setInt(6, companySize);
            insertPs.setString(7, password);
            insertPs.setString(8, address);
            insertPs.setString(9, website);
            insertPs.setInt(10, 1); // payment_status = 1 for successful payment
            int row = insertPs.executeUpdate();
            if (row <= 0) {
                System.out.println("Failed to insert data into company_registration1 for link_id: " + linkId);
                con.rollback();
                throw new SQLException("Failed to transfer data to company_registration1");
            }
            System.out.println("Data inserted into company_registration1 successfully for link_id: " + linkId);

            // Delete from pending_registrations
            String deleteSql = "DELETE FROM pending_registrations WHERE link_id = ?";
            PreparedStatement deletePs = con.prepareStatement(deleteSql);
            deletePs.setString(1, linkId);
            int deletedRows = deletePs.executeUpdate();
            if (deletedRows <= 0) {
                System.out.println("Failed to delete record from pending_registrations for link_id: " + linkId);
                con.rollback();
                throw new SQLException("Failed to delete record from pending_registrations");
            }
            System.out.println("Record deleted from pending_registrations successfully for link_id: " + linkId);

            // Commit the transaction
            con.commit();
            System.out.println("Transaction committed successfully for link_id: " + linkId);

            response.setStatus(HttpServletResponse.SC_OK);
            System.out.println("Successfully processed webhook for link_id: " + linkId);

        } catch (Exception e) {
            System.out.println("Webhook Error: " + e.getMessage());
            e.printStackTrace();
            if (con != null) {
                try {
                    System.out.println("Rolling back transaction due to error");
                    con.rollback();
                } catch (SQLException rollbackEx) {
                    System.out.println("Rollback Error: " + rollbackEx.getMessage());
                    rollbackEx.printStackTrace();
                }
            }
            response.setStatus(HttpServletResponse.SC_OK); // Cashfree expects a 200 response even on error
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true); // Reset auto-commit
                    con.close();
                    System.out.println("PaymentWebhookServlet: Database connection closed");
                } catch (SQLException e) {
                    System.out.println("Error closing database connection: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }
    }
}