import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/mega_trade_provider.dart';

class TradeSummaryBar extends StatelessWidget {
  final MegaTradeProvider provider;

  const TradeSummaryBar({
    super.key,
    required this.provider,
  });

  void _copyShareableText(BuildContext context) {
    final text = provider.generateShareableText();
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('¡Lista copiada al portapapeles! Listo para enviar.'),
          ],
        ),
        backgroundColor: Colors.purple.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Limpiar wishlist?'),
        content: const Text(
          'Se eliminarán todas tus selecciones actuales de megas buscadas y ofrecidas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.clearAll();
              Navigator.of(ctx).pop();
            },
            child: const Text('Limpiar todo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSelected = provider.totalSelectedCount;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Por debajo de ~900 px los contadores y el botón no caben en una
            // sola fila, así que se apilan para evitar desbordamientos.
            final isMobile = constraints.maxWidth < 900;

            return Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Resumen de contadores
                Row(
                  mainAxisAlignment: isMobile
                      ? MainAxisAlignment.spaceAround
                      : MainAxisAlignment.start,
                  children: [
                    _CounterChip(
                      icon: Icons.favorite,
                      color: Colors.deepPurple,
                      label: 'Busco',
                      count: provider.seekingCount,
                    ),
                    const SizedBox(width: 12),
                    _CounterChip(
                      icon: Icons.swap_horiz,
                      color: Colors.amber.shade800,
                      label: 'Ofrezco',
                      count: provider.offeringCount,
                    ),
                    if (totalSelected > 0) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: 'Limpiar selecciones',
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.grey),
                        onPressed: () => _showClearDialog(context),
                      ),
                    ],
                  ],
                ),
                if (isMobile) const SizedBox(height: 10),

                // Botón principal de copiar lista
                ElevatedButton.icon(
                  onPressed: totalSelected == 0
                      ? null
                      : () => _copyShareableText(context),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(
                    totalSelected == 0
                        ? 'Selecciona megas para exportar'
                        : 'Copiar Lista para Intercambio',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: totalSelected > 0 ? 3 : 0,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CounterChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;

  const _CounterChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
