package com.email;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

//@WebServlet("/RegisterCompanyServlet")
public class RegisterCompanyServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Fetch form data
        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String companyName = request.getParameter("company_name");
        String phoneNumber = request.getParameter("phone_number");
        String country = request.getParameter("country");
        String companySize = request.getParameter("company_size");
        String customSize = request.getParameter("custom_size");
        String password = request.getParameter("password");
        String address = request.getParameter("address");
        String website = request.getParameter("website");

        // If custom size is provided, use it instead
        if (customSize != null && !customSize.isEmpty()) {
            companySize = customSize;
        }

        try {
            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            // Get existing company IDs' last two digits
            List<Integer> existingLastTwoDigits = new ArrayList<>();
            String getIdsSql = "SELECT company_id FROM company_registration1";
            PreparedStatement getIdsPs = con.prepareStatement(getIdsSql);
            ResultSet idsRs = getIdsPs.executeQuery();
            while (idsRs.next()) {
                int companyId = idsRs.getInt("company_id");
                int lastTwoDigits = companyId % 100; // Get last two digits
                existingLastTwoDigits.add(lastTwoDigits);
            }

            // Generate a random 4-digit company_id with unique last two digits
            Random random = new Random();
            int companyId;
            int lastTwoDigits;
            do {
                companyId = 1000 + random.nextInt(9000); // Generates a number between 1000 and 9999
                lastTwoDigits = companyId % 100; // Get last two digits
            } while (existingLastTwoDigits.contains(lastTwoDigits));

            // Check if email already exists
            String checkEmailSql = "SELECT COUNT(*) FROM company_registration1 WHERE email = ?";
            PreparedStatement checkEmailPs = con.prepareStatement(checkEmailSql);
            checkEmailPs.setString(1, email);
            ResultSet emailRs = checkEmailPs.executeQuery();
            emailRs.next();
            int emailCount = emailRs.getInt(1);

            // Check if phone number already exists
            String checkPhoneSql = "SELECT COUNT(*) FROM company_registration1 WHERE phone_number = ?";
            PreparedStatement checkPhonePs = con.prepareStatement(checkPhoneSql);
            checkPhonePs.setString(1, phoneNumber);
            ResultSet phoneRs = checkPhonePs.executeQuery();
            phoneRs.next();
            int phoneCount = phoneRs.getInt(1);

            // Check if company name already exists
            String checkCompanySql = "SELECT COUNT(*) FROM company_registration1 WHERE company_name = ?";
            PreparedStatement checkCompanyPs = con.prepareStatement(checkCompanySql);
            checkCompanyPs.setString(1, companyName);
            ResultSet companyRs = checkCompanyPs.executeQuery();
            companyRs.next();
            int companyCount = companyRs.getInt(1);

            if (emailCount > 0) {
                // Email already registered
                request.setAttribute("errorMessage", "The email '" + email + "' is already registered.");
                request.getRequestDispatcher("dashegisterCompany.jsp").forward(request, response);
            } else if (phoneCount > 0) {
                // Phone number already registered
                request.setAttribute("errorMessage", "The phone number '" + phoneNumber + "' is already registered.");
                request.getRequestDispatcher("dashegisterCompany.jsp").forward(request, response);
            } else if (companyCount > 0) {
                // Company already registered
                request.setAttribute("errorMessage", "Company '" + companyName + "' is already registered.");
                request.getRequestDispatcher("dashegisterCompany.jsp").forward(request, response);
            } else {
                // Insert data into the table, including the company_id
                String sql = "INSERT INTO company_registration1 (company_id, full_name, email, company_name, phone_number, country, company_size, password, address, website) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setInt(1, companyId);
                ps.setString(2, fullName);
                ps.setString(3, email);
                ps.setString(4, companyName);
                ps.setString(5, phoneNumber);
                ps.setString(6, country);
                ps.setString(7, companySize);
                ps.setString(8, password);
                ps.setString(9, address);
                ps.setString(10, website);

                int row = ps.executeUpdate();
                if (row > 0) {
                    response.sendRedirect("dashadminLogin.jsp");
                } else {
                    response.sendRedirect("error.jsp");
                }
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}