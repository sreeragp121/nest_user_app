import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nanoid/async.dart';
import 'package:nest_user_app/models/booking_model.dart';
import 'package:nest_user_app/models/room_model.dart';

class BookingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> generateBookingId() async {
    return await nanoid(10);
  }

  String get currentUserId => _auth.currentUser!.uid;

  Future<void> storeBookingInFirestore({
    required BookingModel booking,
    required String bookingId,
  }) async {
    final uid = currentUserId;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(bookingId)
        .set(booking.toJson());

    await _firestore
        .collection('hotels')
        .doc(booking.hotelId)
        .collection('bookings')
        .doc(bookingId)
        .set(booking.toJson());

    log('Booking stored in Firestore.');
  }

  Future<List<BookingModel>> fetchUserBookings() async {
    final uid = currentUserId;

    final snapshot =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('bookings')
            .orderBy('bookingDate', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => BookingModel.fromJson(doc.data()))
        .toList();
  }

  Future<int> checkRoomAvailability({
    required String hotelId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required RoomModel roomData,
  }) async {
    try {
      final totalRooms = int.tryParse(roomData.numberOfRooms) ?? 0;

      if (totalRooms <= 0) {
        log('No rooms available for room type: ${roomData.roomType}');
        return 0;
      }

      final bookingsSnapshot =
          await _firestore
              .collection('hotels')
              .doc(hotelId)
              .collection('bookings')
              .where('roomId', isEqualTo: roomId)
              .where(
                'bookingStatus',
                isEqualTo: 'Booked',
              ) 
              .get();

      int bookedRooms = 0;

      for (var doc in bookingsSnapshot.docs) {
        final booking = BookingModel.fromJson(doc.data());
        if (_datesOverlap(
          checkInDate,
          checkOutDate,
          booking.checkInDate,
          booking.checkOutDate,
        )) {
          bookedRooms += booking.numberOfRoomsBooked;
        }
      }

      final availableRooms = totalRooms - bookedRooms;
      log(
        'Total rooms: $totalRooms, Booked rooms: $bookedRooms, Available rooms: $availableRooms',
      );

      return availableRooms > 0 ? availableRooms : 0;
    } catch (e) {
      log('Error checking room availability: $e');
      return 0;
    }
  }
  bool _datesOverlap(
    DateTime requestStart,
    DateTime requestEnd,
    DateTime bookingStart,
    DateTime bookingEnd,
  ) {
    return requestStart.isBefore(bookingEnd) &&
        requestEnd.isAfter(bookingStart);
  }
  Future<bool> isBookingPossible({
    required String hotelId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required RoomModel roomData,
    required int requestedRooms,
  }) async {
    final availableRooms = await checkRoomAvailability(
      hotelId: hotelId,
      roomId: roomId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      roomData: roomData,
    );

    return availableRooms >= requestedRooms;
  }

  Future<Map<String, dynamic>> getRoomAvailabilityDetails({
    required String hotelId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required RoomModel roomData,
  }) async {
    final totalRooms = int.tryParse(roomData.numberOfRooms) ?? 0;
    final availableRooms = await checkRoomAvailability(
      hotelId: hotelId,
      roomId: roomId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      roomData: roomData,
    );

    return {
      'totalRooms': totalRooms,
      'availableRooms': availableRooms,
      'bookedRooms': totalRooms - availableRooms,
      'isAvailable': availableRooms > 0,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
    };
  }


  Future<void> cancelBooking({
    required String bookingId,
    required String hotelId,
  }) async {
    final uid = currentUserId;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bookings')
          .doc(bookingId)
          .update({'bookingStatus': 'Cancelled'});

      await _firestore
          .collection('hotels')
          .doc(hotelId)
          .collection('bookings')
          .doc(bookingId)
          .update({'bookingStatus': 'Cancelled'});

      log('Booking $bookingId cancelled successfully.');
    } catch (e) {
      log('Error cancelling booking $bookingId: $e');
      rethrow;
    }
  }
}
