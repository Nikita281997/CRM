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
import java.math.BigDecimal;

@WebServlet("/editquote")
public class editquoteservlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        response.setContentType("text/html");

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
            response.sendRedirect("login1.jsp");
            return;
        }

        String quoteId = request.getParameter("quoteid");
        String leadId = request.getParameter("leadid");
        String[] srNos = request.getParameterValues("srNo[]");
        String[] descriptions = request.getParameterValues("description[]");
        String[] prices = request.getParameterValues("price[]");
        String[] descIds = request.getParameterValues("descId[]");
        String[] deleteIds = request.getParameterValues("delete[]"); // Changed from deleteSrNos to deleteIds to match checkbox
        String amountStr = request.getParameter("amount");

        if (quoteId == null || quoteId.isEmpty()) {
            out.println("<script>alert('Error: No Quote ID provided!'); window.location='quotes.jsp';</script>");
            return;
        }

        BigDecimal updatedAmount = (amountStr != null && !amountStr.isEmpty()) ? new BigDecimal(amountStr) : BigDecimal.ZERO;

        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement psFinance = null;
        PreparedStatement psDescription = null;
        ResultSet rs = null;

        try {
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);

            con.setAutoCommit(false);

            // Process deletions first
            if (deleteIds != null) {
                for (String deleteId : deleteIds) {
                    if (deleteId != null && !deleteId.isEmpty()) {
                        String deleteSql = "DELETE FROM description WHERE id=? AND lead_id=? AND company_id=?";
                        ps = con.prepareStatement(deleteSql);
                        ps.setInt(1, Integer.parseInt(deleteId));
                        ps.setInt(2, Integer.parseInt(leadId));
                        ps.setInt(3, companyId);
                        int rowsDeleted = ps.executeUpdate();
                        System.out.println("Deleted record with ID: " + deleteId + ", Rows deleted: " + rowsDeleted);
                    }
                }
            }

            String checkQuoteSql = "SELECT lead_id FROM quotation WHERE quote_id=? AND company_id=?";
            ps = con.prepareStatement(checkQuoteSql);
            ps.setInt(1, Integer.parseInt(quoteId));
            ps.setInt(2, companyId);
            rs = ps.executeQuery();

            if (rs.next()) {
                int leadIdFromQuote = rs.getInt("lead_id");

                // Update or insert descriptions
                if (srNos != null && descriptions != null && prices != null && descIds != null) {
                    for (int i = 0; i < srNos.length; i++) {
                        int srNo = Integer.parseInt(srNos[i]);
                        String description = descriptions[i];
                        BigDecimal price = new BigDecimal(prices[i]);
                        String descId = descIds[i];

                        if (descId != null && !descId.isEmpty()) {
                            // Update existing description with new sr_no
                            String updateDescSql = "UPDATE description SET sr_no=?, descriptions=?, price=? WHERE id=? AND lead_id=? AND company_id=?";
                            psDescription = con.prepareStatement(updateDescSql);
                            psDescription.setInt(1, srNo);
                            psDescription.setString(2, description);
                            psDescription.setBigDecimal(3, price);
                            psDescription.setInt(4, Integer.parseInt(descId));
                            psDescription.setInt(5, Integer.parseInt(leadId));
                            psDescription.setInt(6, companyId);
                            psDescription.executeUpdate();
                        } else {
                            // Insert new description
                            String insertDescSql = "INSERT INTO description (lead_id, company_id, sr_no, descriptions, price) VALUES (?, ?, ?, ?, ?)";
                            psDescription = con.prepareStatement(insertDescSql);
                            psDescription.setInt(1, Integer.parseInt(leadId));
                            psDescription.setInt(2, companyId);
                            psDescription.setInt(3, srNo);
                            psDescription.setString(4, description);
                            psDescription.setBigDecimal(5, price);
                            psDescription.executeUpdate();
                        }
                    }
                }

                // Resequence all records after updates
                resequenceRecords(con, Integer.parseInt(leadId), companyId);

                // Calculate the sum of prices for the specific lead_id
                String sumPriceSql = "SELECT SUM(price) as total_price FROM description WHERE lead_id=? AND company_id=?";
                ps = con.prepareStatement(sumPriceSql);
                ps.setInt(1, Integer.parseInt(leadId));
                ps.setInt(2, companyId);
                rs = ps.executeQuery();
                BigDecimal totalPrice = BigDecimal.ZERO;
                if (rs.next()) {
                    totalPrice = rs.getBigDecimal("total_price") != null ? rs.getBigDecimal("total_price") : BigDecimal.ZERO;
                }

                // Update quotation table with the new orgamt (sum of prices)
                String updateQuoteSql = "UPDATE quotation SET orgamt=? WHERE quote_id=? AND company_id=?";
                ps = con.prepareStatement(updateQuoteSql);
                ps.setBigDecimal(1, totalPrice);
                ps.setInt(2, Integer.parseInt(quoteId));
                ps.setInt(3, companyId);

                int rowsUpdated = ps.executeUpdate();

                if (rowsUpdated > 0) {
                    // Update finance table with orgamt (sum of prices)
                    String fetchFinanceSql = "SELECT quotes_values FROM financemanagement WHERE lead_id=? AND company_id=?";
                    PreparedStatement psFetch = con.prepareStatement(fetchFinanceSql);
                    psFetch.setInt(1, leadIdFromQuote);
                    psFetch.setInt(2, companyId); // Fixed the typo here: psSetInt -> psFetch.setInt
                    ResultSet rsFinance = psFetch.executeQuery();
                    BigDecimal existingQuotesValues = BigDecimal.ZERO;
                    if (rsFinance.next()) {
                        existingQuotesValues = rsFinance.getBigDecimal("quotes_values") != null ? rsFinance.getBigDecimal("quotes_values") : BigDecimal.ZERO;
                    }
                    rsFinance.close();
                    psFetch.close();

                    String updateFinanceSql = "UPDATE financemanagement SET orgamt=? WHERE lead_id=? AND company_id=?";
                    psFinance = con.prepareStatement(updateFinanceSql);
                    psFinance.setBigDecimal(1, totalPrice);
                    psFinance.setInt(2, leadIdFromQuote);
                    psFinance.setInt(3, companyId);

                    int financeResult = psFinance.executeUpdate();

                    if (financeResult > 0) {
                        con.commit();
                        out.println("<script>alert('Quote and finance updated successfully!'); window.location='quotes.jsp';</script>");
                    } else {
                        throw new SQLException("Failed to update finance record");
                    }
                } else {
                    throw new SQLException("Failed to update quote");
                }
            } else {
                throw new SQLException("No matching quote found");
            }

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            out.println("<script>alert('Error: Unable to load the database driver!'); window.location='quotes.jsp';</script>");
        } catch (SQLException e) {
            e.printStackTrace();
            try {
                con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            out.println("<script>alert('Error: Unable to execute the SQL query!'); window.location='quotes.jsp';</script>");
        } finally {
            try {
                con.setAutoCommit(true);
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (psFinance != null) psFinance.close();
                if (psDescription != null) psDescription.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private void resequenceRecords(Connection con, int leadId, int companyId) throws SQLException {
        String selectSql = "SELECT id, sr_no FROM description WHERE lead_id=? AND company_id=? ORDER BY sr_no";
        PreparedStatement psSelect = con.prepareStatement(selectSql);
        psSelect.setInt(1, leadId);
        psSelect.setInt(2, companyId);
        ResultSet rs = psSelect.executeQuery();

        int newSrNo = 1;
        while (rs.next()) {
            int id = rs.getInt("id");
            String updateSql = "UPDATE description SET sr_no=? WHERE id=? AND lead_id=? AND company_id=?";
            PreparedStatement psUpdate = con.prepareStatement(updateSql);
            psUpdate.setInt(1, newSrNo);
            psUpdate.setInt(2, id);
            psUpdate.setInt(3, leadId);
            psUpdate.setInt(4, companyId);
            psUpdate.executeUpdate();
            newSrNo++;
            psUpdate.close();
        }
        rs.close();
        psSelect.close();
    }
}