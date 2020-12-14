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

    // DEV API
    //this.url = 'eps-dev-api.dbmspilot.org';
    //this.useHttps = true;

    // DEMO API
    //this.url = 'eps-demo-api.dbmspilot.org';
    //this.useHttps = true;
  }
}
