import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text().customConstraint('PRIMARY KEY')();
  TextColumn get fullName => text().named('full_name')();
  TextColumn get email => text().unique()();
  TextColumn get username => text().unique()();
  TextColumn get profilePicture => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  // For offline sync
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}