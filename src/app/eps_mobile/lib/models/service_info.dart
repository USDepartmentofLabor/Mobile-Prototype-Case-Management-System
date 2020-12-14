class ServiceInfo {
  String url;
  bool useHttps;

  ServiceInfo() {
    // iOS LOCAL
    this.url = 'localhost:5000';

    // Android LOCAL
    //this.url = '10.0.2.2:5000';

    // LOCAL
    this.useHttps = false;

    // YOUR API
    //this.url = 'example.com';
    //this.useHttps = true;
  }
}
