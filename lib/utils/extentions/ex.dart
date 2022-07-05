import 'package:survey/screens/survey/models/model_file.dart';

extension ConvertDateTime on String {
  String formatDateTimeDMY() {
    DateTime dt = DateTime.parse(this);
    DateTime d = dt.add(Duration(hours: 7));
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  String formatDateTimeHmDMY() {
    DateTime dt = DateTime.parse(this);
    DateTime d = dt.add(Duration(hours: 7));
    return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }
}

extension FilterList<ModelFile> on List<ModelFile> {}

List<ModelFile> filterList(List<ModelFile> listModelFile, int currentIndex) {
  List<ModelFile> list = [];
  for (int i = 0; i < listModelFile.length; i++) {
    if (listModelFile[i].index == currentIndex) {
      list.add(listModelFile[i]);
    }
  }
  return list;
}

List<ModelFile> filterList2(
    List<ModelFile> listModelFile, List<ModelFile> files) {
  List<ModelFile> list = [];
  for (int i = 0; i < listModelFile.length; i++) {
    for (int j = 0; j < files.length; j++) {
      if (listModelFile[i].file == files[j].file) {
        list.add(listModelFile[i]);
      }
    }
  }
  return list;
}
