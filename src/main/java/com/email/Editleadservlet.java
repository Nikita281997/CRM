package com.email;

import java.io.IOException;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/Editleadservlet")
public class Editleadservlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession sessionVar = request.getSession();
        try {
            int leadId = Integer.parseInt(request.getParameter("leadid").trim());
            String projectName = request.getParameter("proname").trim();
            String firmName = request.getParameter("firmname").trim();
            String inDate = request.getParameter("indate").trim();
            String customerName = request.getParameter("customer").trim();
            String email = request.getParameter("email").trim();
            String phone = request.getParameter("phone").trim();
            String address = request.getParameter("address").trim();
            String org = request.getParameter("org").trim();

            String sourcePage = request.getParameter("sourcePage");
            if (sourcePage == null || sourcePage.trim().isEmpty()) {
                sourcePage = "empdashboared.jsp";
            }


            try {
                String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, pass);
                
                StringBuilder query = new StringBuilder("UPDATE leads SET ");
                boolean firstField = true;

                if (!projectName.isEmpty()) {
                    query.append("project_name=?");
                    firstField = false;
                }
                if (!firmName.isEmpty()) {
                    query.append(firstField ? "" : ", ").append("firm=?");
                    firstField = false;
                }
                if (!inDate.isEmpty()) {
                    query.append(firstField ? "" : ", ").append("in_date=?");
                    firstField = false;
                }
                if (!customerName.isEmpty()) {
                    query.append(firstField ? "" : ", ").append("customer_name=?");
                    firstField = false;
                }
                if (!email.isEmpty()) {
                    query.append(firstField ? "" : ", ").append("email=?");
                    firstField = false;
                }
                if (!phone.isEmpty()) {
                    query.append(firstField ? "" : ", ").append("contact=?");
                    firstField = false;
                }
                if (!address.isEmpty()) {
                    query.append(firstField ? "" : ", ").append("address=?");
                    firstField = false;
                }
                if (!org.isEmpty()) {
                    query.append(firstField ? "" : ", ").append("org=?");
                }

                query.append(" WHERE lead_id=?");

                try (PreparedStatement updateStmt = conn.prepareStatement(query.toString())) {
                    int paramIndex = 1;

                    if (!projectName.isEmpty()) updateStmt.setString(paramIndex++, projectName);
                    if (!firmName.isEmpty()) updateStmt.setString(paramIndex++, firmName);
                    if (!inDate.isEmpty()) updateStmt.setDate(paramIndex++, Date.valueOf(inDate));
                    if (!customerName.isEmpty()) updateStmt.setString(paramIndex++, customerName);
                    if (!email.isEmpty()) updateStmt.setString(paramIndex++, email);
                    if (!phone.isEmpty()) updateStmt.setString(paramIndex++, phone);
                    if (!address.isEmpty()) updateStmt.setString(paramIndex++, address);
                    if (!org.isEmpty()) updateStmt.setString(paramIndex++, org);
                    updateStmt.setInt(paramIndex, leadId);

                    int rowsUpdated = updateStmt.executeUpdate();

                    if (rowsUpdated > 0) {
                        sessionVar.setAttribute("popupMessage", "Lead updated successfully!");
                        sessionVar.setAttribute("popupType", "success");
                        response.sendRedirect(sourcePage);
                    } else {
                        sessionVar.setAttribute("popupMessage", "Lead not found or update failed!");
                        sessionVar.setAttribute("popupType", "error");
                        response.sendRedirect(sourcePage);
                    }
                }
            
            } catch (SQLException e) {
            e.printStackTrace();
            sessionVar.setAttribute("popupMessage", "Database error: " + e.getMessage());
            sessionVar.setAttribute("popupType", "error");
            response.sendRedirect("empdashboared.jsp");
        } catch (NumberFormatException e) {
            sessionVar.setAttribute("popupMessage", "Error: Invalid lead ID format.");
            sessionVar.setAttribute("popupType", "error");
            response.sendRedirect("empdashboared.jsp");
        } catch (ClassNotFoundException e) {
            sessionVar.setAttribute("popupMessage", "Database driver not found: " + e.getMessage());
            sessionVar.setAttribute("popupType", "error");
            response.sendRedirect("empdashboared.jsp");
        } catch (IllegalArgumentException e) {
            sessionVar.setAttribute("popupMessage", "Error: Invalid date format. Please use yyyy-MM-dd.");
            sessionVar.setAttribute("popupType", "error");
            response.sendRedirect("empdashboared.jsp");
        }
    }
    catch (Exception e) {
            e.printStackTrace();}
    }
}

