-- CALE MUSIC · Configuración inicial de almacenamiento privado en Supabase.
-- Ejecutar en Supabase > SQL Editor dentro del proyecto propio.
-- IMPORTANTE: Mantener el bucket PRIVADO. NO utilizar una política "public" para audio.
-- Este script no almacena contraseñas, no necesita claves secretas.

insert into storage.buckets (id, name, public, file_size_limit)
values ('cale-audio', 'cale-audio', false, 52428800)
on conflict (id) do update
set public = false, file_size_limit = 52428800;

drop policy if exists "cale_audio_read_own" on storage.objects;
create policy "cale_audio_read_own"
on storage.objects for select to authenticated
using (
  bucket_id = 'cale-audio'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "cale_audio_insert_own" on storage.objects;
create policy "cale_audio_insert_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'cale-audio'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "cale_audio_delete_own" on storage.objects;
create policy "cale_audio_delete_own"
on storage.objects for delete to authenticated
using (
  bucket_id = 'cale-audio'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

-- Antes de activar el acceso:
-- 1. En Supabase Authentication > URL Configuration, configurar como Site URL:
--    https://cesarbrito1026-creator.github.io/Cale-music/cuenta.html
--    y añadir esa misma URL en Redirect URLs.
-- 2. En Project Settings / API Keys copiar la URL del proyecto y la
--    clave publicable (publishable, NO secret / service_role).
-- 3. Escribir esos dos valores en assets/cale-cloud-config.js.
-- 4. Crear y confirmar tu cuenta desde cuenta.html.
-- 5. Como es una biblioteca personal, desactivar nuevos registros
--    en Supabase Auth una vez que tu propia cuenta esté creada.
-- 6. Las canciones guardadas anteriormente en el navegador NO se migran
--    automáticamente; subirlas nuevamente desde cuenta.html.
-- Advertencia: en plan gratuito, máximo 50 MB por archivo; límites de
-- almacenamiento, transferencia y cuota sujetos al plan vigente.
