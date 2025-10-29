package com.email;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

public class VerifyOtpServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int enteredOtp = Integer.parseInt(request.getParameter("otp"));
        HttpSession session = request.getSession();
        int correctOtp = (int) session.getAttribute("otp");

        if (enteredOtp == correctOtp) {
            session.setAttribute("authenticatedUser", session.getAttribute("userEmail"));
            response.sendRedirect("Dashboard.jsp");
        } else {
            response.getWriter().println("Invalid OTP. Try again.");
        }
    }
}
