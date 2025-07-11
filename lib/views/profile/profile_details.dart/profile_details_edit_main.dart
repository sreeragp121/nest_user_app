// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nest_user_app/constants/colors.dart';
import 'package:nest_user_app/constants/my_app_validators.dart';
import 'package:nest_user_app/controllers/image_provider/image_provider.dart';
import 'package:nest_user_app/controllers/user_provider/user_provider.dart';
import 'package:nest_user_app/models/user_model.dart';
import 'package:nest_user_app/views/profile/profile_details.dart/widgets/profile_image_picker.dart';
import 'package:nest_user_app/widgets/my_button.dart';
import 'package:nest_user_app/widgets/my_custom_text_field.dart';
import 'package:provider/provider.dart';

class ProfileDetailsMain extends StatelessWidget {
  const ProfileDetailsMain({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context);
    final imageProvider = Provider.of<AddImageProvider>(context, listen: false);

    final TextEditingController nameController = TextEditingController(
      text: userData.currentUser?.name,
    );
    final TextEditingController emailController = TextEditingController(
      text: userData.currentUser?.email,
    );
    final TextEditingController phoneNumController = TextEditingController(
      text: userData.currentUser!.phoneNumber,
    );

    final MyAppValidators myAppValidators = MyAppValidators();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('My Profile'),
        centerTitle: true,
        backgroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      Consumer<AddImageProvider>(
                        builder: (context, value, child) {
                          return CircleAvatar(
                            backgroundImage:
                                imageProvider.image == null
                                    ? userData.userImage != null
                                        ? NetworkImage(userData.userImage!)
                                        : AssetImage(
                                          'assets/images/images_1.jpg',
                                        )
                                    : FileImage(imageProvider.image!),
                            radius: 80,
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder:
                                  (context) => const AddRoomImageBottomSheet(),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: AppColors.grey300,
                            radius: 30,
                            child: Icon(Icons.camera_alt),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      MyCustomTextFormField(
                        prefixIcon: Icons.person,
                        controller: nameController,
                        hintText: 'Enter Name',
                        validator: myAppValidators.validateEmail,
                      ),
                      SizedBox(height: 10),

                      MyCustomTextFormField(
                        prefixIcon: Icons.email,
                        controller: emailController,
                        hintText: 'Enter The Email',
                        validator: myAppValidators.validateEmail,
                      ),
                      SizedBox(height: 10),

                      MyCustomTextFormField(
                        controller: phoneNumController,
                        prefixIcon: Icons.phone_android,
                        hintText: 'Enter The phone Number',
                        validator: myAppValidators.validateEmail,
                      ),

                      SizedBox(height: 50),

                      MyCustomButton(
                        width: double.infinity,
                        onPressed: () async {
                          String? uploadedImage;
                          if (imageProvider.image != null) {
                            uploadedImage = await userData.uploadImage(
                              imageProvider.image!,
                            );
                          }

                          await userData.updateUser(
                            UserModel(
                              userId: userData.currentUser!.userId,
                              name: nameController.text,
                              email: emailController.text,
                              phoneNumber: phoneNumController.text,
                              profileImage:
                                  (uploadedImage == null)
                                      ? (userData.currentUser!.profileImage)
                                      : (uploadedImage),
                            ),
                            context,
                          );
                          Navigator.pop(context);
                        },
                        backgroundcolor: AppColors.primary,
                        textcolor: AppColors.white,
                        text: 'Submit',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
