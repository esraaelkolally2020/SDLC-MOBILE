class ExampleModel {
  final int? id;
  final String? title;
  final String? body;

  const ExampleModel({this.id, this.title, this.body});

  factory ExampleModel.fromMap(Map<String, dynamic> map) {
    return ExampleModel(
      id: map['id'] as int?,
      title: map['title'] as String?,
      body: map['body'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'title': title, 'body': body};
  }

  @override
  String toString() => 'ExampleModel(id: $id, title: $title)';
}
