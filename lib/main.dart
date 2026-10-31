import 'package:flutter/material.dart';
import 'models/mega_pokemon.dart';
import 'providers/mega_trade_provider.dart';
import 'widgets/mega_card.dart';
import 'widgets/trade_summary_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MegaWishlistApp());
}

class MegaWishlistApp extends StatelessWidget {
  const MegaWishlistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wishlist MegaEvoluciones',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
          surface: const Color(0xFFF8F9FE),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
          surface: const Color(0xFF12121D),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      home: const MegaWishlistScreen(),
    );
  }
}

class MegaWishlistScreen extends StatefulWidget {
  const MegaWishlistScreen({super.key});

  @override
  State<MegaWishlistScreen> createState() => _MegaWishlistScreenState();
}

class _MegaWishlistScreenState extends State<MegaWishlistScreen> {
  late final MegaTradeProvider _provider;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = MegaTradeProvider();
    _provider.addListener(_onProviderChange);
  }

  void _onProviderChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChange);
    _provider.dispose();
    _searchController.dispose();
    super.dispose();
  }

  int _calculateCrossAxisCount(double width) {
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
    if (width > 400) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final xyList = _provider.getFilteredList(MegaGameGroup.xy);
    final orasList = _provider.getFilteredList(MegaGameGroup.oras);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con Título e Ilustración Mega Stone
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 16),
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.catching_pokemon,
                    color: Colors.purple.shade400,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MegaEvoluciones Wishlist',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Buscador y Chips de Filtrado
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Campo de Búsqueda
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => _provider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Buscar MegaEvolución por nombre...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _provider.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? Colors.grey.shade900
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Categorías de Filtro Rápido
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: FilterCategory.values.map((category) {
                        final isSelected =
                            _provider.activeFilter == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category.label),
                            selected: isSelected,
                            onSelected: (_) => _provider.setFilter(category),
                            selectedColor: Colors.purple.shade600,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.white70
                                      : Colors.black87),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_provider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            // SECCIÓN 1: Pokémon X y Pokémon Y
            if (xyList.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: MegaGameGroup.xy.title,
                  subtitle: '${xyList.length} MegaEvoluciones',
                  icon: Icons.games,
                  badgeColor: Colors.blue.shade600,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final cols =
                        _calculateCrossAxisCount(constraints.crossAxisExtent);
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final mega = xyList[index];
                          final state = _provider.getState(mega.id);
                          return MegaCard(
                            pokemon: mega,
                            state: state,
                            onTap: () => _provider.cycleState(mega.id),
                            onStateSelected: (newState) =>
                                _provider.setTradeState(mega.id, newState),
                          );
                        },
                        childCount: xyList.length,
                      ),
                    );
                  },
                ),
              ),
            ],

            // SECCIÓN 2: Pokémon Rubí Omega y Zafiro Alfa
            if (orasList.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: MegaGameGroup.oras.title,
                  subtitle: '${orasList.length} Megas / Primigenios',
                  icon: Icons.auto_awesome,
                  badgeColor: Colors.red.shade600,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final cols =
                        _calculateCrossAxisCount(constraints.crossAxisExtent);
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final mega = orasList[index];
                          final state = _provider.getState(mega.id);
                          return MegaCard(
                            pokemon: mega,
                            state: state,
                            onTap: () => _provider.cycleState(mega.id),
                            onStateSelected: (newState) =>
                                _provider.setTradeState(mega.id, newState),
                          );
                        },
                        childCount: orasList.length,
                      ),
                    );
                  },
                ),
              ),
            ],

            // En caso de resultado vacío por filtro
            if (xyList.isEmpty && orasList.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No se encontraron MegaEvoluciones',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prueba a cambiar el texto de búsqueda o filtro activo.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),

            // Padding inferior para evitar superposición con la barra de resumen
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ],
      ),
      bottomSheet: TradeSummaryBar(provider: _provider),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color badgeColor;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: badgeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
