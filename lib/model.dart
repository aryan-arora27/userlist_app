class User {
  final String name, email;
  Map address;
  bool friend;
  User(this.name, this.email, this.address, this.friend);
  toJson() {
    return {
      "Name": name,
      "email": email,
      "friend": friend,
    };
  }
}
