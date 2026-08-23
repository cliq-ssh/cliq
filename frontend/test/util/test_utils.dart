import 'dart:io';

class TestUtils {
  const new _();

  /// Helper function to read a resource file from the specified directory.
  /// The file is expected to be located at 'test/resources/[directory]/[fileName]'.
  static File readFile(String fileName, String directory) {
    final file = File(
      '${Directory.current.path}/test/resources/$directory/$fileName',
    );
    if (!file.existsSync()) {
      throw Exception('Resource file not found: ${file.path}');
    }
    return file;
  }

  /// Helper function to read a resource file as a string.
  /// If [makeInvalid] is true, it will return only the first half of the content to simulate an invalid file.
  /// Returns a tuple of the file name and its content.
  static Future<(String, String)> readResource(
    String fileName,
    String directory, {
    bool makeInvalid = false,
  }) async {
    final file = readFile(fileName, directory);
    final content = await file.readAsString();
    return (
      file.uri.pathSegments.last,
      makeInvalid ? content.substring(0, content.length ~/ 2) : content,
    );
  }
}
