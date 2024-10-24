import 'package:flutter/material.dart';
import 'package:crud_operation/models/company.dart';
import 'package:crud_operation/services/company_services.dart';
import 'AddNewComapny.dart';
import "loader.dart";

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  List<Company> companies = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCompanyData();
  }

  Future<void> _fetchCompanyData() async {
    setState(() {
      isLoading = true;
    });

    CompanyService companyService = CompanyService();
    await Future.delayed(Duration(seconds: 1)); // Show loader for 5 seconds
    List<Company> data = await companyService.getAllCompanyData();

    setState(() {
      companies = data;
      isLoading = false;
    });
  }

  _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Company'),
          content: Text('Are you sure you want to delete this company?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false on cancel
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Close the dialog and return true
                Navigator.of(context).pop(true);
                // Show the SnackBar after the dialog is closed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Company Deleted Successfully")),
                );
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1.AppBar and refresh Button
      appBar: AppBar(
        title: Text("Company Data",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            onPressed: _fetchCompanyData,
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),

      // Body Content
      body: isLoading
          ? Loader() // Show loader while data is being fetched
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[850]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: companies.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info, color: Colors.white, size: 48),
              SizedBox(height: 16),
              Text("No data available.",
                  style:
                  TextStyle(color: Colors.white, fontSize: 20)),
              ElevatedButton(
                onPressed: () async {

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddCompanyScreen()),
                  );
                  if (result == true) {
                    _fetchCompanyData();
                  }
                },
                child: Text("Add Company"),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: companies.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(
                  vertical: 8, horizontal: 16),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(companies[index].name,
                    style: TextStyle(color: Colors.black)),
                subtitle: Text(companies[index].address,
                    style: TextStyle(color: Colors.black)),
                leading: CircleAvatar(
                  backgroundImage:
                  NetworkImage(companies[index].logo),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String companyId =
                        companies[index].id.toString();
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddCompanyScreen(id: companyId)),
                        );
                        if (result == true) {
                          _fetchCompanyData();
                        }
                      },
                      child: Icon(Icons.edit, color: Colors.blue),
                    ),
                    SizedBox(width: 8),
                    // Deletion GestureDetector
                    GestureDetector(
                      onTap: () async {
                        // Show the confirmation dialog and wait for the result
                        bool? shouldDelete = await _showDeleteConfirmationDialog(context);

                        if (shouldDelete == true) { // Proceed if user confirmed
                          CompanyService companyService = CompanyService();
                          setState(() {
                            isLoading = true; // Start loading
                          });

                          try {
                            await companyService.deleteCompany(companies[index].id);

                            if (mounted) {
                              setState(() {
                                companies.removeAt(index); // Remove the company from the list
                                isLoading = false; // Stop loading
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Company deleted successfully!"),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                isLoading = false; // Stop loading
                              });


                            }
                          }
                        }
                      },
                      child: Icon(Icons.delete, color: Colors.red),
                    )






                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCompanyScreen()),
          );

          if (result == true) {
            _fetchCompanyData();
          }
        },
        backgroundColor: Colors.lightGreen,
        child: Icon(Icons.add),
      ),
    );
  }
}
