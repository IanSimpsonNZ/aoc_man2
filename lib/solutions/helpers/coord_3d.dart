class Coord3D {
  int x;
  int y;
  int z;

  Coord3D(this.x, this.y, this.z);

  Coord3D operator +(Coord3D c) => Coord3D(x + c.x, y + c.y, z + c.z);
  Coord3D operator -(Coord3D c) => Coord3D(x - c.x, y - c.y, z - c.z);
  @override
  bool operator ==(Object other) =>
      other is Coord3D && x == other.x && y == other.y && z == other.z;
  @override
  int get hashCode => Object.hash(x, y, z);

  Coord3D clone() => Coord3D(x, y, z);

  @override
  String toString() => '($x, $y, $z)';
}
