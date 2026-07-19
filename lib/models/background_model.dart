class BackgroundModel {
  final String? imagePath;

  const BackgroundModel({this.imagePath});

  bool get hasCustomBackground => imagePath != null;

  BackgroundModel copyWith({String? imagePath}) {
    return BackgroundModel(imagePath: imagePath ?? this.imagePath);
  }
}