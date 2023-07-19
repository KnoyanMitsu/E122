class ApiEndpoint {
  static String getDetailById(String detailId) {
    return '/posts/$detailId.json';
  }

  static String getpost() {
    return '/posts.json?page=1';
  }

  static String gethots() {
    return '/posts.json?d=1&page=1&tags=order%3Arank';
  }

  static String gethotsNext(int _currentPage) {
    return '/posts.json?d=1&page=$_currentPage&tags=order%3Arank';
  }

  static String getPostNext(int _currentPage) {
    return '/posts.json?page=$_currentPage';
  }

  static String getkeyword(String keyword) {
    return '/tags/autocomplete.json?search%5Bname_matches%5D=$keyword';
  }

  static String getResult(String name) {
    return '/posts.json?page=1&tags=$name';
  }

  static String getResultNext(int _currentPage, String name) {
    return '/posts.json?page=$_currentPage&tags=$name';
  }

  static String getDetail(String imageId) {
    return '/posts/$imageId.json';
  }
}
