import 'dart:convert';
import 'dart:async';
import 'package:eps_mobile/models/case_definition_document.dart';
import 'package:eps_mobile/models/case_file.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/case_instance.dart';
import 'dart:io' as io;

class UploadDocument {
  static Future<Tuple2<bool, CaseFile>> uploadDocumentAsync(
    EpsState epsState,
    CaseInstance caseInstance,
    CaseDefinitionDocument caseDefinitionDocument,
    io.File file,
  ) async {
    Uri uri;

    var path = '/cases/' + caseInstance.id.toString() + '/add_file';

    if (epsState.serviceInfo.useHttps) {
      uri = Uri.https(epsState.serviceInfo.url, path);
    } else {
      uri = Uri.http(epsState.serviceInfo.url, path);
    }

    var headers = {
      "Content-Type": "multipart/form-data",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    var request = http.MultipartRequest(
      'POST',
      uri,
    );
    request.headers.addAll(headers);
    if (caseDefinitionDocument != null) {
      request.files.add(http.MultipartFile.fromString(
        'document_id',
        caseDefinitionDocument.id.toString(),
      ));
    }
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    var stream = await request.send();

    var response = await http.Response.fromStream(stream);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      var caseFile = CaseFile();

      // get properties back
      var idKey = 'id';
      if (responseData.containsKey(idKey)) {
        caseFile.id = responseData[idKey];
      }

      caseFile.caseId = caseInstance.id;

      var documentIdKey = 'document_id';
      if (responseData.containsKey(documentIdKey)) {
        caseFile.documentId = responseData[documentIdKey];
      }

      var originalFileNameKey = 'original_filename';
      if (responseData.containsKey(originalFileNameKey)) {
        caseFile.originalFileName = responseData[originalFileNameKey];
      }

      var remoteFileNameKey = 'remote_filename';
      if (responseData.containsKey(remoteFileNameKey)) {
        caseFile.remoteFileName = responseData[remoteFileNameKey];
      }

      var createdAtKey = 'created_at';
      if (responseData.containsKey(createdAtKey)) {
        caseFile.createdAt = DateTime.parse(responseData[createdAtKey]);
      }

      caseFile.createdBy = 1;

      return Tuple2<bool, CaseFile>(true, caseFile);
    }

    // failure
    return Tuple2<bool, CaseFile>(false, null);
  }
}
