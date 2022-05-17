enum Status {
  LOADING,
  FAILED,
  SUCCESS,
}

class Resource<T> {
  late Status status;
  late T data;
  String? errorMessage;

  Resource(this.status, this.data);

  Resource.failure(this.errorMessage) {
    status = Status.FAILED;
  }

  Resource.success(this.data) {
    status = Status.SUCCESS;
  }

  Resource.loading() {
    status = Status.LOADING;
  }
}
