import 'package:html/parser.dart' as html_parser;

/// HTML açıklamalarındaki etiketleri temizler ve sadece düz metni döner.
class HtmlUtils {
  static String cleanHtml(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text.trim() ?? '';
  }
}

