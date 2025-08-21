import 'package:uuid/uuid.dart';

class IdGenerator {
  static final Uuid _uuid = Uuid();

  static String generateId() {
    return _uuid.v4();
  }
}
