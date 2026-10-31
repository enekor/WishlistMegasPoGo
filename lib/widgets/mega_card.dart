import 'package:flutter/material.dart';
import '../models/mega_pokemon.dart';

class MegaCard extends StatelessWidget {
  final MegaPokemon pokemon;
  final TradeState state;
  final VoidCallback onTap;
  final ValueChanged<TradeState> onStateSelected;

  const MegaCard({
    super.key,
    required this.pokemon,
    required this.state,
    required this.onTap,
    required this.onStateSelected,
  });

  Color _getBorderColor(BuildContext context) {
    switch (state) {
      case TradeState.seeking:
        return Colors.deepPurpleAccent;
      case TradeState.offering:
        return Colors.amber.shade700;
      case TradeState.none:
        return Theme.of(context).dividerColor.withAlpha(50);
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (state) {
      case TradeState.seeking:
        return isDark
            ? Colors.deepPurple.shade900.withAlpha(80)
            : Colors.purple.shade50;
      case TradeState.offering:
        return isDark
            ? Colors.amber.shade900.withAlpha(80)
            : Colors.amber.shade50;
      case TradeState.none:
        return isDark ? Colors.grey.shade900 : Colors.white;
    }
  }

  Widget _buildStateBadge() {
    if (state == TradeState.none) return const SizedBox.shrink();

    final isSeeking = state == TradeState.seeking;
    final color = isSeeking ? Colors.deepPurple : Colors.amber.shade800;
    final icon = isSeeking ? Icons.favorite : Icons.swap_horiz;
    final label = isSeeking ? 'BUSCO' : 'OFREZCO';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(100),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor(context);
    final bgColor = _getBackgroundColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: state.isSelected ? 2.5 : 1,
            ),
            boxShadow: [
              if (state.isSelected)
                BoxShadow(
                  color: borderColor.withAlpha(80),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                )
              else
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Stack(
            children: [
              // Badge de estado superior derecho
              Positioned(
                top: 8,
                right: 8,
                child: _buildStateBadge(),
              ),

              // Número de Dex discreto
              Positioned(
                top: 8,
                left: 10,
                child: Text(
                  '#${pokemon.dexNumber.toString().padLeft(3, '0')}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withAlpha(140),
                  ),
                ),
              ),

              // Contenido principal (Imagen + Nombre + Acciones rápidas)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 28, 8, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Imagen responsiva con Fallback
                    Expanded(
                      child: Hero(
                        tag: 'mega_${pokemon.id}',
                        child: Image.network(
                          pokemon.imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // Cargar imagen de respaldo (Home sprite)
                            return Image.network(
                              pokemon.fallbackImageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.catching_pokemon,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Nombre del Pokémon
                    Text(
                      pokemon.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: state.isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Botones de selección directa (Busco / Ofrezco)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.favorite,
                          tooltip: 'Marcar como Buscado',
                          activeColor: Colors.deepPurple,
                          isSelected: state == TradeState.seeking,
                          onPressed: () {
                            onStateSelected(state == TradeState.seeking
                                ? TradeState.none
                                : TradeState.seeking);
                          },
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.swap_horiz,
                          tooltip: 'Marcar como Ofrecido',
                          activeColor: Colors.amber.shade800,
                          isSelected: state == TradeState.offering,
                          onPressed: () {
                            onStateSelected(state == TradeState.offering
                                ? TradeState.none
                                : TradeState.offering);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color activeColor;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.activeColor,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : Theme.of(context).dividerColor.withAlpha(100),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 14,
            color: isSelected
                ? Colors.white
                : Theme.of(context).iconTheme.color?.withAlpha(150),
          ),
        ),
      ),
    );
  }
}
