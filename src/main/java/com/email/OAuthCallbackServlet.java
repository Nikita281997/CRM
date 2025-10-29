package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import org.json.JSONObject;

public class OAuthCallbackServlet extends HttpServlet {
    private static final String CLIENT_ID = "your-google-client-id";
    private static final String CLIENT_SECRET = "your-google-client-secret";
    private static final String REDIRECT_URI = "http://localhost:8080/oauth2callback";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String code = request.getParameter("code");
        String state = request.getParameter("state");

        // Parse state parameter to get company_id and unique_id (if present)
        String companyId = null;
        String uniqueId = null;
        if (state != null && !state.isEmpty()) {
            JSONObject stateJson = new JSONObject(new String(java.util.Base64.getDecoder().decode(state)));
            companyId = stateJson.optString("company_id");
            uniqueId = stateJson.optString("unique_id");
        }

        if (code != null) {
            // Exchange authorization code for access token
            String tokenUrl = "https://oauth2.googleapis.com/token";
            String params = "code=" + code +
                    "&client_id=" + CLIENT_ID +
                    "&client_secret=" + CLIENT_SECRET +
                    "&redirect_uri=" + REDIRECT_URI +
                    "&grant_type=authorization_code";

            URL url = new URL(tokenUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            try (OutputStream os = conn.getOutputStream()) {
                os.write(params.getBytes());
                os.flush();
            }

            BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            StringBuilder responseData = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                responseData.append(line);
            }
            br.close();

            JSONObject json = new JSONObject(responseData.toString());
            String accessToken = json.getString("access_token");
            String refreshToken = json.optString("refresh_token");
            long expiresIn = json.getLong("expires_in");

            // Calculate token expiry
            LocalDateTime expiryTime = LocalDateTime.now().plusSeconds(expiresIn);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            String tokenExpiry = expiryTime.format(formatter);

            // Get user email using the access token
            String userInfoUrl = "https://www.googleapis.com/oauth2/v2/userinfo";
            URL userInfoUrlObj = new URL(userInfoUrl);
            HttpURLConnection userInfoConn = (HttpURLConnection) userInfoUrlObj.openConnection();
            userInfoConn.setRequestProperty("Authorization", "Bearer " + accessToken);
            BufferedReader userInfoReader = new BufferedReader(new InputStreamReader(userInfoConn.getInputStream()));
            StringBuilder userInfoData = new StringBuilder();
            while ((line = userInfoReader.readLine()) != null) {
                userInfoData.append(line);
            }
            userInfoReader.close();

            JSONObject userInfoJson = new JSONObject(userInfoData.toString());
            String email = userInfoJson.getString("email");

            // Store in mail_table
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

                // Check if email already exists in mail_table
                String checkSql = "SELECT COUNT(*) FROM mail_table WHERE email = ?";
                PreparedStatement checkPs = con.prepareStatement(checkSql);
                checkPs.setString(1, email);
                ResultSet rs = checkPs.executeQuery();
                rs.next();
                int count = rs.getInt(1);

                if (count > 0) {
                    // Update existing record
                    String updateSql = "UPDATE mail_table SET access_token = ?, refresh_token = ?, token_expiry = ?, company_id = ?, unique_id = ? WHERE email = ?";
                    PreparedStatement updatePs = con.prepareStatement(updateSql);
                    updatePs.setString(1, accessToken);
                    updatePs.setString(2, refreshToken);
                    updatePs.setString(3, tokenExpiry);
                    if (companyId != null && !companyId.isEmpty()) {
                        updatePs.setInt(4, Integer.parseInt(companyId));
                    } else {
                        updatePs.setNull(4, java.sql.Types.INTEGER);
                    }
                    if (uniqueId != null && !uniqueId.isEmpty()) {
                        updatePs.setInt(5, Integer.parseInt(uniqueId));
                    } else {
                        updatePs.setNull(5, java.sql.Types.INTEGER);
                    }
                    updatePs.setString(6, email);
                    updatePs.executeUpdate();
                } else {
                    // Insert new record
                    String insertSql = "INSERT INTO mail_table (email, access_token, refresh_token, token_expiry, company_id, unique_id) VALUES (?, ?, ?, ?, ?, ?)";
                    PreparedStatement insertPs = con.prepareStatement(insertSql);
                    insertPs.setString(1, email);
                    insertPs.setString(2, accessToken);
                    insertPs.setString(3, refreshToken);
                    insertPs.setString(4, tokenExpiry);
                    if (companyId != null && !companyId.isEmpty()) {
                        insertPs.setInt(5, Integer.parseInt(companyId));
                    } else {
                        insertPs.setNull(5, java.sql.Types.INTEGER);
                    }
                    if (uniqueId != null && !uniqueId.isEmpty()) {
                        insertPs.setInt(6, Integer.parseInt(uniqueId));
                    } else {
                        insertPs.setNull(6, java.sql.Types.INTEGER);
                    }
                    insertPs.executeUpdate();
                }

                con.close();
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("error.jsp");
                return;
            }

            // Store email in session for later use
            request.getSession().setAttribute("user_email", email);

            // Redirect to company registration or dashboard
            if (companyId == null || companyId.isEmpty()) {
                response.sendRedirect("dashregister.jsp");
            } else {
                response.sendRedirect("dashadminLogin.jsp");
            }
        } else {
            response.sendRedirect("error.jsp");
        }
    }
}