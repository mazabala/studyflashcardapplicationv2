class UserQueryParams {
  final String? searchQuery;
  final int? page;
  final int? pageSize;
  final String? sortBy;
  final bool? ascending;

  const UserQueryParams({
    this.searchQuery,
    this.page,
    this.pageSize,
    this.sortBy,
    this.ascending,
  });
} 