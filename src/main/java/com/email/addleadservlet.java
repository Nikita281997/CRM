package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;

@WebServlet("/addleadservlet")
public class addleadservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String proname = request.getParameter("proname").trim();
        String firmname = request.getParameter("firmname").trim();
        String date = request.getParameter("indate").trim();
        String customer = request.getParameter("customer").trim();
        String email = request.getParameter("email").trim();
        String phone = request.getParameter("phone").trim();
        String address = request.getParameter("address").trim();
        String org = request.getParameter("org").trim();

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
            sessionVar.setAttribute("popupMessage", "Invalid session. Please log in again.");
            sessionVar.setAttribute("popupType", "error");
            response.sendRedirect("login1.jsp");
            return;
        }

        try (Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI")) {
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Generate 4-digit lead_id: first 2 digits from company_id, next 2 digits sequentially
            String companyIdPrefix = String.format("%02d", companyId % 100); // Take first 2 digits of company_id
            String queryMaxSeq = "SELECT MAX(lead_id) AS max_lead FROM leads WHERE lead_id LIKE ? AND company_id = ?";
            PreparedStatement psMaxSeq = con.prepareStatement(queryMaxSeq);
            psMaxSeq.setString(1, companyIdPrefix + "%");
            psMaxSeq.setInt(2, companyId);
            ResultSet rsMaxSeq = psMaxSeq.executeQuery();
            int nextSeq = 1;
            if (rsMaxSeq.next()) {
                String maxLeadId = rsMaxSeq.getString("max_lead");
                if (maxLeadId != null) {
                    int currentSeq = Integer.parseInt(maxLeadId.substring(2)); // Get the sequence part
                    nextSeq = currentSeq + 1;
                }
            }
            rsMaxSeq.close();
            psMaxSeq.close();
            String leadIdStr = companyIdPrefix + String.format("%02d", nextSeq);
            int leadId = Integer.parseInt(leadIdStr);

            String checkQuery = "SELECT email, contact, project_name FROM leads WHERE company_id = ? AND (email = ? OR contact = ? OR project_name = ?)";
            try (PreparedStatement checkPs = con.prepareStatement(checkQuery)) {
                checkPs.setInt(1, companyId);
                checkPs.setString(2, email);
                checkPs.setString(3, phone);
                checkPs.setString(4, proname);

                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        StringBuilder errorMessage = new StringBuilder("Duplicate entry found for: ");
                        boolean hasDuplicate = false;
                        
                        if (email.equalsIgnoreCase(rs.getString("email"))) {
                            errorMessage.append("Email ");
                            hasDuplicate = true;
                        }
                        if (phone.equals(rs.getString("contact"))) {
                            errorMessage.append("Contact ");
                            hasDuplicate = true;
                        }
                        if (proname.equalsIgnoreCase(rs.getString("project_name"))) {
                            errorMessage.append("Project Name ");
                            hasDuplicate = true;
                        }
                        
                        if (hasDuplicate) {
                            sessionVar.setAttribute("popupMessage", errorMessage.toString());
                            sessionVar.setAttribute("popupType", "error");
                            response.sendRedirect("empdashboared.jsp");
                            return;
                        }
                    }
                }
            }

            String insertQuery = "INSERT INTO leads(lead_id, project_name, firm, in_date, customer_name, email, contact, address, org, company_id) VALUES (?,?,?,?,?,?,?,?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(insertQuery)) {
                ps.setInt(1, leadId);
                ps.setString(2, proname);
                ps.setString(3, firmname);
                ps.setString(4, date);
                ps.setString(5, customer);
                ps.setString(6, email);
                ps.setString(7, phone);
                ps.setString(8, address);
                ps.setString(9, org);
                ps.setInt(10, companyId);

                int i = ps.executeUpdate();
                if (i == 1) {
                    sessionVar.setAttribute("popupMessage", "Lead added successfully!");
                    sessionVar.setAttribute("popupType", "success");
                    response.sendRedirect("leads.jsp");
                } else {
                    sessionVar.setAttribute("popupMessage", "Failed to add lead. Please try again.");
                    sessionVar.setAttribute("popupType", "error");
                    response.sendRedirect("leads.jsp");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            sessionVar.setAttribute("popupMessage", "Database error: " + e.getMessage());
            sessionVar.setAttribute("popupType", "error");
            response.sendRedirect("leads.jsp");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            sessionVar.setAttribute("popupMessage", "Driver not found: " + e.getMessage());
            sessionVar.setAttribute("popupType", "error");
            response.sendRedirect("leads.jsp");
        }
    }
}