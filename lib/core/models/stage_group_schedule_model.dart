class Schedules {
  String? id;
  String? day;
  String? time;
  String? groupId;
  String? createdAt;

  Schedules({this.id, this.day, this.time, this.groupId, this.createdAt});

  Schedules copyWith(
      {String? id, String? day, String? time, String? groupId, String? createdAt}) =>
      Schedules(id: id ?? this.id,
          day: day ?? this.day,
          time: time ?? this.time,
          groupId: groupId ?? this.groupId,
          createdAt: createdAt ?? this.createdAt);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["day"] = day;
    map["time"] = time;
    map["groupId"] = groupId;
    map["created_at"] = createdAt;
    return map;
  }

  Schedules.fromJson(dynamic json){
    id = json["id"];
    day = json["day"];
    time = json["time"];
    groupId = json["groupId"];
    createdAt = json["created_at"];
  }
}

class Groups {
  String? id;
  String? name;
  String? teacher_id;
  String? stageId;
  List<Schedules>? schedulesList;
  String? createdAt;
  String? numberOfStudents;

  Groups(
      {this.id, this.name,this.teacher_id, this.stageId, this.schedulesList, this.createdAt, this.numberOfStudents});

  Groups copyWith({String? id, String? name,String? teacher_id, String? stageId, List<
      Schedules>? schedulesList, String? createdAt, dynamic numberOfStudents}) =>
      Groups(id: id ?? this.id,
          name: name ?? this.name,
          teacher_id: teacher_id ?? this.teacher_id,
          stageId: stageId ?? this.stageId,
          schedulesList: schedulesList ?? this.schedulesList,
          createdAt: createdAt ?? this.createdAt,
          numberOfStudents: numberOfStudents ?? this.numberOfStudents);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    map["teacher_id"] = teacher_id;
    map["stage_id"] = stageId;
    if (schedulesList != null) {
      map["schedules"] = schedulesList?.map((v) => v.toJson()).toList();
    }
    map["created_at"] = createdAt;
    map["number_of_students"] = numberOfStudents;
    return map;
  }

  Groups.fromJson(dynamic json){
    id = json["id"];
    name = json["name"];
    teacher_id = json["teacher_id"];
    stageId = json["stage_id"];
    if (json["schedules"] != null) {
      schedulesList = [];
      json["schedules"].forEach((v) {
        schedulesList?.add(Schedules.fromJson(v));
      });
    }
    createdAt = json["created_at"];
    numberOfStudents = json["number_of_students"];
  }
  @override
  String toString() {
    return name ?? 'مجموعة غير معروفة';
  }
}

class DataList {
  String? createdAt;
  String? name;
  String? id;
  List<Groups>? groupsList;

  DataList({this.createdAt, this.name, this.id, this.groupsList});

  DataList copyWith({
    String? createdAt,
    String? name,
    String? id,
    List<Groups>? groupsList,
  }) =>
      DataList(
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        id: id ?? this.id,
        groupsList: groupsList ?? this.groupsList,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["created_at"] = createdAt;
    map["name"] = name;
    map["id"] = id;
    if (groupsList != null) {
      map["groups"] = groupsList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  DataList.fromJson(dynamic json) {
    createdAt = json["created_at"];
    name = json["name"];
    id = json["id"];
    if (json["groups"] != null) {
      groupsList = [];
      json["groups"].forEach((v) {
        groupsList?.add(Groups.fromJson(v));
      });
    }
  }

  @override
  String toString() {
    return name ?? 'مرحلة غير معروفة';
  }
}


class StageGroupScheduleModel {

  factory StageGroupScheduleModel.fromJsonList(List<dynamic> jsonList) {
    return StageGroupScheduleModel(
      dataListList: jsonList.map((e) => DataList.fromJson(e)).toList(),
    );
  }


  List<DataList>? dataListList;

  StageGroupScheduleModel({this.dataListList});

  StageGroupScheduleModel copyWith({List<DataList>? dataListList}) =>
      StageGroupScheduleModel(dataListList: dataListList ?? this.dataListList);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (dataListList != null) {
      map["dataList"] = dataListList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  StageGroupScheduleModel.fromJson(dynamic json){
    if (json != null) {
      dataListList = [];
      json.forEach((v) {
        dataListList?.add(DataList.fromJson(v));
      });
    }
  }
}