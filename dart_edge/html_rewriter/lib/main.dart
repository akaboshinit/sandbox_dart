import 'package:cloudflare_workers/cloudflare_workers.dart' hide File;

void main() {
  CloudflareWorkers(fetch: (request, env, ctx) async {
    final noneOgpRes = await fetch(
        Resource('https://flutter-web-cloudflare-ogp.web.app/aaaa'));
    final siteUrl = noneOgpRes.url.toString();
    return HTMLRewriter()
        .on(
            "head",
            OGPElementHandler(
              siteName: 'flutter-web-cloudflare-ogp',
              // fluter側で設定したtitleが強制的に反映されるけど、クローニング等のためにここでも設定しておく
              title: 'Ogp Example | flutter-web-cloudflare-ogp',
              siteUrl: siteUrl,
              description: 'flutter-web-cloudflare-ogp description',
              image: 'https://cdn2.thecatapi.com/images/5ia.jpg',
              imageAlt: 'cat image',
            ))
        .transform(noneOgpRes);
  });
}

class OGPElementHandler extends ElementHandler {
  OGPElementHandler({
    required this.title,
    required this.description,
    required this.siteName,
    required this.siteUrl,
    required this.image,
    required this.imageAlt,
  });

  final String title;
  final String description;
  final String siteName;
  final String siteUrl;
  final String image;
  final String imageAlt;

  @override
  FutureOr<void> element(Element element) {
    element.before("""
<title>$title</title>
<meta name="description" content="$description" />
<meta property="og:title" content="$title" />
<meta property="og:type" content="website" />
<meta property="og:site_name" content="$siteName" />
<meta property="og:description" content="$description" />
<meta property="og:url" content="$siteUrl" />
<meta property="og:image" content="$image" />
<meta property="og:image:alt" content="$imageAlt" />
<meta property="twitter:title" content="$title" />
<meta property="twitter:description" content="$description" />
<meta property="twitter:card" content="summary_large_image" />
<meta property="twitter:image:src" content="$image" />
""", ContentOptions(html: true));
  }
}
