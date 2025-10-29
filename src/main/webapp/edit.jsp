<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
    String quoteId = request.getParameter("quoteId");
    String leadId = request.getParameter("leadId");
    BigDecimal previousTotalAmount = BigDecimal.ZERO;
    int maxSrNo = 0;

    HttpSession sessionVar = request.getSession();
    String companyIdStr = (String) sessionVar.getAttribute("company_id");
    Integer companyId = null;
    if (companyIdStr != null) {
        try {
            companyId = Integer.parseInt(companyIdStr);
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
    }

    if (companyId == null) {
        response.sendRedirect("login1.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

        // Get the maximum sr_no for this lead
        String maxSrQuery = "SELECT MAX(sr_no) FROM description WHERE lead_id = ? AND company_id = ?";
        ps = con.prepareStatement(maxSrQuery);
        ps.setInt(1, Integer.parseInt(leadId));
        ps.setInt(2, companyId);
        rs = ps.executeQuery();
        if (rs.next()) {
            maxSrNo = rs.getInt(1);
        }

        // Calculate the previous total amount from existing descriptions
        String amountQuery = "SELECT SUM(price) as total FROM description WHERE lead_id = ? AND company_id = ?";
        ps = con.prepareStatement(amountQuery);
        ps.setInt(1, Integer.parseInt(leadId));
        ps.setInt(2, companyId);
        rs = ps.executeQuery();
        if (rs.next()) {
            previousTotalAmount = rs.getBigDecimal("total") != null ? rs.getBigDecimal("total") : BigDecimal.ZERO;
        }

        // Fetch existing descriptions
        String descQuery = "SELECT id, sr_no, descriptions, price FROM description WHERE lead_id = ? AND company_id = ? ORDER BY sr_no";
        ps = con.prepareStatement(descQuery);
        ps.setInt(1, Integer.parseInt(leadId));
        ps.setInt(2, companyId);
        rs = ps.executeQuery();
%>
<div class="modal-header">
    <h2>Edit Quote</h2>
    <button class="close-btn" onclick="closeedit()">×</button>
</div>
<form action="editquote" method="post" onsubmit="return validateSrNoSequence(event)">
    <input type="hidden" name="quoteid" value="<%= quoteId %>">
    <input type="hidden" name="leadid" value="<%= leadId %>">
    <div class="form-group">
        <h3>Descriptions</h3>
        <table class="description-table" id="editDescriptionTable">
            <thead>
                <tr>
                    <th style="width: 10%;">Sr. No</th>
                    <th style="width: 60%;">Description</th>
                    <th style="width: 20%;">Price</th>
                    <th style="width: 10%;">Action</th>
                </tr>
            </thead>
            <tbody id="editDescriptionRows">
                <%
                    while (rs.next()) {
                        int id = rs.getInt("id");
                        int srNo = rs.getInt("sr_no");
                        String description = rs.getString("descriptions");
                        BigDecimal price = rs.getBigDecimal("price");
                %>
                <tr>
                    <td><input type="number" name="srNo[]" value="<%= srNo %>" min="1" class="sr-no-input" required></td>
                    <td><input type="text" name="description[]" value="<%= description != null ? description : "" %>" placeholder="Enter description" required></td>
                    <td><input type="number" name="price[]" value="<%= price != null ? price : "0.00" %>" placeholder="Enter price" step="0.01" min="0" required oninput="calculateEditTotal()"></td>
                    <td class="action-cell">
                        <input type="hidden" name="descId[]" value="<%= id %>">
                        <input type="checkbox" name="delete[]" value="<%= id %>" class="delete-checkbox"> Delete
                    </td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        <button type="button" class="btn btn-primary" id="addEditRowBtn">
            <i class="fas fa-plus"></i> Add Row
        </button>
    </div>
    <div class="form-group">
        <label>Previous Total Amount:</label>
        <span class="total-amount"><%= previousTotalAmount %></span>
    </div>
    <div class="form-group">
        <label>New Additional Amount:</label>
        <span class="total-amount" id="editAdditionalAmount">0.00</span>
    </div>
    <div class="form-group">
        <label>Total Amount:</label>
        <span class="total-amount" id="editTotalAmount">0.00</span>
        <input type="hidden" name="amount" id="editAmountInput">
    </div>
    <button type="submit" class="btn btn-primary" style="width: 100%;">
        <i class="fas fa-save"></i> Update Quote
    </button>
</form>
<%
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
<script>
    function addNewEditRow() {
        const tbody = document.getElementById('editDescriptionRows');
        if (!tbody) return;
        
        const newRow = document.createElement('tr');
        newRow.innerHTML = `
            <td><input type="number" name="srNo[]" value="" min="1" class="sr-no-input" required></td>
            <td><input type="text" name="description[]" placeholder="Enter description" required></td>
            <td><input type="number" name="price[]" placeholder="Enter price" step="0.01" min="0" required oninput="calculateEditTotal()"></td>
            <td class="action-cell">
                <input type="hidden" name="descId[]" value="">
                <input type="checkbox" name="delete[]" value="" class="delete-checkbox"> Delete
            </td>
        `;
        tbody.appendChild(newRow);
        calculateEditTotal();
    }

    function removeRow(button) {
        const row = button.closest('tr');
        if (row) {
            const tbody = row.parentNode;
            if (tbody.querySelectorAll('tr').length > 1) {
                row.remove();
                calculateEditTotal();
                resequenceSrNos();
            }
        }
    }

    function resequenceSrNos() {
        const srNoInputs = document.querySelectorAll('input[name="srNo[]"]');
        srNoInputs.forEach((input, index) => {
            input.value = index + 1;
        });
        calculateEditTotal();
    }

    function calculateEditTotal() {
        let total = 0;
        const priceInputs = document.querySelectorAll('#editDescriptionTable input[name="price[]"]');
        priceInputs.forEach(input => {
            const value = parseFloat(input.value) || 0;
            total += value;
        });
        
        const previousTotalElement = document.querySelector('.total-amount');
        const previousTotal = previousTotalElement ? parseFloat(previousTotalElement.textContent) || 0 : 0;
        const newAdditional = total - previousTotal;
        const updatedTotal = total;
        
        const additionalAmountElement = document.getElementById('editAdditionalAmount');
        const totalAmountElement = document.getElementById('editTotalAmount');
        const amountInputElement = document.getElementById('editAmountInput');
        
        if (additionalAmountElement) additionalAmountElement.textContent = newAdditional.toFixed(2);
        if (totalAmountElement) totalAmountElement.textContent = updatedTotal.toFixed(2);
        if (amountInputElement) amountInputElement.value = updatedTotal.toFixed(2);
    }

    function validateSrNoSequence(event) {
        const srNoInputs = document.querySelectorAll('input[name="srNo[]"]');
        const srNos = Array.from(srNoInputs).map(input => {
            const value = parseInt(input.value) || 0;
            return value > 0 ? value : null;
        }).filter(num => num !== null);
        
        if (srNos.length !== new Set(srNos).size) {
            alert("Duplicate Sr. No. values are not allowed. Please ensure each Sr. No. is unique.");
            event.preventDefault();
            return false;
        }

        srNos.sort((a, b) => a - b);
        for (let i = 0; i < srNos.length; i++) {
            if (srNos[i] !== i + 1) {
                alert("Sr. No. values must be in sequence (1, 2, 3, ...). Please correct the sequence.");
                event.preventDefault();
                return false;
            }
        }

        if (srNos.length > 0 && srNos[0] !== 1) {
            alert("Sr. No. sequence must start from 1. Please correct the first Sr. No.");
            event.preventDefault();
            return false;
        }

        return true;
    }

    // Attach event listeners for dynamically loaded content
    document.getElementById('editModalContent').addEventListener('click', function(e) {
        if (e.target && e.target.closest('#addEditRowBtn')) {
            addNewEditRow();
        }
        // Remove the removeRow call since we're using checkboxes for deletion
    });

    // Initial calculation
    calculateEditTotal();
</script>