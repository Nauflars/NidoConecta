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

  testWidgets('opens enrollment form from admin view', (tester) async {
    await tester.pumpWidget(const NidoConectaApp());

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva alta'));
    await tester.pumpAndSettle();

    expect(find.text('Expediente y accesos'), findsOneWidget);
    expect(find.text('Nombre completo'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Email padre o tutor'), findsOneWidget);
  });
}
