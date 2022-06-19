import 'package:money_link/model/amount.dart';
import 'package:money_link/model/person.dart';

import 'base_model.dart';

class Group extends Model {
  Group({required super.objectId});
}

abstract class Tile {}

class GroupTile extends Tile {
  final String title;
  final String subtitle;
  final List<Tile> innerTiles;
  GroupTile({required this.title, required this.subtitle, required this.innerTiles});
}

class EntityTile<T extends Model> extends Tile {
  final T object;

  EntityTile({required this.object});

  static EntityTile<Person> personTile(Person person) => EntityTile(object: person);

  static EntityTile<Amount> amountTile(Amount amount) => EntityTile(object: amount);
}
