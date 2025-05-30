import 'package:flutter/material.dart';
import 'package:nest_user_app/constants/colors.dart';
import 'package:nest_user_app/controllers/hotel_provider/hotel_provider.dart';
import 'package:nest_user_app/models/hotel_models.dart';
import 'package:nest_user_app/views/hotel_details/hotal_available_room_list.dart';
import 'package:nest_user_app/views/hotel_details/hotel_address.dart';
import 'package:nest_user_app/views/hotel_details/hotel_amenities.dart';
import 'package:nest_user_app/views/hotel_details/hotel_details_image_section.dart';
import 'package:nest_user_app/views/hotel_details/hotel_review_report.dart';
import 'package:provider/provider.dart';

class HotelDetailsScreen extends StatelessWidget {
  final int index;
  const HotelDetailsScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final hotelprovider = Provider.of<HotelProvider>(listen: false, context);
    final HotelModel hotelData = hotelprovider.hotels[index];
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HotelDetailsImageSection(hotelData: hotelData),

            HotelDetailAddress(hotelData: hotelData),

            HotelAmenities(hotelData: hotelData),
            SizedBox(height: 10),

            HotelAvailableRoomsList(hotelData: hotelData),

            SizedBox(height: 20),

            HotelReviewReport(),
          ],
        ),
      ),
    );
  }
}


