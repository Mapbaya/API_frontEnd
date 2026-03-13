import 'package:flutter/material.dart';
import 'api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boutique IUT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ArticlesPage(),
    );
  }
}

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  late Future<List<dynamic>> _futureArticles;
  late Future<List<dynamic>> _futureSuppliers;
  String _currentFrs = '401000394'; // À adapter avec TON n° de fournisseur si besoin.

  @override
  void initState() {
    super.initState();
    _futureSuppliers = fetchSuppliers();
    _futureArticles = fetchArticles(_currentFrs);
  }

  void _chargerArticlesPourFournisseur(String frs) {
    setState(() {
      _currentFrs = frs;
      _futureArticles = fetchArticles(_currentFrs);
    });
  }

  Widget _buildSuppliersBand() {
    return FutureBuilder<List<dynamic>>(
      future: _futureSuppliers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur fournisseurs : ${snapshot.error}'),
          );
        }

        final suppliers = snapshot.data;
        if (suppliers == null || suppliers.isEmpty) {
          return const Center(
            child: Text('Aucun fournisseur trouvé'),
          );
        }

        // Construire la liste des items pour un menu déroulant.
        final items = <DropdownMenuItem<String>>[];
        for (final s in suppliers) {
          if (s is! Map<String, dynamic>) continue;

          final nom = (s['name'] ??
                  s['nom'] ??
                  s['label'] ??
                  s['etudiant'] ??
                  'Fournisseur')
              .toString();
          final frs =
              (s['frs'] ?? s['id'] ?? s['num'])?.toString();
          if (frs == null) continue;

          items.add(
            DropdownMenuItem<String>(
              value: frs,
              child: Text('$nom ($frs)'),
            ),
          );
        }

        if (items.isEmpty) {
          return const Center(
            child: Text('Aucun fournisseur trouvable'),
          );
        }

        // S'assurer que la valeur courante est bien dans la liste.
        final currentValue = items.any((item) => item.value == _currentFrs)
            ? _currentFrs
            : items.first.value;

        return DropdownButtonFormField<String>(
          value: currentValue,
          items: items,
          decoration: const InputDecoration(
            labelText: 'Choisir un fournisseur',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value != null) {
              _chargerArticlesPourFournisseur(value);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique IUT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(
              height: 90,
              child: _buildSuppliersBand(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _futureArticles,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Erreur : ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _chargerArticlesPourFournisseur(
                              _currentFrs,
                            ),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }

                  final articles = snapshot.data;

                  if (articles == null || articles.isEmpty) {
                    return const Center(
                      child: Text('Aucun article trouvé'),
                    );
                  }

                  return ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];

                      if (article is Map<String, dynamic>) {
                        // Adapté aux champs réellement renvoyés par ton JSON :
                        // id, name, price, description, image
                        final code = article['id']?.toString() ?? 'Sans code';
                        final libelle =
                            article['name']?.toString() ?? 'Sans libellé';
                        final prix = article['price']?.toString() ?? '';
                        final description =
                            article['description']?.toString() ?? '';
                        final imageUrl = article['image']?.toString();

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ArticleDetailPage(
                                    article: article,
                                  ),
                                ),
                              );
                            },
                            leading: imageUrl != null && imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.image_not_supported,
                                          size: 32,
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
                                    Icons.image_not_supported,
                                    size: 32,
                                  ),
                            title: Text(libelle),
                            subtitle: Text(
                              description.isNotEmpty
                                  ? 'Code : $code\n$description'
                                  : 'Code : $code',
                            ),
                            trailing: prix.isNotEmpty ? Text('$prix €') : null,
                          ),
                        );
                      }

                      return ListTile(
                        title: Text(article.toString()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key, required this.article});

  final Map<String, dynamic> article;

  @override
  Widget build(BuildContext context) {
    final code = article['id']?.toString() ?? 'Sans code';
    final libelle = article['name']?.toString() ?? 'Sans libellé';
    final prix = article['price']?.toString() ?? '';
    final description = article['description']?.toString() ?? '';
    final imageUrl = article['image']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(libelle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 80,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 80,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              libelle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Code : $code',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (prix.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '$prix €',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.blue),
              ),
            ],
            const SizedBox(height: 16),
            if (description.isNotEmpty)
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}