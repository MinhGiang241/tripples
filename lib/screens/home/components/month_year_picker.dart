import 'package:flutter/material.dart';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../../../constants.dart';

class ChooseMonthYear extends StatefulWidget {
  final Function? onRefresh;
  DateTime? selectedDate;
  final int year;
  final int month;
  final Function selectMonthAndYear;
  ChooseMonthYear(
      {this.onRefresh,
      this.selectedDate,
      required this.selectMonthAndYear,
      required this.year,
      required this.month});
  @override
  _ChooseMonthYearState createState() => _ChooseMonthYearState();
}

class _ChooseMonthYearState extends State<ChooseMonthYear> {
  // DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // _buildMaterialDatePicker(context);
          DatePicker.showPicker(context, onChanged: (v) {}, onConfirm: (v) {
            // setState(() {
            //   widget.selectedDate = v;
            //   // widget!.onLoad!();
            // });

            widget.selectMonthAndYear(v.year, v.month);

            print(v.year);
            print(v.month);
          },
              pickerModel: CustomMonthPicker(
                  minTime: DateTime(2000, 1, 1),
                  maxTime: DateTime.now(),
                  currentTime: DateTime(widget.year, widget.month, 1),
                  locale: LocaleType.vi));
        },
        child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: padding),
            padding: EdgeInsets.symmetric(vertical: padding / 2),
            decoration: BoxDecoration(
                border: Border.symmetric(
              horizontal: BorderSide(width: 1.0, color: Colors.grey.shade200),
            )),
            // padding: EdgeInsets.symmetric(vertical: padding / 2),
            // margin: EdgeInsets.symmetric(horizontal: 12),
            child: Text('${widget.year} - ${widget.month} ',
                style: Theme.of(context).textTheme.bodyLarge)),
      ),
    );
  }
}

class CustomMonthPicker extends DatePickerModel {
  CustomMonthPicker(
      {DateTime? currentTime,
      DateTime? minTime,
      DateTime? maxTime,
      LocaleType? locale})
      : super(
            locale: locale,
            minTime: minTime,
            maxTime: maxTime,
            currentTime: currentTime);

  @override
  List<int> layoutProportions() {
    return [1, 1, 0];
  }
}
