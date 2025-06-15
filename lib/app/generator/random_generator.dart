import 'package:uuid/uuid.dart';

class RandomGenerator {
  static String generateId() {
    return Uuid().v4();
  }
}
