import 'package:flutter/material.dart';
import 'package:survey/constants.dart';
import 'package:survey/generated/l10n.dart';

class HomeSearch extends StatefulWidget {
  const HomeSearch({
    Key? key,
    required this.searchController,
    required this.onSearch,
    required this.onClear,
  }) : super(key: key);
  final TextEditingController searchController;
  final Function(String) onSearch;
  final Function onClear;

  @override
  _HomeSearchState createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearch> {
  bool showClear = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding / 2, horizontal: padding),
      child: SizedBox(
        height: 50,
        child: TextField(
          textInputAction: TextInputAction.search,
          controller: widget.searchController,
          onChanged: (v) {
            if (v.isEmpty) {
              widget.onClear();
              setState(() {
                showClear = false;
              });
            } else {
              setState(() {
                showClear = true;
              });
            }
            widget.onSearch(widget.searchController.text);
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: padding),
            hintText: S.current.search,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(width: 0.5),
            ),
            prefixIcon: Icon(Icons.search),
            suffixIcon: SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  showClear
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded),
                          onPressed: () {
                            widget.onClear();
                            setState(() {
                              showClear = false;
                            });
                            FocusScope.of(context).unfocus();
                          })
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
