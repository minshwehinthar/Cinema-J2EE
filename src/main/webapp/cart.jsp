<%@ page import="java.util.List"%>
<%@ page import="com.demo.model.CartItem"%>
<%@ page import="com.demo.model.User"%>
<%
User user = (User) session.getAttribute("user");
List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
double totalAmount = (request.getAttribute("totalAmount") != null)
    ? (Double) request.getAttribute("totalAmount") : 0.0;

int totalQuantity = 0;
if(cartItems != null){
    for(CartItem c : cartItems){
        totalQuantity += c.getQuantity();
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>My Cart</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 font-sans min-h-screen flex flex-col">

  <!-- Header -->
  <jsp:include page="layout/header.jsp"/>

  <!-- Main Content -->
  <main class="flex-grow max-w-7xl mx-auto py-12 px-4 w-full">
    <h1 class="text-3xl font-bold mb-8 text-center text-gray-900">My Cart</h1>

    <div class="grid grid-cols-1 lg:grid-cols-4 gap-8 items-start">

      <!-- Cart Items -->
      <div class="lg:col-span-3 bg-white rounded-lg shadow-sm border border-gray-200">
        <table class="w-full text-left">
          <thead class="bg-gray-100">
            <tr>
              <th class="px-4 py-3">Product</th>
              <th class="px-4 py-3">Price</th>
              <th class="px-4 py-3 text-center">Amount</th>
              <th class="px-4 py-3 text-right">Price</th>
              <th class="px-4 py-3">Action</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <% if(cartItems == null || cartItems.isEmpty()){ %>
              <tr>
                <td colspan="5" class="text-center py-16">
                  <img src="assets/img/cart_empty.png" alt="Empty Cart" class="mx-auto w-48 h-48 object-contain mb-4">
                  <p class="text-gray-500 text-lg">Your cart is empty.</p>
                  <a href="foods.jsp" class="mt-4 inline-block px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold">
                    Start Ordering
                  </a>
                </td>
              </tr>
            <% } else { 
                 for(CartItem c : cartItems) {
                   double lineTotal = c.getQuantity() * c.getFood().getPrice();
            %>
              <tr>
                <td class="px-4 py-3 flex items-center gap-3">
                  <img src="<%=c.getFood().getImage()%>" alt="<%=c.getFood().getName()%>" class="w-14 h-14 object-cover rounded">
                  <div>
                    <p class="font-semibold text-gray-900"><%=c.getFood().getName()%></p>
                  </div>
                </td>
                <td class="px-4 py-3 text-gray-700">$<%=c.getFood().getPrice() %></td>
                <td class="px-4 py-3 text-center">
                  <form action="cart" method="get" class="inline-flex items-center gap-2">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="cartId" value="<%=c.getId()%>">
                    <button type="submit" name="quantity" value="<%=c.getQuantity()-1%>" class="px-2 py-1 bg-gray-200 rounded">-</button>
                    <span class="px-3 py-1 border rounded bg-gray-50"><%=c.getQuantity()%></span>
                    <button type="submit" name="quantity" value="<%=c.getQuantity()+1%>" class="px-2 py-1 bg-gray-200 rounded">+</button>
                  </form>
                </td>
                <td class="px-4 py-3 text-center">
                  $<%=lineTotal%>
                </td>
                <td class="px-4 py-3 text-right font-bold text-gray-900">
                  <a href="cart?action=remove&cartId=<%=c.getId()%>" class="hover:text-red-500">Remove item</a>
                </td>
              </tr>
            <% } } %>
          </tbody>
        </table>
      </div>

      <!-- Order Summary -->
      <div class="bg-white p-6 rounded-lg shadow sticky top-4">
        <h2 class="text-xl font-bold mb-4 text-gray-900">Summary</h2>

        <div class="flex justify-between mb-2 text-gray-700">
          <span>Number of Products:</span>
          <span><%= (cartItems != null) ? cartItems.size() : 0 %></span>
        </div>

        <div class="flex justify-between mb-2 text-gray-700">
          <span>Total Quantity:</span>
          <span><%= totalQuantity %></span>
        </div>

        <div class="flex justify-between mb-2 text-gray-700">
          <span>Total Price:</span>
          <span>$<%=totalAmount%></span>
        </div>

        <div class="flex justify-between mb-4 text-gray-700">
          <span>Shipping Costs:</span>
          <span class="text-green-600">Free</span>
        </div>

        <div class="flex justify-between text-lg font-bold mb-6">
          <span>Total:</span>
          <span class="text-green-600">$<%= totalAmount %></span>
        </div>

        <a href="checkout" class="block w-full text-center bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded font-semibold">
          CHECKOUT
        </a>
      </div>
    </div>

  </main>

  <!-- Footer -->
  <jsp:include page="layout/footer.jsp"/>

</body>
</html>
