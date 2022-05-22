enum Status {
  loading,
  failed,
  success,
}

class Resource<T> {
  late Status status;
  late T data;
  String? errorMessage;

  Resource(this.status, this.data);

  Resource.failure(this.errorMessage) {
    status = Status.failed;
  }

  Resource.success(this.data) {
    status = Status.success;
  }

  Resource.loading() {
    status = Status.loading;
  }
}
