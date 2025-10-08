package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.demo.dao.BookingDao;
import com.demo.dao.SeatsDao;
import com.demo.model.Booking;
import com.demo.model.BookingSeat;
import com.demo.model.User;

@WebServlet("/BookTicketServlet")
public class BookTicketServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            
            int showtimeId = Integer.parseInt(request.getParameter("showtimeId"));
            double totalPriceDouble = Double.parseDouble(request.getParameter("totalPrice"));
            BigDecimal totalPrice = BigDecimal.valueOf(totalPriceDouble);

            
            String paymentMethod = request.getParameter("paymentMethod");
            if (paymentMethod == null) {
                
                paymentMethod = (String) session.getAttribute("paymentMethod");
            }
            
            if (paymentMethod == null || !isValidPaymentMethod(paymentMethod)) {
                paymentMethod = Booking.CASH;
            }

            
            String[] seatIdsParam = request.getParameterValues("seatIds");
            if (seatIdsParam == null || seatIdsParam.length == 0) {
                
                seatIdsParam = (String[]) session.getAttribute("paymentSeatIds");
                if (seatIdsParam == null || seatIdsParam.length == 0) {
                    response.sendRedirect("bookingConfirmation.jsp?error=NoSeatsSelected");
                    return;
                }
            }

            List<Integer> showtimeSeatIds = new ArrayList<>();
            for (String s : seatIdsParam) showtimeSeatIds.add(Integer.parseInt(s));

            SeatsDao seatsDao = new SeatsDao();

            
            for (int showtimeSeatId : showtimeSeatIds) {
                if (seatsDao.isSeatBookedById(showtimeSeatId)) {
                    response.sendRedirect("bookingConfirmation.jsp?error=SeatAlreadyBooked");
                    return;
                }
            }

            
            Booking booking = new Booking();
            booking.setUserId(user.getUserId());
            booking.setShowtimeId(showtimeId);
            booking.setTotalPrice(totalPrice);
            booking.setStatus("pending");
            booking.setBookingTime(new Timestamp(System.currentTimeMillis()));
            booking.setPaymentMethod(paymentMethod);

            BookingDao bookingDao = new BookingDao();
            int bookingId = bookingDao.insertBooking(booking);

            if (bookingId > 0) {
                
                List<BookingSeat> bookingSeatList = new ArrayList<>();
                for (int showtimeSeatId : showtimeSeatIds) {
                    BookingSeat bs = new BookingSeat();
                    bs.setBookingId(bookingId);
                    bs.setSeatId(showtimeSeatId);
                    bookingSeatList.add(bs);
                }
                seatsDao.insertBookingSeats(bookingSeatList);

                
                seatsDao.updateSeatsStatusById(showtimeSeatIds);

                
                session.removeAttribute("paymentShowtimeId");
                session.removeAttribute("paymentTotalPrice");
                session.removeAttribute("paymentSeatIds");
                session.removeAttribute("paymentMethod");

                
                response.sendRedirect("bookingVoucher.jsp?bookingId=" + bookingId);
            } else {
                response.sendRedirect("bookingConfirmation.jsp?error=BookingFailed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("bookingConfirmation.jsp?error=BookingFailed");
        }
    }

    
    private boolean isValidPaymentMethod(String paymentMethod) {
        return Booking.CASH.equals(paymentMethod) ||
               Booking.KBZ_PAY.equals(paymentMethod) ||
               Booking.WAVE_PAY.equals(paymentMethod);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}