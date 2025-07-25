import 'package:flutter/material.dart';
import '../services/search_service.dart';
import 'select_episodes_screen.dart';

class SelectSeasonScreen extends StatefulWidget {
  final String tvId;
  final String showTitle;
  SelectSeasonScreen({required this.tvId, required this.showTitle});
  @override
  _SelectSeasonScreenState createState() => _SelectSeasonScreenState();
}

class _SelectSeasonScreenState extends State<SelectSeasonScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _seasons = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSeasons();
  }

  Future<void> _fetchSeasons() async {
    setState(() { _loading = true; _error = null; });
    try {
      final seasons = await SearchService.fetchSeasons(widget.tvId);
      setState(() {
        _seasons = seasons;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load seasons.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Season - ${widget.showTitle}')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _seasons.length,
                  itemBuilder: (context, index) {
                    final season = _seasons[index];
                    return ListTile(
                      leading: season['poster_path'] != null
                          ? Image.network('https://image.tmdb.org/t/p/w92${season['poster_path']}', width: 50)
                          : Icon(Icons.tv),
                      title: Text(season['name'] ?? 'Season'),
                      subtitle: Text('Episodes: ${season['episode_count'] ?? '-'}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectEpisodesScreen(
                              tvId: widget.tvId,
                              showTitle: widget.showTitle,
                              seasonNumber: season['season_number'],
                              seasonName: season['name'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
} 