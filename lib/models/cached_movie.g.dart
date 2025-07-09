// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedMovieAdapter extends TypeAdapter<CachedMovie> {
  @override
  final int typeId = 0;

  @override
  CachedMovie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedMovie(
      id: fields[0] as String,
      title: fields[1] as String,
      releaseDate: fields[2] as String,
      posterPath: fields[3] as String,
      cachedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedMovie obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.releaseDate)
      ..writeByte(3)
      ..write(obj.posterPath)
      ..writeByte(4)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedMovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
