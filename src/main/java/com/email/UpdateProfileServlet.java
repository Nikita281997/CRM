package com.email;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.json.JSONObject;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

//@WebServlet("/UpdateProfileServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class UpdateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIRECTORY = "uploads";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject jsonResponse = new JSONObject();
        
        // Log incoming request parameters
        System.out.println("UpdateProfileServlet: Received POST request");
        System.out.println("Parameters:");
        request.getParameterMap().forEach((key, value) -> 
            System.out.println(key + ": " + String.join(", ", value)));

        // Get parameters
        String companyIdStr = request.getParameter("company_id");
        String fullName = request.getParameter("full_name");
        String companyName = request.getParameter("company_name");
        String phoneNumber = request.getParameter("phone_number");
        String companySize = request.getParameter("company_size");
        String address = request.getParameter("address");
        String website = request.getParameter("website");

        if (companyIdStr == null || fullName == null || companyName == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Missing required fields");
            System.out.println("UpdateProfileServlet: Missing required fields");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        int companyId;
        try {
            companyId = Integer.parseInt(companyIdStr);
        } catch (NumberFormatException e) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Invalid company ID");
            System.out.println("UpdateProfileServlet: Invalid company ID - " + e.getMessage());
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        // Handle file upload
        Part filePart = request.getPart("profile_photo");
        String filePath = null;
        String oldFilePath = null;

        // Database connection
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
            System.out.println("UpdateProfileServlet: Database connection established");

            // Get the old image path
            String selectSql = "SELECT img FROM company_registration1 WHERE company_id = ?";
            try (PreparedStatement selectPs = con.prepareStatement(selectSql)) {
                selectPs.setInt(1, companyId);
                ResultSet rs = selectPs.executeQuery();
                if (rs.next()) {
                    oldFilePath = rs.getString("img");
                    System.out.println("UpdateProfileServlet: Old image path - " + oldFilePath);
                }
            }

            // Handle file upload if present
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = extractFileName(filePart);
                if (!fileName.isEmpty()) {
                    String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
                    String uniqueFileName = timestamp + "_" + fileName;

                    String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIRECTORY;
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdir();
                        System.out.println("UpdateProfileServlet: Created upload directory - " + uploadPath);
                    }

                    filePath = UPLOAD_DIRECTORY + File.separator + uniqueFileName;
                    String fullFilePath = uploadPath + File.separator + uniqueFileName;
                    filePart.write(fullFilePath);
                    System.out.println("UpdateProfileServlet: New image saved - " + fullFilePath);
                }
            }

            // Update the database
            String sql = "UPDATE company_registration1 SET full_name = ?, company_name = ?, phone_number = ?, company_size = ?, address = ?, website = ?, img = COALESCE(?, img) WHERE company_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, fullName);
                ps.setString(2, companyName);
                ps.setString(3, phoneNumber != null && !phoneNumber.isEmpty() ? phoneNumber : null);
                ps.setString(4, companySize != null && !companySize.isEmpty() ? companySize : null);
                ps.setString(5, address != null && !address.isEmpty() ? address : null);
                ps.setString(6, website != null && !website.isEmpty() ? website : null);
                ps.setString(7, filePath);
                ps.setInt(8, companyId);

                int rowsUpdated = ps.executeUpdate();
                System.out.println("UpdateProfileServlet: Rows updated - " + rowsUpdated);
                if (rowsUpdated > 0) {
                    if (filePath != null && oldFilePath != null && !oldFilePath.isEmpty()) {
                        File oldFile = new File(getServletContext().getRealPath("") + File.separator + oldFilePath);
                        if (oldFile.exists()) {
                            oldFile.delete();
                            System.out.println("UpdateProfileServlet: Deleted old image - " + oldFilePath);
                        }
                    }
                    jsonResponse.put("success", true);
                    jsonResponse.put("message", "Profile updated successfully");
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "No company found with the given ID");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Database error: " + e.getMessage());
            System.out.println("UpdateProfileServlet: Database error - " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Server error: " + e.getMessage());
            System.out.println("UpdateProfileServlet: Server error - " + e.getMessage());
        } finally {
            if (con != null) {
                try {
                    con.close();
                    System.out.println("UpdateProfileServlet: Database connection closed");
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        response.getWriter().write(jsonResponse.toString());
        System.out.println("UpdateProfileServlet: Response sent - " + jsonResponse.toString());
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }
}