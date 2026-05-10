# De la Conversación a la Coordinación

App web ligera (un solo `index.html`) que implementa una encuesta breve y anónima para alinear prioridades de un grupo privado de WhatsApp. Frontend estático en GitHub Pages, backend en Supabase, sin login ni datos personales.

## Stack

- **Frontend**: HTML + CSS + JS vanilla (sin build step)
- **Backend**: Supabase (Postgres + RLS)
- **Hosting**: GitHub Pages
- **Tema**: toggle día/noche con persistencia en `localStorage`

## Despliegue

### A. Supabase (una sola vez)

1. Crear cuenta gratis en [supabase.com](https://supabase.com) → **New Project**.
2. En el SQL Editor, abrir `supabase-setup.sql` (incluido en este repo) y ejecutarlo. Crea:
   - Tabla `responses` (anónima, con UUID y timestamp)
   - Política RLS que solo permite **INSERT** anónimo (max 3 prioridades)
   - Función pública `get_stats()` para el contador y los agregados
3. **Settings → API** → copiar:
   - `Project URL`
   - `anon public key`
4. Pegarlos en `index.html`, en las constantes:
   ```js
   const SUPABASE_URL      = 'TU_SUPABASE_URL_AQUI';
   const SUPABASE_ANON_KEY = 'TU_SUPABASE_ANON_KEY_AQUI';
   ```

> Nota: la `anon` key es pública por diseño. RLS protege la tabla — ningún cliente puede leer filas individuales, solo insertar y consultar agregados vía `get_stats()`.

### B. GitHub Pages

1. Crear un repo público nuevo en GitHub (ej. `consenso-grupo`).
2. Subir **solo** estos archivos al repo:
   - `index.html`
   - `README.md`
   - `supabase-setup.sql` (referencia, no necesario en runtime)
   - `.gitignore`

   El `.gitignore` ya excluye los archivos fuente privados (`.docx`, `.pdf`, `.zip`, `Derecha_chat.txt`, `consenso-social-rwing.md.txt`).

3. **Settings → Pages → Build and deployment**:
   - Source: `Deploy from a branch`
   - Branch: `main` / `(root)` → Save
4. Tras ~1 minuto, la URL pública estará en:
   `https://<tu-usuario>.github.io/<nombre-repo>/`

5. Compartir esa URL por WhatsApp.

## Uso local (dev)

Abre `index.html` con doble click. Funciona directamente en el navegador (los imports vienen de CDN ESM).

## Verificación

- [ ] Completar encuesta de prueba → fila aparece en Supabase Table Editor
- [ ] Contador del landing se actualiza al recargar
- [ ] Toggle ☀️/🌙 alterna y persiste tras recargar
- [ ] Bloque de prioridades bloquea la 4ª selección
- [ ] Tras enviar, recargar la página redirige a la pantalla de agradecimiento (anti doble-envío)
- [ ] Probar en móvil real (iOS Safari / Android Chrome) vía link de GitHub Pages
- [ ] Botón "Compartir por WhatsApp" abre el deep link correcto

## Reset (testing)

Para volver a probar el flujo completo en el mismo navegador:

```js
localStorage.removeItem('submitted');
```

en la consola del navegador.

## Privacidad

- Sin login, sin email, sin identificadores personales
- ID generado por Postgres (UUID v4) sin vínculo con el cliente
- RLS de Supabase impide cualquier `SELECT` individual
- Solo se exponen agregados a través de `get_stats()`

## Estructura del repo

```
.
├── index.html             # App completa
├── supabase-setup.sql     # DDL para correr una vez en Supabase
├── README.md              # Este archivo
└── .gitignore             # Excluye fuentes privadas del repo público
```
