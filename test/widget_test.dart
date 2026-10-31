import 'package:flutter_test/flutter_test.dart';
import 'package:wishlist_megas_pogo/main.dart';

void main() {
  testWidgets('MegaWishlistApp loads title correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MegaWishlistApp());
    expect(find.text('MegaEvoluciones Wishlist'), findsOneWidget);
  });
}
