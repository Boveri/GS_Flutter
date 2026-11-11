/// Estados possíveis de um componente que consome dados assíncronos
/// (ex.: WebService ViaCEP).
enum ViewState {
  /// Antes de qualquer carregamento.
  initial,

  /// Requisição em andamento.
  loading,

  /// Dados recebidos corretamente.
  success,

  /// Falha na requisição.
  error,
}
