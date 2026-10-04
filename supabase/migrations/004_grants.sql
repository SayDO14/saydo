grant select, insert, update, delete on public.contacts to authenticated;
grant select, insert on public.emails to authenticated;

-- n8n (service_role): lit les lignes et écrit les IDs Google
grant select, update on public.events, public.tasks to service_role;
grant select, insert, update on public.emails to service_role;

-- Uniquement pour le script save_test.py (à retirer quand Flutter sauvegarde)
grant select on public.profiles to service_role;
grant insert on public.events, public.tasks to service_role;
grant select on public.contacts to service_role;
grant insert, update on public.contacts to service_role;