import 'package:money_link/model/amount.dart';
import 'package:money_link/model/base_model.dart';
import 'package:money_link/model/person.dart';

class Group extends BaseModel {
  Group(super.objectId);
}

abstract class Tile {}

class GroupTile extends Tile {
  final String title;
  final String subtitle;
  final List<Tile> innerTiles;
  GroupTile({required this.title, required this.subtitle, required this.innerTiles});
}

class EntityTile<T extends BaseModel> extends Tile {
  final T object;

  EntityTile({required this.object});

  static EntityTile<Person> personTile(Person person) => EntityTile(object: person);

  static EntityTile<Amount> amountTile(Amount amount) => EntityTile(object: amount);
}
