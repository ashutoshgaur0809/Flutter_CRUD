import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crud_operation/models/company.dart'; // Update to reflect new model

class CompanyService {

  List<Company> allCompanies = [];

  String baseUrl = "http://retoolapi.dev/teg31h/data";  // Update with your actual base URL


  // get the data
  Future<List<Company>> getAllCompanyData() async {
    try {
      var response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        var data = response.body;
        var decodeData = jsonDecode(data);
        var companies = decodeData as List; // Treat data as a list
        print(companies); // Print raw data for debugging

        allCompanies.clear(); // Clear the list before adding new data

        for (var i in companies) {
          Company newCompany = Company.fromJson(i);
          allCompanies.add(newCompany);
        }

        return allCompanies; // Return the company list for UI
      } else {
        print("Failed with status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error occurred: $e");
      throw Exception(e.toString());
    }
  }

  // get data by id
  Future<Company?> getCompanyById(String id) async {
    // Fetch all companies first
    await getAllCompanyData(); // Ensure we have the latest data

    // Find the company with the matching ID
    for (var company in allCompanies) {
      if (company.id.toString() == id) {
        return company; // Return the found company
      }
    }

    // If no company is found, you can either return null or throw an exception
    print("Company with ID $id not found.");
    return null; // Or throw Exception("Company not found");
  }


  // update company
  // Method to update a company
  Future<void> updateCompany(Company company) async {
    final url = '$baseUrl/${company.id}'; // Initial update URL

    try {
      var response = await http.put(
        Uri.parse(url),
        body: jsonEncode(company.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      // Check for the 308 redirect
      if (response.statusCode == 308) {
        // Retrieve the new location from headers
        final newUrl = response.headers['location'];
        if (newUrl != null) {
          // Try updating again at the new URL
          response = await http.put(
            Uri.parse(newUrl),
            body: jsonEncode(company.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      if (response.statusCode == 200) {
        print("Company updated successfully!");
      } else {
        print("Failed to update company. Status code: ${response.statusCode}");
        throw Exception("Failed to update company.");
      }
    } catch (e) {
      print("Error occurred while updating company: $e");
      throw Exception(e.toString());
    }
  }




  // Create a new company (POST request)
  Future<void> createCompany(Company company) async {
    final url = "http://retoolapi.dev/teg31h/data";

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',

      //Content-Type: application/json:
      // This header indicates the media type of the resource being sent to the server. Here, it specifies that the body of the request contains JSON data.
      // When the server receives this request, it knows to parse the body as JSON, which is essential for correctly interpreting the data being sent.

        },
        body: jsonEncode(company.toJson()),
      );

      print("Sending data: ${company.toJson()}");  // Log the data being sent
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Check for redirect status
      if (response.statusCode == 308) {
        // Handle the redirect by checking the `Location` header
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          // Optionally follow the redirect
          print('Redirecting to: $redirectUrl');
          var redirectResponse = await http.post(
            Uri.parse(redirectUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(company.toJson()),
          );

          print("Redirect response status: ${redirectResponse.statusCode}");
          print("Redirect response body: ${redirectResponse.body}");

          if (redirectResponse.statusCode == 200) {
            print("Company added successfully after redirect: ${redirectResponse.body}");
          } else {
            throw Exception("Failed to add company after redirect: ${redirectResponse.statusCode}");
          }
        } else {
          throw Exception("Redirect location is missing.");
        }
      } else if (response.statusCode == 201 || response.statusCode == 200) {
        print("Company added successfully: ${response.body}");
      } else {
        throw Exception("Failed to add company: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: ${e.toString()}");
    }
  }



//   delete comapany
  Future<void> deleteCompany(int id) async {
    final url = "$baseUrl/$id"; // Append the company ID to the base URL

    try {
      var response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Check for redirect status
      if (response.statusCode == 308) {
        // Handle the redirect by checking the `Location` header
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          // Follow the redirect URL for deletion
          print('Redirecting to: $redirectUrl');
          var redirectResponse = await http.delete(
            Uri.parse(redirectUrl),
            headers: {
              'Content-Type': 'application/json',
            },
          );

          print("Redirect response status: ${redirectResponse.statusCode}");
          print("Redirect response body: ${redirectResponse.body}");

          if (redirectResponse.statusCode == 200 || redirectResponse.statusCode == 204) {
            print("Company deleted successfully after redirect.");
          } else {
            throw Exception("Failed to delete company after redirect: ${redirectResponse.statusCode}");
          }
        } else {
          throw Exception("Redirect location is missing.");
        }
      } else if (response.statusCode == 200 || response.statusCode == 204) {
        print("Company deleted successfully.");
      } else {
        throw Exception("Failed to delete company: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
      throw Exception("Failed to delete company.");
    }
  }





}
