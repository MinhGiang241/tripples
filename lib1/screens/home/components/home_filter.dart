import 'package:flutter/material.dart';
import 'package:survey/models/company.dart';

class HomeFilter extends StatefulWidget {
  const HomeFilter(
      {Key? key,
      required this.companies,
      required this.onChanged,
      this.selectedCompany})
      : super(key: key);
  final List<RefCompanyIdCompanyDto> companies;
  final RefCompanyIdCompanyDto? selectedCompany;
  final Function(RefCompanyIdCompanyDto? value) onChanged;
  @override
  _HomeFilterState createState() => _HomeFilterState();
}

class _HomeFilterState extends State<HomeFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: new DropdownButton<RefCompanyIdCompanyDto?>(
      isExpanded: true,
      value: widget.selectedCompany,
      onChanged: widget.onChanged,
      items: widget.companies.map((RefCompanyIdCompanyDto company) {
        return new DropdownMenuItem<RefCompanyIdCompanyDto>(
          value: company,
          child: Center(
            child: new Text(
              company.name ?? '',
              style: new TextStyle(color: Colors.black),
            ),
          ),
        );
      }).toList(),
    ));
  }
}
