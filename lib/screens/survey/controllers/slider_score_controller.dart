import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'answer_controller.dart';

class SliderScoreController extends ChangeNotifier {
  double value = 0;
  SliderScoreController(var val) {
    value = val;
    notifyListeners();
  }

  changeValue(double v, int index, BuildContext context) {
    value = v;
    Provider.of<AnswerController>(context, listen: false)
        .updateScoreAnswer(score: value, index: index);
    notifyListeners();
  }
}
