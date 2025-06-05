abstract class UseCase<Type, Param> {
  Future<Type> call(Param param);
}

abstract class StreamUseCase<Type, Param> {
  Stream<Type> call(Param param);
}
