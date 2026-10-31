import 'package:flutter_test/flutter_test.dart';
import 'package:wishlist_megas_pogo/models/mega_pokemon.dart';

void main() {
  group('MegaPokemon artwork', () {
    test('todas las megas tienen un PokeAPI ID válido', () {
      for (final mega in MegaPokemon.allMegas) {
        expect(
          mega.pokeApiId,
          greaterThan(0),
          reason:
              '${mega.id} no tiene pokeApiId y mostraría '
              'la imagen de su forma base',
        );
      }
    });

    test('los PokeAPI IDs no se repiten', () {
      final ids = <int, String>{};
      for (final mega in MegaPokemon.allMegas) {
        final previous = ids[mega.pokeApiId];
        expect(
          previous,
          isNull,
          reason:
              '${mega.id} comparte pokeApiId ${mega.pokeApiId} con $previous',
        );
        ids[mega.pokeApiId] = mega.id;
      }
    });

    test('las megas de Z-A y Megadimensión usan su propio artwork', () {
      // Las primeras megas de Leyendas Z-A empiezan en el ID 10278 de PokeAPI.
      const firstNewMegaId = 10278;

      final newMegas = MegaPokemon.allMegas.where(
        (mega) =>
            mega.gameGroup == MegaGameGroup.za ||
            mega.gameGroup == MegaGameGroup.megadimension,
      );

      for (final mega in newMegas) {
        expect(
          mega.pokeApiId,
          greaterThanOrEqualTo(firstNewMegaId),
          reason: '${mega.id} sigue apuntando a un Pokémon que no es su Mega',
        );
        expect(
          mega.imageUrl,
          endsWith('/official-artwork/${mega.pokeApiId}.png'),
        );
        expect(mega.fallbackImageUrl, endsWith('/home/${mega.pokeApiId}.png'));
      }
    });
  });
}
