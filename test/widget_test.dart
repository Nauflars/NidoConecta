import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nidoconecta/main.dart';

void main() {
  testWidgets('shows the family daily summary by default', (tester) async {
    await tester.pumpWidget(const NidoConectaApp());

    expect(find.text('NidoConecta'), findsOneWidget);
    expect(find.text('Mateo'), findsOneWidget);
    expect(find.text('Enviar mensaje'), findsOneWidget);
  });

  testWidgets('switches to educator view', (tester) async {
    await tester.pumpWidget(const NidoConectaApp());

    await tester.tap(find.text('Educadora'));
    await tester.pumpAndSettle();

    expect(find.text('Clase Mariposas'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
  });
}
