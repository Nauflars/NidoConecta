import 'package:flutter_test/flutter_test.dart';
import 'package:nidoconecta/src/domain/nido_domain.dart';

void main() {
  group('role mapping', () {
    test('maps database role values to domain roles', () {
      expect(roleFromDb('admin'), NidoRole.admin);
      expect(roleFromDb('educator'), NidoRole.educator);
      expect(roleFromDb('family'), NidoRole.family);
      expect(roleFromDb(null), NidoRole.family);
    });

    test('maps domain roles to database values', () {
      expect(roleToDb(NidoRole.admin), 'admin');
      expect(roleToDb(NidoRole.educator), 'educator');
      expect(roleToDb(NidoRole.family), 'family');
    });
  });

  group('daily report mapping', () {
    test('maps meal labels to database values and back', () {
      expect(mealToDb('Todo'), 'all');
      expect(mealToDb('Bastante'), 'most');
      expect(mealToDb('Poco'), 'little');
      expect(mealToDb('Nada'), 'none');
      expect(mealFromDb('all'), 'Todo');
      expect(mealFromDb('most'), 'Bastante');
      expect(mealFromDb('little'), 'Poco');
      expect(mealFromDb('none'), 'Nada');
    });

    test('maps sleep labels to database values and back', () {
      expect(sleepToDb('Bien'), 'good');
      expect(sleepToDb('Regular'), 'regular');
      expect(sleepToDb('Mal'), 'bad');
      expect(sleepToDb('No'), 'none');
      expect(sleepFromDb('good'), 'Bien');
      expect(sleepFromDb('regular'), 'Regular');
      expect(sleepFromDb('bad'), 'Mal');
      expect(sleepFromDb('none'), 'No');
    });
  });

  group('field validation', () {
    test('requires non-empty values', () {
      expect(requiredField(''), 'Campo obligatorio');
      expect(requiredField('  '), 'Campo obligatorio');
      expect(requiredField('Mateo'), isNull);
    });

    test('validates required and optional email fields', () {
      expect(emailField('bad-email'), 'Email no valido');
      expect(emailField('familia@example.com'), isNull);
      expect(optionalEmailField(''), isNull);
      expect(optionalEmailField('madre@example.com'), isNull);
    });

    test('validates birth date format and future dates', () {
      expect(birthDateField('2023-05-10'), isNull);
      expect(birthDateField('10/05/2023'), 'Usa formato AAAA-MM-DD');
      expect(birthDateField('2999-01-01'), 'Fecha futura no valida');
    });
  });

  test('demo daily report contains the requested child id', () {
    final report = demoDailyReport('child-1');

    expect(report.childId, 'child-1');
    expect(report.breakfast, 'Todo');
    expect(report.schoolNotes, isNotEmpty);
  });
}
