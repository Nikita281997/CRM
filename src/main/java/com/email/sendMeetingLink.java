package com.email;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import com.email.EmailSender;

public class sendMeetingLink extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");

        // Generate a random meeting room name (you can replace this with a custom name)
        String meetingRoom = "Meeting_" + System.currentTimeMillis();
        String meetingLink = "https://meet.jit.si/" + meetingRoom;

        try {
            // Send email with the Jitsi meeting link
            EmailSender.sendEmail(email, "Your Video Meeting Link", "Click here to join the meeting: " + meetingLink);
            response.sendRedirect("meetingPage.jsp?meetingLink=" + meetingLink);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error sending email.");
        }
    }
}