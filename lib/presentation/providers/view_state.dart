/// Estados posibles de una pantalla que carga datos.
/// Se usa en todos los providers para que la UI sepa qué mostrar
/// (spinner, error, contenido o vacío).
enum ViewState { initial, loading, loaded, error, empty }
