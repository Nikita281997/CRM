package com.email;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class DeleteTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String source = request.getParameter("source");
        int taskId = Integer.parseInt(request.getParameter("task_id"));

        Connection con = null;
        PreparedStatement pst = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            String tableName;
            switch (source) {
                case "open":
                    tableName = "open_tasks";
                    break;
                case "in_progress":
                    tableName = "in_progress_tasks";
                    break;
                case "completed":
                    tableName = "completed_tasks";
                    break;
                default:
                    throw new IllegalArgumentException("Invalid source: " + source);
            }

            String query = "DELETE FROM " + tableName + " WHERE task_id = ?";
            pst = con.prepareStatement(query);
            pst.setInt(1, taskId);

            int rowsAffected = pst.executeUpdate();
            if (rowsAffected > 0) {
                response.sendRedirect("tasks.jsp");
            } else {
                response.getWriter().println("Error: Task not found or could not be deleted.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error deleting task: " + e.getMessage());
        } finally {
            try {
                if (pst != null) pst.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}