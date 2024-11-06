class Coord {
  int x;
  int y;

  Coord(this.x, this.y);

  Coord operator +(Coord c) => Coord(x + c.x, y + c.y);
  Coord operator -(Coord c) => Coord(x - c.x, y - c.y);
  @override
  bool operator ==(Object other) =>
      other is Coord && x == other.x && y == other.y;
  @override
  int get hashCode => Object.hash(x, y);

  Coord clone() => Coord(x, y);

  // String print() => '($x, $y)';
  @override
  String toString() => '($x, $y)';
}
