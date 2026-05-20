part of 'generated.dart';

class CreateMovieVariablesBuilder {
  String title;
  String genre;
  String imageUrl;

  final FirebaseDataConnect _dataConnect;
  CreateMovieVariablesBuilder(this._dataConnect, {required  this.title,required  this.genre,required  this.imageUrl,});
  Deserializer<CreateMovieData> dataDeserializer = (dynamic json)  => CreateMovieData.fromJson(jsonDecode(json));
  Serializer<CreateMovieVariables> varsSerializer = (CreateMovieVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateMovieData, CreateMovieVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateMovieData, CreateMovieVariables> ref() {
    CreateMovieVariables vars= CreateMovieVariables(title: title,genre: genre,imageUrl: imageUrl,);
    return _dataConnect.mutation("CreateMovie", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateMovieMovieInsert {
  final String id;
  CreateMovieMovieInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateMovieMovieInsert otherTyped = other as CreateMovieMovieInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateMovieMovieInsert({
    required this.id,
  });
}

@immutable
class CreateMovieData {
  final CreateMovieMovieInsert movieInsert;
  CreateMovieData.fromJson(dynamic json):
  
  movieInsert = CreateMovieMovieInsert.fromJson(json['movie_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateMovieData otherTyped = other as CreateMovieData;
    return movieInsert == otherTyped.movieInsert;
    
  }
  @override
  int get hashCode => movieInsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['movie_insert'] = movieInsert.toJson();
    return json;
  }

  const CreateMovieData({
    required this.movieInsert,
  });
}

@immutable
class CreateMovieVariables {
  final String title;
  final String genre;
  final String imageUrl;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateMovieVariables.fromJson(Map<String, dynamic> json):
  
  title = nativeFromJson<String>(json['title']),
  genre = nativeFromJson<String>(json['genre']),
  imageUrl = nativeFromJson<String>(json['imageUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateMovieVariables otherTyped = other as CreateMovieVariables;
    return title == otherTyped.title && 
    genre == otherTyped.genre && 
    imageUrl == otherTyped.imageUrl;
    
  }
  @override
  int get hashCode => Object.hashAll([title.hashCode, genre.hashCode, imageUrl.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    json['genre'] = nativeToJson<String>(genre);
    json['imageUrl'] = nativeToJson<String>(imageUrl);
    return json;
  }

  const CreateMovieVariables({
    required this.title,
    required this.genre,
    required this.imageUrl,
  });
}

