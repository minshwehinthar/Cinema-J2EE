<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Base64"%>
<%@ page import="com.demo.dao.ReviewDAO"%>
<%@ page import="com.demo.model.Review"%>
<%@ page import="com.demo.model.User"%>
<%
User user = (User) session.getAttribute("user");
ReviewDAO dao = new ReviewDAO();

// Get theaterId from query parameter
String theaterIdParam = request.getParameter("theaterId");
int theaterId = 0;
if (theaterIdParam != null && !theaterIdParam.isEmpty()) {
    theaterId = Integer.parseInt(theaterIdParam);
} else {
    response.sendRedirect("moduleReview.jsp");
    return;
}

// Fetch reviews for the selected theater
List<Review> reviews = dao.getReviewsByTheater(theaterId);

boolean canPost = user != null && "user".equals(user.getRole());

// Count total, good, bad reviews
int totalReviews = reviews.size();
int goodReviews = 0;
int badReviews = 0;
for (Review r : reviews) {
    if ("yes".equals(r.getIsGood()))
        goodReviews++;
    else
        badReviews++;
}

int goodPercent = totalReviews > 0 ? (goodReviews * 100) / totalReviews : 0;
int badPercent = totalReviews > 0 ? (badReviews * 100) / totalReviews : 0;
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Theater Reviews</title>
<script src="https://cdn.tailwindcss.com"></script>
<%
boolean loggedIn = (user != null);
String reviewsHeight = loggedIn ? "54vh" : "";
%>
<style>
.reviews-container {
    height: <%=reviewsHeight%>;
    overflow-y: auto;
    scrollbar-width: none; /* Firefox */
    -ms-overflow-style: none; /* IE & Edge */
}
.reviews-container::-webkit-scrollbar {
    width: 0;
    height: 0;
}
</style>
</head>
<body class="bg-gray-50">
<jsp:include page="layout/header.jsp"></jsp:include>

<div class="max-w-4xl mx-auto py-6">
    <h1 class="text-3xl font-bold text-center mb-6">Customer Reviews</h1>

    <!-- Stats Boxes -->
    <div class="w-full max-w-3xl mx-auto mb-4 flex flex-col md:flex-row md:space-x-4 space-y-2 md:space-y-0">
        <div id="totalBox" class="flex-1 cursor-pointer bg-gray-50 border border-gray-200 rounded-lg h-24 flex flex-col items-center justify-center text-gray-800 font-semibold">
            <span class="text-sm">Total</span> 
            <span class="text-xl"><%=totalReviews%></span>
        </div>

        <div id="goodBox" class="flex-1 cursor-pointer bg-gray-50 border border-gray-200 rounded-lg h-24 flex flex-col items-center justify-center text-green-600 font-semibold">
            <span class="text-sm">Good</span> 
            <span class="text-xl"><%=goodReviews%> (<%=goodPercent%>%)</span>
        </div>

        <div id="badBox" class="flex-1 cursor-pointer bg-gray-50 border border-gray-200 rounded-lg h-24 flex flex-col items-center justify-center text-red-600 font-semibold">
            <span class="text-sm">Bad</span> 
            <span class="text-xl"><%=badReviews%> (<%=badPercent%>%)</span>
        </div>
    </div>

    <!-- Progress Bar -->
    <div class="mb-6 px-2">
        <div class="flex justify-between text-sm text-gray-700 mb-1">
            <span>Good <%=goodPercent%>%</span> 
            <span>Bad <%=badPercent%>%</span>
        </div>
        <div class="w-full h-3 bg-gray-200 rounded-full relative overflow-hidden">
            <div class="absolute left-0 top-0 h-3 bg-green-500 rounded-l-full" style="width:<%=goodPercent%>%"></div>
            <div class="absolute right-0 top-0 h-3 bg-red-500 rounded-r-full" style="width:<%=badPercent%>%"></div>
        </div>
    </div>

    <!-- Reviews List -->
    <div class="reviews-container flex flex-col space-y-3 mb-8 px-2">
        <%
        if (reviews.isEmpty()) {
        %>
        <p class="text-gray-400 text-center">No reviews yet.</p>
        <%
        } else {
            for (Review r : reviews) {
                // Convert byte[] user image to Base64
                String reviewUserImage = null;
                if (r.getUserImage() != null) {
                    byte[] imgBytes = r.getUserImage().getBytes(); // If stored as byte[], else skip
                    if(imgBytes.length > 0) {
                        reviewUserImage = "data:image/png;base64," + Base64.getEncoder().encodeToString(imgBytes);
                    }
                }
                if(reviewUserImage == null){
                    reviewUserImage = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAjVBMVEXZ3OF...";
                }

                boolean isGood = "yes".equals(r.getIsGood());
                String textColor = isGood ? "text-green-600" : "text-red-600";

                boolean isOwner = user != null && user.getUserId() == r.getUserId(); // Check ownership
        %>
        <div class="review-item flex flex-col border border-gray-200 rounded-lg p-3 bg-white">
            <div class="flex justify-between mb-2">
                <div class="flex items-center space-x-3">
                    <img src="<%=reviewUserImage%>" alt="avatar" class="w-10 h-10 rounded-full object-cover">
                    <div class="flex flex-col">
                        <span class="font-medium text-gray-800"><%=r.getUserName()%></span>
                        <span class="text-xs text-gray-400 review-timestamp"><%=r.getCreatedAt()%></span>
                    </div>
                </div>
                <div class="flex items-center space-x-2">
                    <% int rating = r.getRating();
                       for(int i = 1; i <= 5; i++){
                           if(i <= rating){ %>
                               <span class="text-yellow-500">★</span>
                           <% } else { %>
                               <span class="text-gray-300">★</span>
                           <% }
                       } %>
                    <% if(isOwner){ %>
                        <form action="review" method="post" class="inline">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="reviewId" value="<%=r.getId()%>">
                            <input type="hidden" name="theaterId" value="<%=theaterId%>">
                            <button type="submit" class="text-red-600 font-bold px-2 py-1 rounded hover:bg-red-100">Delete</button>
                        </form>
                    <% } %>
                </div>
            </div>
            <p class="review-text <%=textColor%> text-sm whitespace-pre-wrap"><%=r.getReviewText()%></p>
        </div>
        <%
            }
        }
        %>
    </div>

    <!-- Review Input Form -->
    <%
    if(user != null){
        String currentUserImage;
        byte[] imgBytes = user.getImage();
        if(imgBytes != null && imgBytes.length > 0){
            currentUserImage = "data:image/png;base64," + Base64.getEncoder().encodeToString(imgBytes);
        } else {
            currentUserImage = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAjVBMVEXZ3OF...";
        }
    %>
    <div class="w-full max-w-3xl mx-auto px-2 mb-8">
        <form id="reviewForm" action="review" method="post" class="flex flex-col md:flex-row items-start space-y-2 md:space-y-0 md:space-x-2 bg-white border border-gray-200 rounded-lg p-3">
            <input type="hidden" name="theaterId" value="<%=theaterId%>">
            <img src="<%=currentUserImage%>" alt="avatar" class="w-10 h-10 rounded-full object-cover">
            <textarea name="reviewText" rows="2" class="flex-1 p-2 border border-gray-300 rounded-md resize-none focus:ring-1 focus:ring-blue-400" placeholder="<%=canPost ? "Write your review..." : "Only users can post reviews"%>" <%=canPost ? "" : "disabled"%>></textarea>
            <select name="isGood" class="p-2 border border-gray-300 rounded-md" <%=canPost ? "" : "disabled"%>>
                <option value="yes">Good</option>
                <option value="no">Bad</option>
            </select>
            <select name="rating" class="p-2 border border-gray-300 rounded-md" <%=canPost ? "" : "disabled"%>>
                <option value="0">Rating</option>
                <option value="1">1 ⭐</option>
                <option value="2">2 ⭐</option>
                <option value="3">3 ⭐</option>
                <option value="4">4 ⭐</option>
                <option value="5">5 ⭐</option>
            </select>
            <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700" <%=canPost ? "" : "disabled"%>>Send</button>
        </form>
    </div>
    <%
    }
    %>

</div>

<jsp:include page="layout/footer.jsp"></jsp:include>

<script>
// Filter reviews by clicking stats boxes
const reviews = document.querySelectorAll('.review-item');
const totalBox = document.getElementById('totalBox');
const goodBox = document.getElementById('goodBox');
const badBox = document.getElementById('badBox');

function filterReviews(filter){
    reviews.forEach(r => {
        const reviewText = r.querySelector('.review-text');
        const isGood = reviewText.classList.contains('text-green-600');
        if(filter === 'total') r.style.display = 'flex';
        else if(filter === 'good') r.style.display = isGood ? 'flex' : 'none';
        else if(filter === 'bad') r.style.display = !isGood ? 'flex' : 'none';
    });
}

totalBox.addEventListener('click', ()=>filterReviews('total'));
goodBox.addEventListener('click', ()=>filterReviews('good'));
badBox.addEventListener('click', ()=>filterReviews('bad'));

// Format timestamps
function formatReviewDate(isoDate){
    const dateObj = new Date(isoDate);
    const options = { day:'2-digit', month:'long', year:'numeric', hour:'2-digit', minute:'2-digit', hour12:true };
    return dateObj.toLocaleString('en-US', options);
}

document.querySelectorAll('.review-timestamp').forEach(span=>{
    const isoDate = span.textContent.trim();
    if(isoDate) span.textContent = formatReviewDate(isoDate);
});
</script>

</body>
</html>
