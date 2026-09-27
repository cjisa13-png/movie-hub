/// Miembro del reparto de una película (actor/actriz y su personaje).
class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });
}
