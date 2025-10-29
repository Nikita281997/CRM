package com.email;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;
import org.json.JSONObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

public class GoogleOAuthServlet extends HttpServlet {
    private static final String CLIENT_ID = "39424492315-nunqj04c49dn2iddl9c006eo8jhj86ss.apps.googleusercontent.com";
    private static final String CLIENT_SECRET = "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";
    private static final String REDIRECT_URI = "http://localhost:8080/emailCrm/GoogleOAuthServlet";
    private static final String TOKEN_URL = "https://oauth2.googleapis.com/token";
    private static final String USER_INFO_URL = "https://www.googleapis.com/oauth2/v2/userinfo";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String code = request.getParameter("code");

        if (code == null) {
            // Redirect user to Google OAuth authentication first
            String authUrl = "https://accounts.google.com/o/oauth2/auth?"
                    + "client_id=" + CLIENT_ID
                    + "&redirect_uri=" + REDIRECT_URI
                    + "&response_type=code"
                    + "&scope=email%20profile"
                    + "&access_type=online"
                    + "&prompt=consent";

            response.sendRedirect(authUrl);
        } else {
            // Exchange authorization code for access token
            String accessToken = getAccessToken(code);
            if (accessToken != null) {
                JSONObject userDetails = getUserInfo(accessToken);
                if (userDetails != null) {
                    String email = userDetails.getString("email");
                    String name = userDetails.getString("name");
                    String oauthId = userDetails.getString("id");

                    // Redirect to auth.jsp to store details in the database
                    response.sendRedirect("auth.jsp?email=" + email + "&name=" + name + "&oauth_id=" + oauthId);
                } else {
                    response.getWriter().println("Failed to retrieve user details.");
                }
            } else {
                response.getWriter().println("Failed to get access token.");
            }
        }
    }

    private String getAccessToken(String code) throws IOException {
        URL url = new URL(TOKEN_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);

        String requestBody = "client_id=" + CLIENT_ID +
                             "&client_secret=" + CLIENT_SECRET +
                             "&code=" + code +
                             "&grant_type=authorization_code" +
                             "&redirect_uri=" + REDIRECT_URI;

        try (OutputStream os = conn.getOutputStream()) {
            os.write(requestBody.getBytes(StandardCharsets.UTF_8));
        }

        int responseCode = conn.getResponseCode();
        if (responseCode == 200) {
            Scanner scanner = new Scanner(conn.getInputStream(), StandardCharsets.UTF_8);
            String responseText = scanner.useDelimiter("\\A").next();
            scanner.close();

            JSONObject json = new JSONObject(responseText);
            return json.getString("access_token");
        }
        return null;
    }

    private JSONObject getUserInfo(String accessToken) throws IOException {
        URL url = new URL(USER_INFO_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);

        int responseCode = conn.getResponseCode();
        if (responseCode == 200) {
            Scanner scanner = new Scanner(conn.getInputStream(), StandardCharsets.UTF_8);
            String responseText = scanner.useDelimiter("\\A").next();
            scanner.close();

            return new JSONObject(responseText);
        }
        return null;
    }
}
