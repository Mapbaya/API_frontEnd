import 'dart:convert';

import 'package:http/http.dart' as http;

/// Récupère la liste des articles pour un numéro de fournisseur donné.
Future<List<dynamic>> fetchArticles(String frs) async {
  final url = 'http://polyedre.eu:8000/polyfx/cgi/getart.cgi?frs=$frs';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data is List) {
      return data;
    }

    if (data is Map && data['articles'] is List) {
      return data['articles'] as List<dynamic>;
    }

    throw Exception('Format JSON inattendu');
  } else {
    throw Exception('Erreur serveur : ${response.statusCode}');
  }
}

/// URL des fournisseurs pour le TD1.
/// Si tu es en TD2, remplace `getfrstd1.cgi` par `getfrstd2.cgi`.
const String suppliersUrl = 'http://polyedre.eu:8000/polyfx/cgi/getfrstd2.cgi';

/// Récupère la liste des fournisseurs (étudiants) avec leur numéro de fournisseur.
Future<List<dynamic>> fetchSuppliers() async {
  final response = await http.get(Uri.parse(suppliersUrl));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data is List) {
      return data;
    }

    if (data is Map && data['fournisseurs'] is List) {
      return data['fournisseurs'] as List<dynamic>;
    }

    throw Exception('Format JSON inattendu (fournisseurs)');
  } else {
    throw Exception('Erreur serveur fournisseurs : ${response.statusCode}');
  }
}
