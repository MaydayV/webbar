import Foundation

enum WebViewPresentationProfile {
    static let viewportScriptSource = """
    (function() {
      const content = 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no';
      let meta = document.querySelector('meta[name="viewport"]');
      if (!meta) {
        meta = document.createElement('meta');
        meta.name = 'viewport';
        document.head.appendChild(meta);
      }
      meta.setAttribute('content', content);
    })();
    """

    static func userAgent(forWidth width: CGFloat) -> String {
        if width <= 560 {
            return "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"
        }

        return "Mozilla/5.0 (iPad; CPU OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"
    }
}
