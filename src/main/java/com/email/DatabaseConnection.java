package com.email;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    // Database URL, username, and password
	//"jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI"
    private static final String URL = "jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb"; // Update with your DB details
    private static final String USER = "atharva"; // Update with your DB username
    private static final String PASSWORD ="AVNS_SFoivcl39tz_B7wqssI"; // Update with your DB password

    // This method will establish and return a connection to the database
    public static Connection getConnection() {
        Connection connection = null;
        try {
            // Load the MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Create the connection
            connection = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace(); // Handle exceptions
        }
        return connection;
    }
}
