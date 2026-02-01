class InviteImageOption {
  const InviteImageOption({required this.id, required this.assetPath, required this.title});

  final String id;
  final String assetPath;
  final String title;
}

class InviteImages {
  static const heart = InviteImageOption(
    id: 'heart',
    assetPath: 'assets/images/heart.svg',
    title: 'Sweet Heart',
  );

  static const letter = InviteImageOption(
    id: 'letter',
    assetPath: 'assets/images/letter.svg',
    title: 'Love Letter',
  );

  static const rose = InviteImageOption(
    id: 'rose',
    assetPath: 'assets/images/rose.svg',
    title: 'Blushing Rose',
  );

  static const cupid = InviteImageOption(
    id: 'cupid',
    assetPath: 'assets/images/cupid.svg',
    title: 'Cheeky Cupid',
  );

  static const List<InviteImageOption> options = [heart, letter, rose, cupid];

  static InviteImageOption byId(String id) {
    return options.firstWhere((option) => option.id == id, orElse: () => heart);
  }
}
