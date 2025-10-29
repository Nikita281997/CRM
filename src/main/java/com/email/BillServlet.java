package com.email;

import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.UnitValue;
import com.itextpdf.io.font.constants.StandardFonts;
import com.itextpdf.layout.properties.TextAlignment;
import java.text.SimpleDateFormat;
import java.util.Date;

public class BillServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Set content type at the beginning
        response.setContentType("application/pdf");
        OutputStream out = null;
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            // Get session and company_id
            HttpSession session = request.getSession();
            String companyIdStr = (String) session.getAttribute("company_id");
            Integer companyId = null;

            if (companyIdStr != null) {
                try {
                    companyId = Integer.parseInt(companyIdStr);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                    throw new ServletException("Invalid company ID format");
                }
            }

            // Redirect if company_id is missing
            if (companyId == null) {
                response.sendRedirect("login1.jsp");
                return;
            }

            int leadId;
            try {
                leadId = Integer.parseInt(request.getParameter("leadId"));
            } catch (NumberFormatException e) {
                response.setContentType("text/html");
                response.getWriter().println("<script>alert('Invalid Lead ID'); window.history.back();</script>");
                return;
            }

            // Get balance from request parameter
            String balanceStr = request.getParameter("balance");
            BigDecimal balance = (balanceStr != null && !balanceStr.isEmpty()) ? new BigDecimal(balanceStr.replace(",", "")) : BigDecimal.ZERO;

            response.setHeader("Content-Disposition", "attachment; filename=Bill_Lead_" + leadId + ".pdf");
            
            // Get output stream
            out = response.getOutputStream();
            
            // Create PDF objects
            PdfWriter writer = new PdfWriter(out);
            PdfDocument pdfDoc = new PdfDocument(writer);
            Document document = new Document(pdfDoc);

            // Load fonts
            PdfFont boldFont = PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD);
            PdfFont normalFont = PdfFontFactory.createFont(StandardFonts.HELVETICA);

            // Title
            Paragraph title = new Paragraph("CUSTOMER BILL");
            title.setFont(boldFont);
            title.setFontSize(18);
            title.setTextAlignment(TextAlignment.CENTER);
            document.add(title);
            document.add(new Paragraph(" "));

            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            // Fetch company and lead details
            String sql = "SELECT fm.*, l.customer_name AS lead_customer_name, l.firm AS lead_firm, l.address, " +
                         "cr.company_name, cr.address AS cr_address, cr.website, cr.email, cr.phone_number, cr.full_name " +
                         "FROM financemanagement fm " +
                         "JOIN leads l ON fm.lead_id = l.lead_id " +
                         "JOIN company_registration1 cr ON l.company_id = cr.company_id " +
                         "WHERE fm.lead_id = ? AND fm.company_id = ?";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, leadId);
            ps.setInt(2, companyId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                // Company details
                Paragraph companyPara = new Paragraph("Company: " + rs.getString("company_name"));
                companyPara.setFont(boldFont);
                companyPara.setFontSize(12);
                document.add(companyPara);
                
                Paragraph addressPara = new Paragraph("Address: " + rs.getString("cr_address"));
                addressPara.setFont(normalFont);
                addressPara.setFontSize(12);
                document.add(addressPara);
                
                Paragraph phonePara = new Paragraph("Phone: " + rs.getString("phone_number"));
                phonePara.setFont(normalFont);
                phonePara.setFontSize(12);
                document.add(phonePara);
                
                Paragraph emailPara = new Paragraph("Email: " + rs.getString("email"));
                emailPara.setFont(normalFont);
                emailPara.setFontSize(12);
                document.add(emailPara);
                
                Paragraph websitePara = new Paragraph("Website: " + rs.getString("website"));
                websitePara.setFont(normalFont);
                websitePara.setFontSize(12);
                document.add(websitePara);
                
                // Get current system date
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                String currentDate = dateFormat.format(new Date());
                
                Paragraph datePara = new Paragraph("Date: " + currentDate);
                datePara.setFont(normalFont);
                datePara.setFontSize(12);
                document.add(datePara);
                
                document.add(new Paragraph(" "));
                
                // To section - using lead_customer_name and lead_firm from leads table
                Paragraph toPara = new Paragraph("To:");
                toPara.setFont(boldFont);
                toPara.setFontSize(12);
                document.add(toPara);
                
                String customerName = rs.getString("lead_customer_name") != null ? rs.getString("lead_customer_name") : "";
                Paragraph clientNamePara = new Paragraph("Client Name: " + customerName);
                clientNamePara.setFont(normalFont);
                clientNamePara.setFontSize(12);
                document.add(clientNamePara);
                
                String firmName = rs.getString("lead_firm") != null ? rs.getString("lead_firm") : "";
                Paragraph firmPara = new Paragraph("Firm: " + firmName);
                firmPara.setFont(normalFont);
                firmPara.setFontSize(12);
                document.add(firmPara);
                
                Paragraph clientAddressPara = new Paragraph("Address: " + rs.getString("address"));
                clientAddressPara.setFont(normalFont);
                clientAddressPara.setFontSize(12);
                document.add(clientAddressPara);
                
                document.add(new Paragraph(" "));
                
                // Bill Details section
                Paragraph billDetailsTitle = new Paragraph("Bill Details:").setFont(boldFont).setFontSize(12);
                document.add(billDetailsTitle);
                
                // Add project name and due date from financemanagement and project tables
                Paragraph projectNamePara = new Paragraph("Project Name: " + (rs.getString("project_name") != null ? rs.getString("project_name") : "N/A")).setFont(normalFont).setFontSize(12);
                document.add(projectNamePara);
                
                // Fetch due date from project table
                String dueDateSql = "SELECT due_date FROM project WHERE lead_id = ? AND company_id = ?";
                PreparedStatement dueDatePs = con.prepareStatement(dueDateSql);
                dueDatePs.setInt(1, leadId);
                dueDatePs.setInt(2, companyId);
                ResultSet dueDateRs = dueDatePs.executeQuery();
                String dueDate = "N/A";
                if (dueDateRs.next()) {
                    dueDate = dueDateRs.getString("due_date") != null ? dueDateRs.getString("due_date") : "N/A";
                }
                Paragraph dueDatePara = new Paragraph("Due Date: " + dueDate).setFont(normalFont).setFontSize(12);
                document.add(dueDatePara);
                
                dueDateRs.close();
                dueDatePs.close();
                
                document.add(new Paragraph(" "));
                
                // Table for description data
                String descriptionSql = "SELECT sr_no, descriptions, price FROM description WHERE lead_id = ?";
                ps = con.prepareStatement(descriptionSql);
                ps.setInt(1, leadId);
                ResultSet descriptionRs = ps.executeQuery();
                // Add amount from quotation table
                if (rs.getString("orgamt") != null) {
                    Paragraph amountPara = new Paragraph("Deal Closed At : " + rs.getString("orgamt")).setFont(normalFont).setFontSize(12);
                    document.add(amountPara);
                }
                
                if (descriptionRs.next()) {
                    Table descriptionTable = new Table(UnitValue.createPercentArray(new float[]{1, 2, 1}));
                    descriptionTable.setWidth(UnitValue.createPercentValue(100));
                    
                    descriptionTable.addCell(new Paragraph("Sr No").setFont(boldFont));
                    descriptionTable.addCell(new Paragraph("Descriptions").setFont(boldFont));
                    descriptionTable.addCell(new Paragraph("Price").setFont(boldFont));
                    
                    do {
                        descriptionTable.addCell(new Paragraph(descriptionRs.getString("sr_no") != null ? descriptionRs.getString("sr_no") : "").setFont(normalFont));
                        descriptionTable.addCell(new Paragraph(descriptionRs.getString("descriptions") != null ? descriptionRs.getString("descriptions") : "").setFont(normalFont));
                        descriptionTable.addCell(new Paragraph(descriptionRs.getString("price") != null ? descriptionRs.getString("price") : "").setFont(normalFont));
                    } while (descriptionRs.next());
                    
                    document.add(descriptionTable);
                }
                descriptionRs.close();
                
                document.add(new Paragraph(" "));
                
                // Financial Details section with balance from request parameter
                Paragraph financeDetailsTitle = new Paragraph("Financial Details:").setFont(boldFont).setFontSize(12);
                document.add(financeDetailsTitle);
                
                Table financeTable = new Table(UnitValue.createPercentArray(new float[]{2, 1, 1}));
                financeTable.setWidth(UnitValue.createPercentValue(100));
                
                financeTable.addCell(new Paragraph("Field").setFont(boldFont));
                financeTable.addCell(new Paragraph("Value").setFont(boldFont));
                financeTable.addCell(new Paragraph("Date").setFont(boldFont));
                
                // Installment 1
                financeTable.addCell(new Paragraph("Installment 1 (Advance Payment)").setFont(normalFont));
                financeTable.addCell(new Paragraph(rs.getString("installment1") != null ? rs.getString("installment1") : "0.00").setFont(normalFont));
                financeTable.addCell(new Paragraph(rs.getString("date1") != null ? rs.getString("date1") : "N/A").setFont(normalFont));
                
                // Installment 2
                financeTable.addCell(new Paragraph("Installment 2 (Mid Payment)").setFont(normalFont));
                financeTable.addCell(new Paragraph(rs.getString("installment2") != null ? rs.getString("installment2") : "0.00").setFont(normalFont));
                financeTable.addCell(new Paragraph(rs.getString("date2") != null ? rs.getString("date2") : "N/A").setFont(normalFont));
                
                // Installment 3 with history
                String installment3Sql = "SELECT amount, date3 FROM installment3_logs WHERE finance_id = ? ORDER BY date3 ASC";
                PreparedStatement installment3Ps = con.prepareStatement(installment3Sql);
                installment3Ps.setInt(1, leadId);
                ResultSet installment3Rs = installment3Ps.executeQuery();
                StringBuilder installment3Values = new StringBuilder();
                StringBuilder installment3Dates = new StringBuilder();
                double totalInstallment3 = 0.0;
                while (installment3Rs.next()) {
                    String amount = installment3Rs.getString("amount") != null ? installment3Rs.getString("amount") : "0.00";
                    String date = installment3Rs.getString("date3") != null ? installment3Rs.getString("date3") : "N/A";
                    installment3Values.append(amount).append("\n");
                    installment3Dates.append(date).append("\n");
                    totalInstallment3 += Double.parseDouble(amount);
                }
                installment3Rs.close();
                installment3Ps.close();
                
                financeTable.addCell(new Paragraph("Installment 3 (Final Payment) History").setFont(normalFont));
                financeTable.addCell(new Paragraph(installment3Values.length() > 0 ? installment3Values.toString() : "0.00").setFont(normalFont));
                financeTable.addCell(new Paragraph(installment3Dates.length() > 0 ? installment3Dates.toString() : "N/A").setFont(normalFont));
                
                // Add total for Installment 3
                financeTable.addCell(new Paragraph("Installment 3 Total").setFont(normalFont));
                financeTable.addCell(new Paragraph(String.format("%.2f", totalInstallment3)).setFont(normalFont));
                financeTable.addCell(new Paragraph("N/A").setFont(normalFont));
                
                // Final Value
                financeTable.addCell(new Paragraph("Final Value").setFont(normalFont));
                financeTable.addCell(new Paragraph(rs.getString("orgamt") != null ? rs.getString("orgamt") : "0.00").setFont(normalFont));
                financeTable.addCell(new Paragraph("N/A").setFont(normalFont));
                
                // Balance
                financeTable.addCell(new Paragraph("Balance").setFont(normalFont));
                financeTable.addCell(new Paragraph(String.format("%,.2f", balance)).setFont(normalFont));
                financeTable.addCell(new Paragraph("N/A").setFont(normalFont));
                
                // Status - Updated logic
                String status = balance.compareTo(BigDecimal.ZERO) == 0 ? "Completed" : "Pending";
                financeTable.addCell(new Paragraph("Status").setFont(normalFont));
                financeTable.addCell(new Paragraph(status).setFont(normalFont));
                financeTable.addCell(new Paragraph("N/A").setFont(normalFont));
                
                document.add(financeTable);
                
                document.add(new Paragraph(" "));
                
                // Terms & Conditions
                Paragraph termsTitle = new Paragraph("Terms & Conditions:").setFont(boldFont).setFontSize(12);
                document.add(termsTitle);
                
                Paragraph term1 = new Paragraph("1. Payment due within 15 days from the invoice date.").setFont(normalFont).setFontSize(12);
                document.add(term1);
                
                Paragraph term3 = new Paragraph("2. Work will commence after 50% advance payment.").setFont(normalFont).setFontSize(12);
                document.add(term3);
                
                document.add(new Paragraph(" "));
                
                // Authorized Signatory
                Paragraph signTitle = new Paragraph("Authorized Signatory").setFont(boldFont).setFontSize(12);
                document.add(signTitle);
                
                Paragraph signName = new Paragraph(rs.getString("full_name")).setFont(normalFont).setFontSize(12);
                document.add(signName);
                
                Paragraph designation = new Paragraph("CEO").setFont(normalFont).setFontSize(12);
                document.add(designation);
                
                Paragraph signature = new Paragraph("Signature").setFont(normalFont).setFontSize(12);
                document.add(signature);
                
                // Make sure to flush and close in correct order
                document.flush();
                document.close();
                pdfDoc.close();
                writer.close();
            } else {
                document.add(new Paragraph("No data found for Lead ID: " + leadId + " or unauthorized access."));
                document.flush();
                document.close();
                pdfDoc.close();
                writer.close();
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("PDF Generation Error: " + e.getMessage());
            
            // Reset response to send error message
            response.reset();
            response.setContentType("text/html");
            response.getWriter().println("<script>alert('Error generating PDF: " + 
                e.getMessage().replace("'", "\\'") + "'); window.history.back();</script>");
        } finally {
            // Close database resources
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}