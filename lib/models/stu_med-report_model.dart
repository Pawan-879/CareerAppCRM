// To parse this JSON data, do
//
//     final stuMedReprtModel = stuMedReprtModelFromJson(jsonString);

import 'dart:convert';

StuMedReprtModel stuMedReprtModelFromJson(String str) =>
    StuMedReprtModel.fromJson(json.decode(str));

String stuMedReprtModelToJson(StuMedReprtModel data) =>
    json.encode(data.toJson());

class StuMedReprtModel {
  StuMedReprtModel({
    this.status,
    this.error,
    this.data,
  });

  int? status;
  bool? error;
  List<StudentRep>? data;

  factory StuMedReprtModel.fromJson(Map<String, dynamic> json) =>
      StuMedReprtModel(
        status: json["status"],
        error: json["error"],
        data: List<StudentRep>.from(
            json["data"].map((x) => StudentRep.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class StudentRep {
  StudentRep({
    this.id,
    this.studentId,
    this.treatmentGiven,
    this.medicineDetails,
    this.remark,
    this.sick,
    this.image,
    this.totalFee,
    this.medicalFormId,
    this.created,
    this.video,
  });

  String? id;
  String? studentId;
  String? treatmentGiven;
  String? medicineDetails;
  String? remark;
  String? sick;
  String? image;
  String? totalFee;
   String? video;
  String? medicalFormId;
  String? created;

  factory StudentRep.fromJson(Map<String, dynamic> json) => StudentRep(
        id: json["id"],
        studentId: json["student_id"],
        treatmentGiven: json["treatment_given"],
        medicineDetails: json["medicine_details"],
        remark: json["remark"],
        sick: json["sick"],
        image: json["image"],
        totalFee: json["total_fee"],
        medicalFormId: json["medical_form_id"],
        created: json["created"],
        video: json["video"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "student_id": studentId,
        "treatment_given": treatmentGiven,
        "medicine_details": medicineDetails,
        "remark": remark,
        "sick": sick,
        "image": image,
        "total_fee": totalFee,
        "medical_form_id": medicalFormId,
        "created": created,
        "video": video,
      };
}

class StuHostelModel {
  StuHostelModel({
    this.status,
    this.error,
    this.data,
  });

  int? status;
  bool? error;
  List<StudentHostel>? data;

  factory StuHostelModel.fromJson(Map<String, dynamic> json) => StuHostelModel(
        status: json["status"],
        error: json["error"],
        data: List<StudentHostel>.from(
            json["data"].map((x) => StudentHostel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class StudentHostel {
  StudentHostel({
    this.id,
    this.userId,
    this.schoolId,
    this.studentId,
    this.date,
    this.hostelNo,
    this.bedNo,
    this.floor,
    this.wardenName,
    this.wardenNo,
    this.almiraStatus,
    this.beddingStatus,
    this.haircuttingStatus,
    this.laundryStatus,
    this.roomCleaningStatus,
    this.washroomsCleannessStatus,
    this.electricityStatus,
    this.waterSupplyStatus,
    this.disciplinePunctualityStatus,
    this.remark,
    this.createdAt,
    this.updatedAt,
  });

  String? id;
  String? userId;
  String? schoolId;
  String? studentId;
  String? date;
  String? hostelNo;
  String? bedNo;
  String? floor;
  String? wardenName;
  String? wardenNo;
  String? almiraStatus;
  String? beddingStatus;
  String? haircuttingStatus;
  String? laundryStatus;
  String? roomCleaningStatus;
  String? washroomsCleannessStatus;
  String? electricityStatus;
  String? waterSupplyStatus;
  String? disciplinePunctualityStatus;
  String? remark;
  String? createdAt;
  String? updatedAt;

  factory StudentHostel.fromJson(Map<String, dynamic> json) => StudentHostel(
        id: json["id"],
        userId: json["user_id"],
        schoolId: json["school_id"],
        studentId: json["student_id"],
        date: json["date"],
        hostelNo: json["hostel_no"],
        bedNo: json["bed_no"],
        floor: json["floor"],
        wardenName: json["warden_name"],
        wardenNo: json["warden_no"],
        almiraStatus: json["almira_status"],
        beddingStatus: json["bedding_status"],
        haircuttingStatus: json["haircutting_status"],
        laundryStatus: json["laundry_status"],
        roomCleaningStatus: json["room_cleaning_status"],
        washroomsCleannessStatus: json["washrooms_cleanness_status"],
        electricityStatus: json["electricity_status"],
        waterSupplyStatus: json["water_supply_status"],
        disciplinePunctualityStatus: json["discipline_punctuality_status"],
        remark: json["remark"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "school_id": schoolId,
        "student_id": studentId,
        "date": date,
        "hostel_no": hostelNo,
        "bed_no": bedNo,
        "floor": floor,
        "warden_name": wardenName,
        "warden_no": wardenNo,
        "almira_status": almiraStatus,
        "bedding_status": beddingStatus,
        "haircutting_status": haircuttingStatus,
        "laundry_status": laundryStatus,
        "room_cleaning_status": roomCleaningStatus,
        "washrooms_cleanness_status": washroomsCleannessStatus,
        "electricity_status": electricityStatus,
        "water_supply_status": waterSupplyStatus,
        "discipline_punctuality_status": disciplinePunctualityStatus,
        "remark": remark,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };
}
