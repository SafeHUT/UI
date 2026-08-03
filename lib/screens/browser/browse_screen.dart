import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final List<String> adDomains = [
    "googleadservices.com",
    "googlesyndication.com",
    "doubleclick.net",
    "facebook.com/tr",
    "analytics.twitter.com",
    "taboola.com",
    "outbrain.com",
    "scorecardresearch.com",
    "criteo.com"
  ];
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  
  final TextEditingController urlController = TextEditingController();
  
  double progress = 0;
  bool canGoBack = false;
  bool canGoForward = false;

  late final InAppWebViewSettings settings = InAppWebViewSettings(
    incognito: true, 
    clearCache: true,
    clearSessionCache: true,
    transparentBackground: true,
    supportZoom: true,
    contentBlockers: _buildContentBlockers(),
  );

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  // This doesn't just "hide" the ads. Because the BLOCK action kills the network request before it leaves the phone,
  // the user actually saves data and the websites load significantly faster.
  // Plus, the ad networks never receive the user's IP address!
  List<ContentBlocker> _buildContentBlockers() {
    List<ContentBlocker> blockers = [];

    for (final domain in adDomains) {
      blockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*$domain.*", 
        ),
        action: ContentBlockerAction(
          type: ContentBlockerActionType.BLOCK, 
        ),
      ));
    }
    blockers.add(ContentBlocker(
      trigger: ContentBlockerTrigger(
        urlFilter: ".*",
      ),
      action: ContentBlockerAction(
        type: ContentBlockerActionType.CSS_DISPLAY_NONE,
        selector: ".ad, .ads, .advert, .banner, .ad-container, [id*='ad-'], [class*='ad-']",
      ),
    ));

    return blockers;
  }
  void _onSearchSubmit(String query) {
    if (query.isEmpty) return;
    
    Uri? uri = Uri.tryParse(query);
    if (uri != null && uri.scheme.isNotEmpty) {
      webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(query)));
    } else if (query.contains('.') && !query.contains(' ')) {
      webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri('https://$query')));
    } else {
      webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri('https://duckduckgo.com/?q=$query')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: urlController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: _onSearchSubmit,
            decoration: InputDecoration(
              hintText: "Search privately or enter URL",
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.greenAccent, size: 18),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white54, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bookmark feature coming soon!")),
                  );
                },
              ),
            ),
          ),
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: canGoBack ? Colors.white : Colors.white30,
              onPressed: canGoBack ? () => webViewController?.goBack() : null,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            color: canGoForward ? Colors.white : Colors.white30,
            onPressed: canGoForward ? () => webViewController?.goForward() : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 22, color: Colors.white),
            onPressed: () => webViewController?.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (progress < 1.0)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              minHeight: 2,
            ),
            
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialSettings: settings,
              initialUrlRequest: URLRequest(url: WebUri("https://duckduckgo.com")),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  urlController.text = url.toString();
                });
              },
              onLoadStop: (controller, url) async {
                final back = await controller.canGoBack();
                final forward = await controller.canGoForward();
                setState(() {
                  urlController.text = url.toString();
                  canGoBack = back;
                  canGoForward = forward;
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}