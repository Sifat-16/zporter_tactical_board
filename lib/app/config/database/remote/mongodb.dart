import 'package:mongo_dart/mongo_dart.dart' hide State;
import 'package:zporter_tactical_board/app/environment/env.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

class MongoDB {
  Db? db;
  Future<void> connect() async {
    if (db != null && db!.isConnected) {
      zlog(data: 'Successful connecting to MongoDB: ');
      return; // Already connected
    }
    try {
      db = await Db.create(Env.MONGODB_CONNECT);
      await db!.open();
      zlog(data: 'Successful connecting to MongoDB: ');
    } catch (e) {
      zlog(data: 'Error connecting to MongoDB: $e');
    }
  }
}
