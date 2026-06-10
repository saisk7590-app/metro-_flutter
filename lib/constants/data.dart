class AppData {
  static const List<String> depots = ['Miyapur', 'Uppal'];

  static final List<String> trainsets = List.generate(
    57,
    (index) => 'TS${(index + 1).toString().padLeft(3, '0')}',
  );

  static const Map<String, List<String>> sections = {
    'Miyapur': ['Test Line', 'SBL', 'IBL', 'Wash Plant', 'Permanent Way'],

    'Uppal': ['Test Line', 'SBL', 'IBL', 'Wheel Lathe', 'Maintenance'],
  };

  static final Map<String, Map<String, List<String>>> tracks = {
    'Miyapur': {
      'Test Line': ['MPTT'],

      'Wash Plant': ['MPWP'],

      'Permanent Way': ['MPPW1', 'MPPW2'],

      'IBL': [
        'MPIBL01BE',
        'MPIBL02BE',
        'MPIBL03BE',
        'MPIBL04BE',
        'MPIBL01OE',
        'MPIBL02OE',
        'MPIBL03OE',
        'MPIBL04OE',
      ],

      'SBL': [
        for (int i = 1; i <= 12; i++) 'MPSBL${i.toString().padLeft(2, '0')}BE',

        for (int i = 1; i <= 12; i++) 'MPSBL${i.toString().padLeft(2, '0')}OE',
      ],
    },

    'Uppal': {
      'Test Line': ['UPLTT'],

      'Wheel Lathe': ['UPLWL'],

      'Maintenance': ['UPLMAIN01', 'UPLMAIN02', 'UPLMAIN03', 'UPLMAIN04'],

      'IBL': [
        'UPLIBL01BE',
        'UPLIBL02BE',
        'UPLIBL03BE',
        'UPLIBL04BE',
        'UPLIBL01OE',
        'UPLIBL02OE',
        'UPLIBL03OE',
        'UPLIBL04OE',
      ],

      'SBL': [
        for (int i = 1; i <= 12; i++) 'UPLSBL${i.toString().padLeft(2, '0')}BE',

        for (int i = 1; i <= 12; i++) 'UPLSBL${i.toString().padLeft(2, '0')}OE',
      ],
    },
  };

  static const List<String> status = [
    'Running',
    'Idle',
    'Maintenance',
    'Failure',
  ];
}
