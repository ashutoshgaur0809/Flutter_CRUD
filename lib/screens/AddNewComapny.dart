import 'package:flutter/material.dart';
import 'package:crud_operation/models/company.dart';
import 'package:crud_operation/services/company_services.dart';
import 'loader.dart';

class AddCompanyScreen extends StatefulWidget {
  final String? id;

  const AddCompanyScreen({Key? key, this.id}) : super(key: key);

  @override
  _AddCompanyScreenState createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final String logoUrl = "https://logo.clearbit.com/mail.ru";
  bool isLoading = false; // Loader state

  @override
  void initState() {
    super.initState();
    if (widget.id != null && widget.id != "0") {
      _fetchCompanyData(widget.id!);
    }
  }

  Future<void> _fetchCompanyData(String id) async {
    setState(() {
      isLoading = true; // Start loader
    });

    CompanyService companyService = CompanyService();
    try {
      Company? company = await companyService.getCompanyById(id);
      if (company != null) {
        nameController.text = company.name;
        addressController.text = company.address;
        phoneController.text = company.phone;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Company not found.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching company data: $e")),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loader
      });
    }
  }

  Future<void> _submitForm() async {
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        phoneController.text.isEmpty) {
      // Show warning if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    setState(() {
      isLoading = true; // Start loader
    });

    CompanyService companyService = CompanyService();
    try {
      if (widget.id != null && widget.id != "0") {
        // Update company
        Company updatedCompany = Company(
          id: int.parse(widget.id!),
          logo: logoUrl,
          name: nameController.text,
          phone: phoneController.text,
          address: addressController.text,
        );

        await companyService.updateCompany(updatedCompany);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Company updated successfully!")),
        );
      } else {
        // Add new company
        Company newCompany = Company(
          id: 0,
          logo: logoUrl,
          name: nameController.text,
          phone: phoneController.text,
          address: addressController.text,
        );

        await companyService.createCompany(newCompany);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Company added successfully!")),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error processing request: $e")),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loader
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id != null && widget.id != "0" ? "Update Company" : "Add Company"),
      ),
      body: isLoading
          ? const Loader() // Show loader while loading
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8, // Add shadow effect
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Company Name",
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Space between fields
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: "Company Address",
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submitForm, // Call _submitForm for validation and submission
                  icon: const Icon(Icons.save),
                  label: Text(widget.id != null && widget.id != "0" ? "Update Data" : "Submit"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
