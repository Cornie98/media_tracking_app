import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/search_service.dart';
import 'media_detail_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  MediaType _selectedType = MediaType.movie;
  final TextEditingController _searchController = TextEditingController();
  List<MediaItem> _results = [];
  bool _isLoading = false;
  String? _error;

  void _onSearch() async {
    final query = _searchController.text.trim();
    if (query.length < 2) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
    });
    try {
      final results = await SearchService.searchAll(query, _selectedType);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error:  {e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Media Type', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: MediaType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.toString().split('.').last),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                      _results = [];
                      _error = null;
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearch,
                  child: Text('Go'),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_isLoading) Center(child: CircularProgressIndicator()),
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
            if (!_isLoading && _results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    return ListTile(
                      leading: Image.network(
                        item.coverUrl,
                        width: 50,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                      ),
                      title: Text(item.title),
                      subtitle: Text(item.creator),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MediaDetailPage(mediaItem: item),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            if (!_isLoading && _results.isEmpty && _searchController.text.isNotEmpty && _error == null)
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Center(child: Text('No results found.')),
              ),
          ],
        ),
      ),
    );
  }
} 