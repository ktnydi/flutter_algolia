class Channel {
  String objectID;
  int id;
  String name;
  int numRegisters;

  Channel(String objectID, Map<String, dynamic> data) {
    this.objectID = objectID;
    this.id = data['id'];
    this.name = data['name'];
    this.numRegisters = data['numRegisters'];
  }
}
