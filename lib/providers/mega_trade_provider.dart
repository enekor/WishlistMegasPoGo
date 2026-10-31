import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mega_pokemon.dart';

enum FilterCategory {
  all('Todos', 'Ver la lista completa'),
  seeking('Buscados', 'Megas que te interesan'),
  offering('Ofrecidos', 'Megas que tienes para cambiar'),
  xy('X / Y', 'Debut en Pokémon X y Y'),
  oras('RO / ZA', 'Debut en Rubí Omega / Zafiro Alfa');

  final String label;
  final String description;
  const FilterCategory(this.label, this.description);
}

class MegaTradeProvider extends ChangeNotifier {
  final Map<String, TradeState> _selections = {};
  String _searchQuery = '';
  FilterCategory _activeFilter = FilterCategory.all;
  bool _isLoading = true;

  Map<String, TradeState> get selections => _selections;
  String get searchQuery => _searchQuery;
  FilterCategory get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;

  int get seekingCount =>
      _selections.values.where((s) => s == TradeState.seeking).length;

  int get offeringCount =>
      _selections.values.where((s) => s == TradeState.offering).length;

  int get totalSelectedCount => seekingCount + offeringCount;

  MegaTradeProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final mega in MegaPokemon.allMegas) {
        final savedState = prefs.getString('trade_state_${mega.id}');
        if (savedState != null) {
          if (savedState == 'seeking') {
            _selections[mega.id] = TradeState.seeking;
          } else if (savedState == 'offering') {
            _selections[mega.id] = TradeState.offering;
          }
        }
      }
    } catch (e) {
      debugPrint('Error al cargar la persistencia local: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  TradeState getState(String pokemonId) {
    return _selections[pokemonId] ?? TradeState.none;
  }

  Future<void> setTradeState(String pokemonId, TradeState state) async {
    if (state == TradeState.none) {
      _selections.remove(pokemonId);
    } else {
      _selections[pokemonId] = state;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'trade_state_$pokemonId';
      if (state == TradeState.none) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, state.name);
      }
    } catch (e) {
      debugPrint('Error al guardar el estado: $e');
    }
  }

  Future<void> cycleState(String pokemonId) async {
    final currentState = getState(pokemonId);
    final nextState = switch (currentState) {
      TradeState.none => TradeState.seeking,
      TradeState.seeking => TradeState.offering,
      TradeState.offering => TradeState.none,
    };
    await setTradeState(pokemonId, nextState);
  }

  Future<void> clearAll() async {
    final keysToRemove = List<String>.from(_selections.keys);
    _selections.clear();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      for (final id in keysToRemove) {
        await prefs.remove('trade_state_$id');
      }
    } catch (e) {
      debugPrint('Error al limpiar selecciones: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void setFilter(FilterCategory category) {
    _activeFilter = category;
    notifyListeners();
  }

  List<MegaPokemon> getFilteredList(MegaGameGroup gameGroup) {
    return MegaPokemon.allMegas.where((pokemon) {
      if (pokemon.gameGroup != gameGroup) return false;

      // Filter by Search Query
      if (_searchQuery.isNotEmpty &&
          !pokemon.name.toLowerCase().contains(_searchQuery) &&
          !pokemon.dexNumber.toString().contains(_searchQuery)) {
        return false;
      }

      // Filter by Category
      final state = getState(pokemon.id);
      switch (_activeFilter) {
        case FilterCategory.all:
          return true;
        case FilterCategory.seeking:
          return state == TradeState.seeking;
        case FilterCategory.offering:
          return state == TradeState.offering;
        case FilterCategory.xy:
          return pokemon.gameGroup == MegaGameGroup.xy;
        case FilterCategory.oras:
          return pokemon.gameGroup == MegaGameGroup.oras;
      }
    }).toList();
  }

  String generateShareableText() {
    final seekingList = <String>[];
    final offeringList = <String>[];

    for (final mega in MegaPokemon.allMegas) {
      final state = getState(mega.id);
      if (state == TradeState.seeking) {
        seekingList.add(mega.name);
      } else if (state == TradeState.offering) {
        offeringList.add(mega.name);
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('✨ MIS MEGAEVOLUCIONES PARA INTERCAMBIO ✨');
    buffer.writeln('----------------------------------------');

    if (seekingList.isNotEmpty) {
      buffer.writeln('🔍 BUSCO (${seekingList.length}):');
      for (final name in seekingList) {
        buffer.writeln(' • $name');
      }
    } else {
      buffer.writeln('🔍 BUSCO: Ninguno seleccionado');
    }

    buffer.writeln();

    if (offeringList.isNotEmpty) {
      buffer.writeln('🔄 OFREZCO (${offeringList.length}):');
      for (final name in offeringList) {
        buffer.writeln(' • $name');
      }
    } else {
      buffer.writeln('🔄 OFREZCO: Ninguno seleccionado');
    }

    buffer.writeln('----------------------------------------');
    buffer.writeln('Generado con Wishlist MegaEvoluciones');

    return buffer.toString();
  }
}
