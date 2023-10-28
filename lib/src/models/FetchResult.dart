enum ResultStatus { success, failure }

class FetchResult<T> {
  final ResultStatus status;
  final T data;

  FetchResult(this.status, this.data);
}
