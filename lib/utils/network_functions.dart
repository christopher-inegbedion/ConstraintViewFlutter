import 'package:http/http.dart' as http;

class NetworkUtils {
  static String serverAddr = "192.168.1.129:";
  static String websocketAddr = "192.168.1.129";
  static String portNum = "8000";
  static String websocketPortNum = "4321";

  static dynamic performNetworkAction(String addr, String path, String method,
      {data}) async {
    http.Response response;

    if (method == "get") {
      response = await http.Client().get(Uri.http(addr, path));
    } else if (method == "post") {
      response = await http.Client().post(Uri.http(addr, path), body: data);
    }

    if (response.statusCode == 200) {
      dynamic result = response.body;
      return result;
    } else {
      return "null";
    }
  }
}
