import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nidoconecta/main.dart';

void main() {
  testWidgets('shows the family daily summary by default', (tester) async {
    await pumpApp(tester);

    expect(find.text('NidoConecta'), findsOneWidget);
    expect(find.text('Mateo'), findsOneWidget);
    expect(find.text('Enviar mensaje'), findsOneWidget);
  });

  testWidgets('switches to educator view', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Educadora'));
    await tester.pumpAndSettle();

    expect(find.text('Clase Mariposas'), findsWidgets);
    expect(find.byIcon(Icons.qr_code_scanner), findsWidgets);
  });

  testWidgets('opens enrollment form from admin view', (tester) async {
    await pumpApp(tester);

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

  testWidgets('opens and submits announcement form from admin view',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Comunicados'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Comunicados'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publicar comunicado'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo comunicado'), findsWidgets);
    await tester.enterText(find.byType(TextFormField).at(0), 'Reunion');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'La reunion sera el proximo viernes.',
    );
    await tester.tap(find.text('Publicar comunicado').last);
    await tester.pumpAndSettle();

    expect(find.text('Comunicado publicado'), findsOneWidget);
  });

  testWidgets('opens and submits calendar event form from admin view',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Calendario'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Calendario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nuevo evento'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo evento'), findsWidgets);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Puertas abiertas',
    );
    await tester.tap(find.text('Crear evento'));
    await tester.pumpAndSettle();

    expect(find.text('Evento creado'), findsOneWidget);
  });

  testWidgets('opens home report form from family view', (tester) async {
    await pumpApp(tester);

    await tester.scrollUntilVisible(
      find.text('Enviar informacion de casa'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar informacion de casa'));
    await tester.pumpAndSettle();

    expect(find.text('Informacion de casa'), findsOneWidget);
    expect(find.text('Como ha dormido'), findsOneWidget);
  });
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const NidoConectaApp());
  await tester.pumpAndSettle();
}
