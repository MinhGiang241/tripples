import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../../../constants.dart';

class ChooseMonthYear extends StatefulWidget {
  @override
  _ChooseMonthYearState createState() => _ChooseMonthYearState();
}

class _ChooseMonthYearState extends State<ChooseMonthYear> {
  DateTime selectedDate = DateTime.now();
  _buildMaterialDatePicker(BuildContext context) async {
    final DateTime? picked = await
        // showMonthYearPicker(
        //   context: context,
        //   initialDate: DateTime.now(),
        //   firstDate: DateTime(2019),
        //   lastDate: DateTime(2023),
        // );

        showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.day,
      helpText: 'Choose date',
      cancelText: 'Cancel',
      confirmText: 'Save',
      errorFormatText: 'Invalid date format',
      errorInvalidText: 'Invalid date format',
      fieldLabelText: 'Start date',
      fieldHintText: 'Year/Month/Date',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: Container(child: child),
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        print(selectedDate);
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _buildMaterialDatePicker(context);
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.symmetric(
          horizontal: BorderSide(width: 1.0, color: Colors.grey),
        )),
        padding: EdgeInsets.symmetric(vertical: padding / 2),
        margin: EdgeInsets.symmetric(horizontal: 12),
        child: Text("${selectedDate.toLocal()}".split(' ')[0] ?? 'Select Date',
            style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
