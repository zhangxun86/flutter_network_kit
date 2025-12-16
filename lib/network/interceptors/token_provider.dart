abstract class TokenProvider {
  /// 获取当前的 Access Token (用于请求头)
  Future<String?> getAccessToken();

  /// 刷新 Token (当 401 发生时调用)
  /// 返回 true 表示刷新成功，可以重试请求；返回 false 表示刷新失败，需跳转登录
  Future<bool> refreshToken();
}