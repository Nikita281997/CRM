
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Servlet implementation class loginServlet
 */
public class loginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		Connection con = null;
		PreparedStatement ps = null;
		try {

			Class.forName("com.mysql.cj.jdbc.Driver");
			String host = System.getenv("DB_HOST");
			String port = System.getenv("DB_PORT");
			String dbName = System.getenv("DB_NAME");
			String user = System.getenv("DB_USER");
			String pass = System.getenv("DB_PASS");

			String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;

			con = DriverManager.getConnection(url, user, pass);

			String loginquery = "select username,password from register where username=? and password=?";
			ps = con.prepareStatement(loginquery);
			ps.setString(1, username);
			ps.setString(2, password);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				out.println("<script> window.location='leads.jsp';</script>");
			} else {
				out.println("<script>alert('Failed login,Try again'); window.location='index.jsp';</script>");
			}
		} catch (ClassNotFoundException | SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

}
