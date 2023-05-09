import 'dart:io';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:shelf_router/shelf_router.dart';

List info = [];

void main() async {
  withHotreload(() => createServer());
}

Future<HttpServer> createServer() async {
  final ip = InternetAddress.anyIPv4;

  final port = int.parse(Platform.environment["PORT"] ?? "8080");

  final router = Router()
    ..get('/profile', (Request req) {
      final jsonBody = json.encode(info);
      return Response.ok(jsonBody);
    })
    //----------------
    ..post('/editprofile/', (Request req) async {
      final body = await req.readAsString();
      final Map jsonBody = json.decode(body);
      info.add(jsonBody);

      bool update = false;

      if (jsonBody.containsKey("name")) {
        info[info.length - 1]['name'] = jsonBody["name"];
        update = true;
      }
      if (jsonBody.containsKey("age")) {
        info[info.length - 1]['age'] = jsonBody["age"];
        update = true;
      }
      if (jsonBody.containsKey("mobile_number")) {
        info[info.length - 1]['mobile_number'] = jsonBody["mobile_number"];
        update = true;
      }
      if (jsonBody.containsKey("city")) {
        info[info.length - 1]['city'] = jsonBody["city"];
        update = true;
      }
      if (update == true) {
        return Response.ok('updated ...');
      } else {
        return Response.ok('there are no update ...');
      }
    })
    ..get('/profile/<id>', (Request req, String index) async {
      if (int.parse(index) >= 0 && int.parse(index) < info.length) {
        final jsonBody = json.encode(info[int.parse(index)]);
        return Response.ok(jsonBody);
      } else {
        return Response.ok("Data not found");
      }
    })
    ..delete('/profile/<id>', (Request req, String index) async {
      if (int.parse(index) >= 0 && int.parse(index) < info.length) {
        info.removeAt(int.parse(index));
       
        return Response.ok("Data has been deleted");
      } else {
        return Response.ok("Data not found");
      }
    });

  final server = await serve(router, ip, port);

  print("serverv is starting at http://${server.address.host}:${server.port}");

  return server;
}
