class AppResponse<T> {
  final T data;
  final String error;

  AppResponse.named({this.data, this.error});

  bool get isError => this.data == null;
  bool get isSuccess => this.data != null;
}
