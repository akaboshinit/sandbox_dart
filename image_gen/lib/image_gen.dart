import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  // ルーターを作成
  final router = Router();

  // PNG画像を返すルートを定義
  // router.get('/image.png', (Request request) {
  router.get('/', (Request request) {
    // 新しい画像を生成
    Image image = Image(width: 200, height: 200);
    fill(image, color: ColorFloat16.rgba(255, 0, 0, 255));

    // 組み込みフォントを使用
    drawString(
        image,
        x: 10,
        y: 100,
        'Hello, World!!!!',
        color: ColorFloat16.rgba(0, 0, 0, 255),
        // fontは外部フォントは使えない
        // edgeではlocalファイルも使えないので現状フォントを変えれない
        font: arial24);

    // PNG形式にエンコード
    List<int> png = encodePng(image);

    // エンコードされたPNGをレスポンスとして返す
    return Response.ok(Stream.fromIterable([png]),
        headers: {'content-type': 'image/png'});
  });

  // PNG画像を返すルートを定義
  router.get('/network-image-rewrite', (Request request) async {
    // ネットワーク上の画像のURL
    var imageUrl =
        'https://github.com/brendan-duncan/image/blob/main/example/thumbnail.png?raw=true';

    // 画像をダウンロード
    var response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      // ダウンロードした画像データをデコード
      Image image = decodeImage(response.bodyBytes)!;

      // 画像に対して操作を行う（例：テキストを追加）
      drawString(
          image,
          x: 0,
          y: 0,
          'Hello, World!',
          color: ColorFloat16.rgba(0, 0, 0, 255),
          font: arial24);

      // PNG形式にエンコード
      List<int> png = encodePng(image);

      // エンコードされたPNGをレスポンスとして返す
      return Response.ok(Stream.fromIterable([png]),
          headers: {'content-type': 'image/png'});
    } else {
      print('Failed to download the image.');
    }
  });

  // サーバーを起動
  // final server = await serve(router, 'localhost', 8080);
  // print('Server listening on port ${server.port}');
  final server = await io.serve(router, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}
