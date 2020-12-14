import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class FileHelper {
  static String getFileNameFull(
    io.File file,
  ) {
    return path.basename(file.path);
  }

  static String getFileName(
    io.File file,
  ) {
    return path.basenameWithoutExtension(file.path);
  }

  static String getFileExtension(
    io.File file,
  ) {
    return path.extension(file.path);
  }

  static Future<String> writeFile(
    io.File file,
  ) async {
    var _directory = await getApplicationDocumentsDirectory();
    var _path = _directory.path;
    var _folderPath = '$_path/app_files';
    if (!await io.Directory(_folderPath).exists()) {
      //var folder = await io.Directory('$_path/app_files').create();
      await io.Directory('$_path/app_files').create();
    }
    var _fileNameWithExtension = path.basename(file.path);
    var _fileNameWithoutExtension = path.basenameWithoutExtension(file.path);
    var _fileExtension = path.extension(file.path);
    for (var fileInFolder
        in await io.Directory(_folderPath).list(recursive: false).toList()) {
      if (path.basename(fileInFolder.path) == _fileNameWithExtension) {
        var uuid = Uuid();
        _fileNameWithoutExtension += '_' + uuid.v1().toString();
      }
    }
    var writeFile =
        io.File('$_folderPath/' + _fileNameWithoutExtension + _fileExtension);
    await writeFile.writeAsBytes(file.readAsBytesSync());
    return _fileNameWithoutExtension + _fileExtension;
  }
}
