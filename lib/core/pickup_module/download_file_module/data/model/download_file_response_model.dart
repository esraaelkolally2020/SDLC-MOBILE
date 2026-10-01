class DownloadFileResponseModel {
  const DownloadFileResponseModel({this.data});

  final DownloadFileModel? data;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'data': data?.toMap()};
  }

  // In resignation when downloading attachment it returns a list not a Map
  // So i do check if it is a list or a map before paring convering it into a DownloadFileModel
  DownloadFileResponseModel fromMap(dynamic map) {
    return DownloadFileResponseModel(
      data: (DownloadFileModel.fromMap(
        (map is List && map.isNotEmpty) ? map[0] : map,
      )),
    );
  }

  @override
  String toString() => 'DownloadFileResponseModel(data: $data)';
}

class DownloadFileModel {
  final int? fileId;
  final String? fileBinary;
  final String? mimetype;
  final String? fileName;
  final String? type;

  const DownloadFileModel({
    this.fileId,
    this.fileBinary,
    this.mimetype,
    this.fileName,
    this.type,
  });

  factory DownloadFileModel.fromMap(Map<String, dynamic> map) {
    return DownloadFileModel(
      fileId: map['fileId'] ?? map['ID'],
      fileBinary: map['fileBinary'] ?? map['FileBinary'],
      mimetype: map['mimetype'] as String?,
      fileName: map['fileName'] ?? map['FileName'],
      type: map['type'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fileId': fileId,
      'fileBinary': fileBinary,
      'mimetype': mimetype,
      'fileName': fileName,
      'type': type,
    };
  }

  @override
  String toString() => 'DownloadFileModel(fileId: $fileId)';
}
