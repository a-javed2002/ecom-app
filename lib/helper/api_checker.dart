import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/error_response.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiChecker {
  static void checkApi(ApiResponse apiResponse, {String? email}) {
    print("hello");
    if (apiResponse.error == "Failed to load data - status code: 401") {
      Provider.of<AuthController>(Get.context!, listen: false)
          .clearSharedData();
    } else if (apiResponse.response?.statusCode == 500) {
      showCustomSnackBar(
          getTranslated('internal_server_error', Get.context!), Get.context!);
    } else {
      log("==ff=>${apiResponse.error}");
      String? errorMessage = apiResponse.error.toString();
      if (apiResponse.error is String) {
        errorMessage = apiResponse.error.toString();
      } else {
        ErrorResponse errorResponse = ErrorResponse.fromJson(apiResponse.error);
        log(errorResponse.toString());
        //errorMessage = errorResponse.errors?[0].message;
      }
      if (errorMessage.startsWith('000')) {
        print("hello3 ${errorMessage}");
        // Remove the first 4 characters
        String modifiedInput = errorMessage.substring(4);
        // Split the remaining string by '-'
        List<String> numbers = modifiedInput.split('---');

        // Check if there are any non-empty numbers
        if (numbers.isNotEmpty && numbers.any((number) => number.isNotEmpty)) {
          String name =
              (numbers.length > 2 && numbers[2].isNotEmpty) ? numbers[2] : "";
          String address1 =
              (numbers.length > 3 && numbers[3].isNotEmpty) ? numbers[3] : "";
          String address2 =
              (numbers.length > 4 && numbers[4].isNotEmpty) ? numbers[4] : "";
          String city =
              (numbers.length > 5 && numbers[5].isNotEmpty) ? numbers[5] : "";

          // Filter out empty numbers
          List<String> nonEmptyNumbers =
              numbers.where((number) => number.isNotEmpty).toList();

          showDialog(
            context: Get.context!,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Select The Number For OTP'),
                content: Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 2,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(
                            'Number ${index + 1}: ${nonEmptyNumbers[index]}'),
                        onTap: () async {
                          print(
                              'Number ${index + 1}: ${nonEmptyNumbers[index]}');
                          final response = await http.post(
                            Uri.parse(
                                'https://eshop.pakbev.com/api/request-otp'),
                            headers: {
                              'Content-Type': 'application/json',
                            },
                            body:
                                jsonEncode({'number': nonEmptyNumbers[index]}),
                          );

                          print(response.statusCode);
                          print(jsonDecode(response.body));

                          if (response.statusCode == 200) {
                            final responseBody = jsonDecode(response.body);
                            if (responseBody['status'] == true) {
                              print('OTP sent successfully.');
                              TextEditingController otpController =
                                  TextEditingController();

                              Navigator.of(context)
                                  .pop(); // Close the number selection dialog

                              showDialog(
                                context: Get.context!,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Enter OTP'),
                                    content: TextField(
                                      controller: otpController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          hintText: 'Enter OTP'),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('Submit'),
                                        onPressed: () async {
                                          String otp = otpController.text;
                                          print(
                                              'OTP entered: $otp ${nonEmptyNumbers[index]}');
                                          final response2 = await http.post(
                                            Uri.parse(
                                                'https://eshop.pakbev.com/api/verify-otp'),
                                            headers: {
                                              'Content-Type':
                                                  'application/json',
                                            },
                                            // body: jsonEncode({'otp': otp}),
                                            body: jsonEncode({
                                              'number': nonEmptyNumbers[index],
                                              'otp': otp
                                            }),
                                          );

                                          if (response2.statusCode == 200) {
                                            final responseBody2 =
                                                jsonDecode(response2.body);
                                            if (responseBody2['status'] ==
                                                true) {
                                              showCustomSnackBar(
                                                  "OTP Successfully Match",
                                                  Get.context!);
                                              TextEditingController
                                                  passwordController =
                                                  TextEditingController();
                                              TextEditingController
                                                  confirmPasswordController =
                                                  TextEditingController();
                                              bool isPasswordVisible = false;
                                              bool isConfirmPasswordVisible =
                                                  false;

                                              Navigator.of(context)
                                                  .pop(); // Close OTP dialog

                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder:
                                                        (context, setState) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Enter Password'),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            TextField(
                                                              controller:
                                                                  passwordController,
                                                              obscureText:
                                                                  !isPasswordVisible,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    'Enter Password',
                                                                suffixIcon:
                                                                    IconButton(
                                                                  icon: Icon(
                                                                    isPasswordVisible
                                                                        ? Icons
                                                                            .visibility
                                                                        : Icons
                                                                            .visibility_off,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      isPasswordVisible =
                                                                          !isPasswordVisible;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  confirmPasswordController,
                                                              obscureText:
                                                                  !isConfirmPasswordVisible,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    'Confirm Password',
                                                                suffixIcon:
                                                                    IconButton(
                                                                  icon: Icon(
                                                                    isConfirmPasswordVisible
                                                                        ? Icons
                                                                            .visibility
                                                                        : Icons
                                                                            .visibility_off,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      isConfirmPasswordVisible =
                                                                          !isConfirmPasswordVisible;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            child:
                                                                Text('Submit'),
                                                            onPressed:
                                                                () async {
                                                              String password =
                                                                  passwordController
                                                                      .text;
                                                              String
                                                                  confirmPassword =
                                                                  confirmPasswordController
                                                                      .text;
                                                              if (password
                                                                      .length >=
                                                                  8) {
                                                                if (password ==
                                                                    confirmPassword) {
                                                                  print(
                                                                      'Password entered: $password $email');
                                                                  showCustomSnackBar(
                                                                      "Password Match Successfully",
                                                                      Get.context!);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  if (email ==
                                                                          '' ||
                                                                      email ==
                                                                          null) {
                                                                    showCustomSnackBar(
                                                                        "Error",
                                                                        Get.context!);
                                                                  } else {
                                                                    final response3 =
                                                                        await http
                                                                            .post(
                                                                      Uri.parse(
                                                                          'https://eshop.pakbev.com/api/insert-static-data'),
                                                                      headers: {
                                                                        'Content-Type':
                                                                            'application/json',
                                                                      },
                                                                      body:
                                                                          jsonEncode({
                                                                        'email':
                                                                            email,
                                                                        'phone':
                                                                            email,
                                                                        'password':
                                                                            password,'name':name,'address1':address1,'address2':address2,'city':city
                                                                      }),
                                                                    );
                                                                    if (response3
                                                                            .statusCode ==
                                                                        200) {
                                                                      final responseBody3 =
                                                                          jsonDecode(
                                                                              response3.body);
                                                                      if (responseBody3[
                                                                              'status'] ==
                                                                          1) {
                                                                        showCustomSnackBar(
                                                                            "Now Login",
                                                                            Get.context!);
                                                                      } else {
                                                                        showCustomSnackBar(
                                                                            "${responseBody3['status']}",
                                                                            Get.context!);
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }
                                                                    } else {
                                                                      showCustomSnackBar(
                                                                          "Registration Failed Server",
                                                                          Get.context!);
                                                                    }
                                                                  }
                                                                } else {
                                                                  print(
                                                                      'Passwords do not match');
                                                                  showCustomSnackBar(
                                                                      "Passwords do not match",
                                                                      Get.context!);
                                                                }
                                                              } else {
                                                                showCustomSnackBar(
                                                                    "Minimum 8 Characters",
                                                                    Get.context!);
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            } else {
                                              showCustomSnackBar(
                                                  "OTP Does Not Match",
                                                  Get.context!);
                                              // Do not pop the OTP dialog
                                            }
                                          } else {
                                            showCustomSnackBar(
                                                "Server OTP Failed",
                                                Get.context!);
                                          }

                                          print(response2.statusCode);
                                          print(jsonDecode(response2.body));
                                          // Only pop the OTP dialog if the OTP is correct
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              print('Failed to send OTP.');
                              showCustomSnackBar("OTP Failed", Get.context!);
                            }
                          } else {
                            showCustomSnackBar(
                                "Server OTP Failed", Get.context!);
                          }
                        },
                      );
                    },
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }

        showCustomSnackBar("Select The Number For OTP", Get.context!);
      } else {
        showCustomSnackBar(errorMessage, Get.context!);
      }
    }
  }

  Future<bool> sendOtp(BuildContext context, String number) async {
    final response = await http.post(
      Uri.parse('https://eshop.pakbev.com/api/request-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'number': number}),
    );

    print(response.statusCode);
    print(jsonDecode(response.body));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['status'] == true) {
        print('OTP sent successfully.');
        return true;
      } else {
        print('Failed to send OTP.');
        return false;
      }
    } else {
      throw Exception('Failed to load sale orders');
    }
  }
}
