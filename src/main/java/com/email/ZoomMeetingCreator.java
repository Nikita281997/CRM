package com.email;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import javax.net.ssl.HttpsURLConnection;

public class ZoomMeetingCreator {

    public static String createZoomMeeting(String accessToken) throws Exception {
        URL url = new URL("https://api.zoom.us/v2/users/me/meetings");
        HttpsURLConnection connection = (HttpsURLConnection) url.openConnection();

        // Set the method and headers
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setDoOutput(true);

        // Request body
        String jsonInputString = "{"
                + "\"topic\": \"Your Meeting Title\","
                + "\"type\": 2,"
                + "\"start_time\": \"2025-02-13T15:00:00Z\","
                + "\"duration\": 30,"
                + "\"timezone\": \"Asia/Kolkata\","
                + "\"agenda\": \"Discuss project updates\","
                + "\"settings\": {"
                + "\"host_video\": true,"
                + "\"participant_video\": true,"
                + "\"audio\": \"voip\","
                + "\"auto_recording\": \"none\""
                + "}"
                + "}";

        // Send the POST request
        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = jsonInputString.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        // Get the response
        int responseCode = connection.getResponseCode();
        if (responseCode == HttpsURLConnection.HTTP_OK) {
            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String inputLine;
            StringBuffer response = new StringBuffer();
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();
            // Return the meeting link from the response
            return response.toString();
        } else {
            return "Failed to create meeting, response code: " + responseCode;
        }
    }
}
