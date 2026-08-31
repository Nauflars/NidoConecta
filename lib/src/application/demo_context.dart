import '../domain/nido_domain.dart';

class DemoContextFactory {
  const DemoContextFactory._();

  static AppContextData create() {
    return const AppContextData(
      centerId: 'demo-center',
      centerName: 'Centro piloto',
      role: NidoRole.family,
      isDemo: true,
      children: [
        ChildSummary(
          id: 'demo-child-mateo',
          fullName: 'Mateo',
          classroomName: 'Clase Mariposas',
        ),
      ],
    );
  }
}
