import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/registerservlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10, // 10MB
                 maxRequestSize = 1024 * 1024 * 50) // 50MB
public class registerservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
  
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String fullname = req.getParameter("fullname");
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String contact = req.getParameter("contact");
        String password = req.getParameter("password");
        String gender = req.getParameter("gender");
        String dob = req.getParameter("dob");
        String address = req.getParameter("address");
        String city = req.getParameter("city");
        String state = req.getParameter("state");
        String country = req.getParameter("country");
        String zipcode = req.getParameter("zipcode");
        
        Part filePart = req.getPart("profile_image");
        String fileName = extractFileName(filePart);
        
        // Use the real path for storing the image file
        String savePath = getServletContext().getRealPath("/") + "profile_images" + File.separator + fileName;
        
        // Create the directory if it doesn't exist
        File fileSaveDir = new File(getServletContext().getRealPath("/") + "profile_images");
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdirs();
        }

        // Save the uploaded file
        filePart.write(savePath);

        Connection con = null;
        PreparedStatement ps = null;
        int rs;
        PrintWriter out = res.getWriter();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
            String insertquery = "INSERT INTO register(fullname, username, email, contact, password, gender, dob, address, city, state, country, zipcode, profile_image) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            ps = con.prepareStatement(insertquery);
            ps.setString(1, fullname);
            ps.setString(2, username);
            ps.setString(3, email);
            ps.setString(4, contact);
            ps.setString(5, password);
            ps.setString(6, gender);
            ps.setString(7, dob);
            ps.setString(8, address);
            ps.setString(9, city);
            ps.setString(10, state);
            ps.setString(11, country);
            ps.setString(12, zipcode);
            ps.setString(13, fileName);

            rs = ps.executeUpdate();
            if (rs > 0) {
                out.println("<script>window.location='index.jsp';</script>");
            } else {
                out.println("<script>alert('Failed to register!'); window.location='register.jsp';</script>");
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String content : contentDisp.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf("=") + 2, content.length() - 1);
            }
        }
        return "";
    }
}
