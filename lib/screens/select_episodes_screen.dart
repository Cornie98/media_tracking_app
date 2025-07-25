import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../models/media_item.dart';
import '../services/log_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectEpisodesScreen extends StatefulWidget {
  final String tvId;
  final String showTitle;
  final int seasonNumber;
  final String seasonName;
  SelectEpisodesScreen({required this.tvId, required this.showTitle, required this.seasonNumber, required this.seasonName});
  @override
  _SelectEpisodesScreenState createState() => _SelectEpisodesScreenState();
}

class _SelectEpisodesScreenState extends State<SelectEpisodesScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _episodes = [];
  Set<int> _selectedEpisodes = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    setState(() { _loading = true; _error = null; });
    try {
      final episodes = await SearchService.fetchEpisodes(widget.tvId, widget.seasonNumber);
      setState(() {
        _episodes = episodes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load episodes.';
        _loading = false;
      });
    }
  }

  void _toggleEpisode(int episodeNumber) {
    setState(() {
      if (_selectedEpisodes.contains(episodeNumber)) {
        _selectedEpisodes.remove(episodeNumber);
      } else {
        _selectedEpisodes.add(episodeNumber);
      }
    });
  }

  Future<void> _logSelectedEpisodes() async {
    if (_selectedEpisodes.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    for (final epNum in _selectedEpisodes) {
      final ep = _episodes.firstWhere((e) => e['episode_number'] == epNum);
      await LogService.saveLog(
        mediaItem: MediaItem(
          id: '${widget.tvId}_S${widget.seasonNumber}_E$epNum',
          type: MediaType.tvShow,
          title: '${widget.showTitle} - S${widget.seasonNumber}E$epNum: ${ep['name']}',
          creator: '',
          coverUrl: ep['still_path'] != null ? 'https://image.tmdb.org/t/p/w500${ep['still_path']}' : '',
          loggedDate: DateTime.now(),
          rating: null,
          review: null,
        ),
        loggedDate: DateTime.now(),
        rating: null,
        review: null,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Episodes logged!')),
    );
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Episodes - ${widget.seasonName}')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _episodes.length,
                        itemBuilder: (context, index) {
                          final ep = _episodes[index];
                          final epNum = ep['episode_number'];
                          return CheckboxListTile(
                            value: _selectedEpisodes.contains(epNum),
                            onChanged: (_) => _toggleEpisode(epNum),
                            title: Text('E$epNum: ${ep['name']}'),
                            subtitle: Text(ep['air_date'] ?? ''),
                            secondary: ep['still_path'] != null
                                ? Image.network('https://image.tmdb.org/t/p/w92${ep['still_path']}', width: 50)
                                : Icon(Icons.tv),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _selectedEpisodes.isNotEmpty ? _logSelectedEpisodes : null,
                        child: Text('Log Selected Episodes'),
                      ),
                    ),
                  ],
                ),
    );
  }
} 