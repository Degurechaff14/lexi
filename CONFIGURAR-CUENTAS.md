# Activar las cuentas de Lexi

Mientras `supabaseUrl` y `supabaseKey` estén vacíos en `index.html`, Lexi funciona como antes: sin cuentas y guardando todo en el navegador. Estos pasos activan el registro con correo y código, el inicio de sesión con Google y el guardado en la nube.

## 1. Crear el proyecto en Supabase
1. Entra a https://supabase.com y pulsa **Start your project**. Regístrate con GitHub o con tu correo.
2. **New project**: nombre `lexi`, una contraseña de base de datos (guárdala) y región **South America (São Paulo)**.
3. Espera 1 o 2 minutos a que termine de crearse.

## 2. Crear las tablas
1. Menú izquierdo: **SQL Editor** → **New query**.
2. Pega todo el contenido de `supabase/setup.sql` y pulsa **Run**. Debe decir *Success*.

## 3. Copiar las claves para la web
1. **Project Settings** (engranaje) → **API** (o **Data API** / **API Keys**).
2. Copia la **Project URL** (`https://xxxx.supabase.co`).
3. Copia la clave **anon public** (o la **publishable key**, `sb_publishable_...`).
   - Esa clave está pensada para ir en la web; las reglas del paso 2 impiden que alguien lea datos ajenos.
   - **Nunca** uses la clave `service_role` ni la `secret`.

## 4. Correo con código de confirmación
1. **Authentication** → **Sign In / Providers** → **Email**: activado, con **Confirm email** activado.
2. **Authentication** → **Emails** → plantilla **Confirm signup**. Reemplaza el contenido por:
   ```html
   <h2>Confirma tu cuenta de Lexi</h2>
   <p>Tu código de confirmación es:</p>
   <p style="font-size:28px;font-weight:bold;letter-spacing:6px">{{ .Token }}</p>
   <p>Si no creaste una cuenta en Lexi, ignora este correo.</p>
   ```
3. Plantilla **Reset password**:
   ```html
   <h2>Recupera tu acceso a Lexi</h2>
   <p>Tu código para crear una contraseña nueva es:</p>
   <p style="font-size:28px;font-weight:bold;letter-spacing:6px">{{ .Token }}</p>
   ```

### Envío de correos (importante)
El correo que trae Supabase por defecto solo envía a los miembros de tu equipo de Supabase y muy pocos por hora. Para que tus testers reciban el código, configura tu propio SMTP:

**Con Gmail (lo más simple):**
1. En tu cuenta de Google activa la **verificación en dos pasos**.
2. Entra a https://myaccount.google.com/apppasswords y crea una **contraseña de aplicación** llamada `Lexi`. Copia las 16 letras.
3. En Supabase: **Authentication** → **Emails** → **SMTP Settings** → **Enable custom SMTP**:
   - Sender email: tu Gmail · Sender name: `Lexi`
   - Host: `smtp.gmail.com` · Port: `465`
   - Username: tu Gmail · Password: la contraseña de aplicación
4. Guarda. Gmail permite unos 500 correos al día.

## 5. Direcciones permitidas
**Authentication** → **URL Configuration**:
- **Site URL:** `https://degurechaff14.github.io/lexi/`
- **Redirect URLs:** agrega `https://degurechaff14.github.io/lexi/`

## 6. Iniciar sesión con Google
1. Entra a https://console.cloud.google.com y crea un proyecto llamado `Lexi`.
2. **APIs y servicios** → **Pantalla de consentimiento de OAuth** (o **Google Auth Platform**):
   - Tipo **Externo**, nombre de la app `Lexi`, tu correo de soporte y de contacto.
   - En **Público / Audience**, publica la app (**Publish app**) para que cualquier cuenta de Google pueda entrar.
3. **Credenciales** → **Crear credenciales** → **ID de cliente de OAuth**:
   - Tipo: **Aplicación web** · Nombre: `Lexi web`
   - **Orígenes autorizados de JavaScript:** `https://degurechaff14.github.io`
   - **URI de redireccionamiento autorizados:** `https://TU-PROYECTO.supabase.co/auth/v1/callback`
     (está en Supabase → Authentication → Sign In / Providers → Google, como *Callback URL*).
4. Copia el **ID de cliente** y el **Secreto del cliente**.
5. En Supabase: **Authentication** → **Sign In / Providers** → **Google**: actívalo, pega ID y secreto y guarda.

## 7. Conectar la web
Pasa a Claude la **Project URL** y la clave **anon/publishable** (paso 3). Claude las pone en `index.html` y publica. O edítalo tú: en `index.html`, busca `window.LEXI_CONFIG` y llena `supabaseUrl` y `supabaseKey`.

## Cómo se manejan los datos
- Cada cuenta solo puede ver sus propios expedientes y notas (reglas *row level security* del paso 2).
- Si alguien ya tenía expedientes en su navegador, al crear su cuenta se pasan a la nube automáticamente (sin los de ejemplo).
- Al cerrar sesión se borra la copia guardada en ese navegador.
- Tú, como dueña del proyecto de Supabase, sí puedes ver los datos desde el panel. Por eso sigue el aviso de no cargar nombres de clientes ni datos personales.
