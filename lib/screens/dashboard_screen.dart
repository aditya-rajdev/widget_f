import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/link_model.dart';
import '../services/link_service.dart';
import 'add_link_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<LinkModel> _links = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    final loaded = await LinkService.loadLinks();
    setState(() {
      _links = loaded;
      _isLoading = false;
    });
  }

  Future<void> _saveLinks(List<LinkModel> updatedLinks) async {
    setState(() {
      _links = updatedLinks;
    });
    await LinkService.saveLinks(updatedLinks);
  }

  Color _getCardColor(String url) {
    if (url.isEmpty) return const Color(0xFF1A1A1A);
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.contains('youtube') || lowerUrl.contains('youtu.be')) {
      return const Color(0xFFDE0000); // Red
    }
    if (lowerUrl.contains('github')) {
      return const Color(0xFFDBDBDB); // Light Gray / Black
    }
    if (lowerUrl.contains('linkedin')) {
      return const Color(0xFF006DE1); // Blue
    }
    if (lowerUrl.contains('leetcode')) {
      return const Color(0xFFEC9C08); // Orange
    }
    if (lowerUrl.contains('instagram')) {
      return const Color(0xFFDF088D); // Magenta
    }

    return const Color(0xFF1A1A1A); // Dark Gray default
  }

  Color _getTextColor(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('github')) {
      return Colors.black;
    }
    return Colors.white;
  }

  String _getIconAsset(String url) {
    if (url.isEmpty) return 'assets/icons/link.png';
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.contains('youtube') || lowerUrl.contains('youtu.be')) {
      return 'assets/icons/youtube.png';
    }
    if (lowerUrl.contains('github')) {
      return 'assets/icons/github.png';
    }
    if (lowerUrl.contains('linkedin')) {
      return 'assets/icons/linkedin.png';
    }
    if (lowerUrl.contains('leetcode')) {
      return 'assets/icons/leetcode.png';
    }
    if (lowerUrl.contains('instagram')) {
      return 'assets/icons/instagram.png';
    }

    return 'assets/icons/link.png';
  }

  Future<void> _openLink(String urlString) async {
    if (urlString.isEmpty) return;
    String formattedUrl = urlString.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    final Uri? uri = Uri.tryParse(formattedUrl);
    if (uri != null) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(uri);
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Could not open link',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF323232),
          textColor: Colors.white,
        );
      }
    }
  }

  void _showOptions(LinkModel item) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            item.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Choose an action',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddLinkScreen(
                      editLink: item,
                      onSave: (updatedLink) {
                        // Duplication check for edit workflow
                        final isDuplicate = _links.any((link) =>
                            link.id != updatedLink.id &&
                            (link.title.toLowerCase() ==
                                    updatedLink.title.toLowerCase() ||
                                link.url.toLowerCase() ==
                                    updatedLink.url.toLowerCase()));

                        if (isDuplicate) {
                          Fluttertoast.showToast(
                            msg: 'Same name ya link pehle se exist karta hai!',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: const Color(0xFF323232),
                            textColor: Colors.white,
                          );
                          return;
                        }

                        final updatedLinks = _links
                            .map((link) =>
                                link.id == updatedLink.id ? updatedLink : link)
                            .toList();
                        _saveLinks(updatedLinks);
                      },
                    ),
                  ),
                );
              },
              child: const Text('Edit', style: TextStyle(color: Color(0xFF4F46E5))),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final updatedLinks =
                    _links.where((x) => x.id != item.id).toList();
                await _saveLinks(updatedLinks);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddLink() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddLinkScreen(
          onSave: (newLink) {
            // Duplication check for adding new link workflow
            final isDuplicate = _links.any((link) =>
                link.title.toLowerCase() == newLink.title.toLowerCase() ||
                link.url.toLowerCase() == newLink.url.toLowerCase());

            if (isDuplicate) {
              Fluttertoast.showToast(
                msg: 'Link or Title already exists',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: const Color(0xFF323232),
                textColor: Colors.white,
              );
              return;
            }

            final updatedLinks = [..._links, newLink];
            _saveLinks(updatedLinks);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Zurl',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _navigateToAddLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '+ Add Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4F46E5),
                        ),
                      )
                    : _links.isEmpty
                        ? const Center(
                            child: Text(
                              'No links added yet',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _links.length,
                            itemBuilder: (context, index) {
                              final item = _links[index];
                              final cardColor = _getCardColor(item.url);
                              final textColor = _getTextColor(item.url);
                              final iconPath = _getIconAsset(item.url);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _openLink(item.url),
                                    onLongPress: () => _showOptions(item),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 20,
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            iconPath,
                                            width: 28,
                                            height: 28,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Icon(
                                              Icons.link,
                                              color: textColor,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
