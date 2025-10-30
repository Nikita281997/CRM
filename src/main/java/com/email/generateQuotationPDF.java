package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.UnitValue;
import com.itextpdf.io.font.constants.StandardFonts;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.layout.properties.TextAlignment;

//@WebServlet("/generateQuotationPDF")
public class generateQuotationPDF extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int quoteId = Integer.parseInt(request.getParameter("quoteId"));
        
        try {
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);
            
            // Get quote details with company name and lead information
            String sql = "SELECT q.*, l.customer_name AS lead_customer_name, l.firm AS lead_firm, l.address, cr.company_name, cr.address AS cr_address, cr.website, cr.email, cr.phone_number, cr.full_name " +
                         "FROM quotation q " +
                         "JOIN leads l ON q.lead_id = l.lead_id " +
                         "JOIN company_registration1 cr ON l.company_id = cr.company_id " +
                         "WHERE q.quote_id = ?";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, quoteId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                // Get additional details from the additional table (now unused for table)
                sql = "SELECT addfeature, addrequirement, add_date, addiamt FROM additional WHERE lead_id = ? AND quote_id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, rs.getInt("lead_id"));
                ps.setInt(2, quoteId);
                ResultSet additionalRs = ps.executeQuery();
                
                String additionalFeatures = "";
                String additionalRequirements = "";
                String addDate = "";
                String addAmount = "";
                
                if (additionalRs.next()) {
                    additionalFeatures = additionalRs.getString("addfeature") != null ? additionalRs.getString("addfeature") : "";
                    additionalRequirements = additionalRs.getString("addrequirement") != null ? additionalRs.getString("addrequirement") : "";
                    addDate = additionalRs.getString("add_date") != null ? additionalRs.getString("add_date") : "";
                    addAmount = additionalRs.getString("addiamt") != null ? additionalRs.getString("addiamt") : "";
                }
                
                // Create PDF document
                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "inline; filename=quotation_" + quoteId + ".pdf");
                
                PdfWriter writer = new PdfWriter(response.getOutputStream());
                PdfDocument pdf = new PdfDocument(writer);
                Document document = new Document(pdf);
                
                // Add content to PDF
                PdfFont boldFont = PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD);
                PdfFont normalFont = PdfFontFactory.createFont(StandardFonts.HELVETICA);
                
                // Title
                Paragraph title = new Paragraph("QUOTATION");
                title.setFont(boldFont);
                title.setFontSize(18);
                title.setTextAlignment(TextAlignment.CENTER);
                document.add(title);
                document.add(new Paragraph(" "));
                
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
                
                // Use lead_customer_name instead of customer_name
                String customerName = rs.getString("lead_customer_name") != null ? rs.getString("lead_customer_name") : "";
                Paragraph clientNamePara = new Paragraph("Client Name: " + customerName);
                clientNamePara.setFont(normalFont);
                clientNamePara.setFontSize(12);
                document.add(clientNamePara);
                
                // Use lead_firm instead of firm
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
                
                // Quotation details section
                Paragraph quoteDetailsTitle = new Paragraph("Quotation Details:").setFont(boldFont).setFontSize(12);
                document.add(quoteDetailsTitle);
                
                // Add requirement from quotation table
                if (rs.getString("requirement") != null && !rs.getString("requirement").isEmpty()) {
                    Paragraph requirementPara = new Paragraph("Requirement: " + rs.getString("requirement")).setFont(normalFont).setFontSize(12);
                    document.add(requirementPara);
                }
                
                // Add feature from quotation table
                if (rs.getString("feature") != null && !rs.getString("feature").isEmpty()) {
                    Paragraph featurePara = new Paragraph("Feature: " + rs.getString("feature")).setFont(normalFont).setFontSize(12);
                    document.add(featurePara);
                }
                
                // Add amount from quotation table
                if (rs.getString("orgamt") != null) {
                    Paragraph amountPara = new Paragraph("Deal Closed At :" + rs.getString("orgamt")).setFont(normalFont).setFontSize(12);
                    document.add(amountPara);
                }
                
                // Add original quotation date from quotation table
                if (rs.getString("quotation_date") != null) {
                    Paragraph quoteDatePara = new Paragraph("Quotation Date: " + rs.getString("quotation_date")).setFont(normalFont).setFontSize(12);
                    document.add(quoteDatePara);
                }
                
                document.add(new Paragraph(" "));
                
                // New table based on description table
                sql = "SELECT sr_no, descriptions, price FROM description WHERE lead_id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, rs.getInt("lead_id"));
                ResultSet descriptionRs = ps.executeQuery();
                
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
                
                document.add(new Paragraph(" "));
                
                // Terms & Conditions (moved below the table)
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
                
                document.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}