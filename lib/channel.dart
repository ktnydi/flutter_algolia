class Channel {
  int id;
  String name;
  int numRegisters;

  Channel(Map<String, dynamic> data) {
    this.id = data['id'];
    this.name = data['name'];
    this.numRegisters = data['numRegisters'];
  }
}
