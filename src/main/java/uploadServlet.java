import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@MultipartConfig
public class uploadServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Part filePart = request.getPart("profileImage");
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

        // Define the upload directory using the real path
        String uploadPath = getServletContext().getRealPath("/") + "profile_images";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // Save file to server
        File file = new File(uploadPath, fileName);
        filePart.write(file.getAbsolutePath());

        // Update the database
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
            PreparedStatement ps = con.prepareStatement("UPDATE register SET profile_image=? WHERE username='someuser'");
            ps.setString(1, fileName);
            ps.executeUpdate();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        response.sendRedirect("profile.jsp"); // Reload the profile page
    }
}
