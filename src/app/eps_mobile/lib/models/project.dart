import 'package:eps_mobile/models/user.dart';

class Project {
  int id;
  String agreementNumber;
  String name;
  String title;
  String location;
  String organization;
  double fundingAmount;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAt;
  DateTime updatedAt;
  int createdBy;
  int updatedBy;

  Project() {
    this.id = -1;
    this.agreementNumber = '';
    this.name = '';
    this.title = '';
    this.location = '';
    this.organization = '';
    this.fundingAmount = 0.0;
    this.startDate = null;
    this.endDate = null;
    this.createdAt = null;
    this.updatedAt = null;
    this.createdBy = -1;
    this.updatedBy = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agreementNumber': agreementNumber,
      'name': name,
      'title': title,
      'location': location,
      'organization': organization,
      'fundingAmount': fundingAmount,
      'startDate': startDate.toString(),
      'endDate': endDate.toString(),
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  static Project fromMap(Map map) {
    var project = Project();

    var idKey = 'id';
    if (map.containsKey(idKey)) {
      project.id = map[idKey];
    }

    var agreementNumberKey = 'agreementNumber';
    if (map.containsKey(agreementNumberKey)) {
      project.agreementNumber = map[agreementNumberKey];
    }

    var nameKey = 'name';
    if (map.containsKey(nameKey)) {
      project.name = map[nameKey];
    }

    var titleKey = 'title';
    if (map.containsKey(titleKey)) {
      project.title = map[titleKey];
    }

    var locationKey = 'location';
    if (map.containsKey(locationKey)) {
      project.location = map[locationKey];
    }

    var organizationKey = 'organization';
    if (map.containsKey(organizationKey)) {
      project.organization = map[organizationKey];
    }

    var fundingAmountKey = 'fundingAmount';
    if (map.containsKey(fundingAmountKey)) {
      project.fundingAmount = map[fundingAmountKey];
    }

    var startDateKey = 'startDate';
    if (map.containsKey(startDateKey)) {
      project.startDate = DateTime.parse(map[startDateKey]);
    }

    var endDateKey = 'endDate';
    if (map.containsKey(endDateKey)) {
      project.endDate = DateTime.parse(map[endDateKey]);
    }

    var createdAtKey = 'createdAt';
    if (map.containsKey(createdAtKey)) {
      project.createdAt = DateTime.parse(map[createdAtKey]);
    }

    var updatedAtKey = 'updatedAt';
    if (map.containsKey(updatedAtKey)) {
      project.updatedAt = DateTime.parse(map[updatedAtKey]);
    }

    var createdByKey = 'createdBy';
    if (map.containsKey(createdByKey)) {
      project.createdBy = map[createdByKey];
    }

    var updatedByKey = 'updatedBy';
    if (map.containsKey(updatedByKey)) {
      project.updatedBy = map[updatedByKey];
    }

    return project;
  }

  @override
  String toString() {
    return 'Project{' +
        'id: $id, ' +
        'agreementNumber: $agreementNumber, ' +
        'name: $name, ' +
        'title: $title, ' +
        'location: $location, ' +
        'organization: $organization, ' +
        'fundingAmount: $fundingAmount, ' +
        'startDate: $startDate, ' +
        'endDate: $endDate, ' +
        'createdAt: $createdAt, ' +
        'updatedAt: $updatedAt, ' +
        'createdBy: $createdBy, ' +
        'updatedBy: $updatedBy, ' +
        '}';
  }

  static String getTableName() {
    return 'projects';
  }

  static String getCreateTableStatement(String tableName) {
    return 'CREATE TABLE IF NOT EXISTS ' +
        tableName +
        '(' +
        'id INTEGER PRIMARY KEY' +
        ', ' +
        'agreementNumber TEXT' +
        ', ' +
        'name TEXT' +
        ', ' +
        'title TEXT' +
        ', ' +
        'location TEXT' +
        ', ' +
        'organization TEXT' +
        ', ' +
        'fundingAmount REAL' +
        ', ' +
        'startDate TEXT' + // SQLite "Datetime"
        ', ' +
        'endDate TEXT' + // SQLite "Datetime"
        ', ' +
        'createdAt TEXT' + // SQLite "Datetime"
        ', ' +
        'updatedAt TEXT' + // SQLite "Datetime"
        ', ' +
        'createdBy INT' +
        ', ' +
        'updatedBy INT' +
        ', ' +
        'FOREIGN KEY(createdBy) REFERENCES ' +
        User.getTableName() +
        '(id)' +
        ', ' +
        'FOREIGN KEY(updatedBy) REFERENCES ' +
        User.getTableName() +
        '(id)' +
        ');';
  }
}
