# Lexi para Android

App de Android que abre la web de Lexi (`https://degurechaff14.github.io/lexi/`) dentro de una app, con su propio ícono. Usa las mismas cuentas y datos que la web, y cada cambio publicado en la web aparece en la app sin reinstalarla.

## Cómo se genera el APK
GitHub lo compila solo con el flujo `.github/workflows/android.yml`:
- cada vez que cambia algo dentro de `android-app/`, o
- a mano: pestaña **Actions** → **App Android (APK)** → **Run workflow**.

El APK queda en la pestaña **Releases** del repositorio. Enlace directo a la última versión:
https://github.com/Degurechaff14/lexi/releases/latest/download/Lexi.apk

## Archivos
- `capacitor.config.json`: nombre, identificador (`pe.lexi.plazos`) y dirección de la web.
- `assets/`: ícono y pantalla de carga; las imágenes de Android se generan a partir de estos archivos.
- `www/index.html`: página que se muestra si no hay internet.

## Limitaciones actuales
- Es un APK de prueba (firmado en modo depuración): para instalarlo hay que permitir "instalar apps de origen desconocido". Para publicarlo en Google Play hace falta firmarlo con una clave propia.
- Dentro de la app no está el botón de Google; quien se registró con Google crea una contraseña con "¿Olvidaste tu contraseña?" y entra con su correo.
