import 'package:cloudflare_workers/cloudflare_workers.dart' hide File;
import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:edge_http_client/edge_http_client.dart';
import 'package:http/http.dart' as http;

const clientId = "11****+++++++*";
const privateKey = "-----BEGIN PRIVATE KEY-----\nMII********";
const clientEmail = "******@template-dev-d032e.iam.gserviceaccount.com";

void main() {
  CloudflareWorkers(fetch: (request, env, ctx) async {
    return http.runWithClient(() async {
      final admin = FirebaseAdminApp.initializeApp(
        'template-dev-d032e',
        Credential.fromServiceAccountParams(
          clientId: clientId,
          privateKey: privateKey,
          clientEmail: clientEmail,
        ),
      );
      final firestore = Firestore(admin);
      final collection = firestore.collection('test');
      final snapshot = await collection.get();
      final data = <Map<String, Object?>>[];
      for (final doc in snapshot.docs) {
        data.add(doc.data());
      }

      final auth = Auth(admin);
      await auth.deleteUser("< UserId >");

      // レスポンスに必要のないタスクを実行登録しておいて 早くレスポンスする
      ctx.waitUntil(Future(() async {
        await collection.doc(DateTime.now().toString()).set({
          'age': 32,
          'time': DateTime.now().toIso8601String(),
        });
        await admin.close();
      }));
      return Response("Hello.....${data.map((e) => e.toString())}");
    }, () => EdgeHttpClient());
  });
}
