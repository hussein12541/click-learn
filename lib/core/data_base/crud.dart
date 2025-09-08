abstract class CRUD{
  Future<bool> insert({required String tableName,required  Map<String, dynamic> values});
  Future<bool> update({required String ColumnIDName,required String tableName,required String id, required Map<String, dynamic> values});
  Future<bool> delete({required String tableName,required String id,required String ColumnIDName});
  Future<List<Map<String, Object?>>>  select({required String tableName,required String where});
  Future<List<Map<String, Object?>>>  selectUsingQuery({required String query});

  // Future<List<Map<String, Object?>>>  search({required String tableName,required String searchWord});

}