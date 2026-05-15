class CarDataset {
  static const Map<String, List<String>> manufacturers = {
    'Tata': ['Nexon', 'Harrier', 'Safari', 'Altroz', 'Punch', 'Tiago', 'Tigor', 'Curvv'],
    'Mahindra': ['XUV700', 'Scorpio-N', 'Thar', 'XUV300', 'Bolero', 'XUV400', 'Marazzo'],
    'Hyundai': ['Creta', 'Verna', 'i20', 'Venue', 'Alcazar', 'Tucson', 'Exter', 'Kona'],
    'Maruti Suzuki': ['Swift', 'Baleno', 'Brezza', 'Grand Vitara', 'Fronx', 'Jimny', 'Ertiga', 'Dzire'],
    'Toyota': ['Fortuner', 'Innova Hycross', 'Urban Cruiser Taisor', 'Hilux', 'Camry', 'Vellfire'],
    'Kia': ['Seltos', 'Sonet', 'Carens', 'EV6', 'Carnival'],
    'Honda': ['City', 'Amaze', 'Elevate', 'Civic', 'Accord'],
    'Volkswagen': ['Virtus', 'Taigun', 'Tiguan', 'Polo', 'Vento'],
    'Skoda': ['Slavia', 'Kushaq', 'Kodiaq', 'Octavia', 'Superb'],
    'MG': ['Hector', 'Astor', 'ZS EV', 'Comet', 'Gloster'],
    'BMW': ['3 Series', '5 Series', '7 Series', 'X1', 'X3', 'X5', 'X7', 'M3', 'M5', 'Z4'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLA', 'GLC', 'GLE', 'GLS', 'AMG GT'],
    'Audi': ['A4', 'A6', 'A8', 'Q3', 'Q5', 'Q7', 'Q8', 'e-tron', 'RS6'],
    'Porsche': ['911 Carrera', '718 Cayman', 'Taycan', 'Panamera', 'Macan', 'Cayenne'],
    'Jeep': ['Compass', 'Meridian', 'Wrangler', 'Grand Cherokee'],
    'Land Rover': ['Defender', 'Range Rover Evoque', 'Velar', 'Discovery', 'Range Rover Sport'],
    'Tesla': ['Model 3', 'Model Y', 'Model S', 'Model X'],
  };

  static List<String> getManufacturers() => manufacturers.keys.toList();
  
  static List<String> getModels(String manufacturer) {
    return manufacturers[manufacturer] ?? [];
  }

  static List<String> search(String query) {
    if (query.isEmpty) return [];
    List<String> results = [];
    manufacturers.forEach((make, models) {
      if (make.toLowerCase().contains(query.toLowerCase())) {
        for (var model in models) {
          results.add('$make $model');
        }
      } else {
        for (var model in models) {
          if (model.toLowerCase().contains(query.toLowerCase())) {
            results.add('$make $model');
          }
        }
      }
    });
    return results;
  }
}
