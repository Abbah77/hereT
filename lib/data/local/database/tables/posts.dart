import 'package:drift/drift.dart';

class Posts extends Table {
  TextColumn get id => text().customConstraint('PRIMARY KEY')();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get content => text()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  // Sync status flags
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get syncAttempts => integer().withDefault(const Constant(0))();
  TextColumn get syncError => text().nullable()();
  
  // For pending deletion
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}