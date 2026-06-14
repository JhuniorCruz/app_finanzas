DROP TABLE IF EXISTS public.debts, public.profiles, public.transactions CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user CASCADE;
SET default_transaction_read_only = off;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  insert into public.profiles (
    id,
    income_type,
    savings_target,
    debt_to_income_threshold,
    utilization_threshold,
    reminders
  ) values (
    new.id,
    'mensual',
    10.0,
    40.0,
    50.0,
    false
  )
  on conflict (id) do nothing;

  return new;
end;
$$;



--
SET default_tablespace = '';
SET default_table_access_method = heap;
-- Name: debts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.debts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name text NOT NULL,
    amount double precision NOT NULL,
    total_debt double precision NOT NULL,
    credit_limit double precision,
    due_date date NOT NULL,
    paid boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    paid_at timestamp with time zone,
    CONSTRAINT debts_amount_check CHECK ((amount >= (0)::double precision)),
    CONSTRAINT debts_total_debt_check CHECK ((total_debt >= (0)::double precision))
);



--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    income_type text DEFAULT 'mensual'::text,
    savings_target double precision DEFAULT 10.0 NOT NULL,
    debt_to_income_threshold double precision DEFAULT 40.0 NOT NULL,
    utilization_threshold double precision DEFAULT 50.0 NOT NULL,
    reminders boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);



--
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    type text NOT NULL,
    amount double precision NOT NULL,
    date timestamp with time zone NOT NULL,
    category text NOT NULL,
    note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT transactions_amount_check CHECK ((amount >= (0)::double precision)),
    CONSTRAINT transactions_type_check CHECK ((type = ANY (ARRAY['income'::text, 'expense'::text])))
);



--


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: debts; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 99, true);
SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);
-- Name: debts debts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.debts
    ADD CONSTRAINT debts_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: idx_debts_user_duedate; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_debts_user_duedate ON public.debts USING btree (user_id, due_date DESC);


--
-- Name: idx_debts_user_paid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_debts_user_paid ON public.debts USING btree (user_id, paid, due_date);


--
-- Name: idx_transactions_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_user_date ON public.transactions USING btree (user_id, date DESC);


--
-- Name: debts debts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.debts
    ADD CONSTRAINT debts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: debts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.debts ENABLE ROW LEVEL SECURITY;

--
-- Name: debts debts_delete_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY debts_delete_own ON public.debts FOR DELETE USING ((auth.uid() = user_id));


--
-- Name: debts debts_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY debts_insert_own ON public.debts FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: debts debts_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY debts_select_own ON public.debts FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: debts debts_update_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY debts_update_own ON public.debts FOR UPDATE USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profiles_delete_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_delete_own ON public.profiles FOR DELETE USING ((auth.uid() = id));


--
-- Name: profiles profiles_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_insert_own ON public.profiles FOR INSERT WITH CHECK ((auth.uid() = id));


--
-- Name: profiles profiles_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_select_own ON public.profiles FOR SELECT USING ((auth.uid() = id));


--
-- Name: profiles profiles_update_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_update_own ON public.profiles FOR UPDATE USING ((auth.uid() = id)) WITH CHECK ((auth.uid() = id));


--
-- Name: transactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

--
-- Name: transactions tx_delete_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY tx_delete_own ON public.transactions FOR DELETE USING ((auth.uid() = user_id));


--
-- Name: transactions tx_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY tx_insert_own ON public.transactions FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: transactions tx_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY tx_select_own ON public.transactions FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: transactions tx_update_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY tx_update_own ON public.transactions FOR UPDATE USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- Name: TABLE debts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.debts TO anon;
GRANT ALL ON TABLE public.debts TO authenticated;
GRANT ALL ON TABLE public.debts TO service_role;


--
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- Name: TABLE transactions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.transactions TO anon;
GRANT ALL ON TABLE public.transactions TO authenticated;
GRANT ALL ON TABLE public.transactions TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--



--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--



--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--



--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--



--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--



--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--



--
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', 'adba3600-c94a-46ad-8a66-03fa6e32e79e', 'authenticated', 'authenticated', 'cruz27@gmail.com', '$2a$10$OBQ8XEPG8vshmJeV5cQOKOiI48zPYqegmrMmCWfmLR67REBXH4a1i', '2025-11-01 08:20:21.887652+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-01 08:20:33.23438+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "adba3600-c94a-46ad-8a66-03fa6e32e79e", "email": "cruz27@gmail.com", "full_name": "Cruz", "email_verified": true, "phone_verified": false}', NULL, '2025-11-01 08:20:21.782332+00', '2025-11-01 08:20:33.236809+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '5134f328-1aa9-41f1-aa85-27baab3ffb03', 'authenticated', 'authenticated', 'les17mari@gmail.com', '$2a$10$L6sRyG4EDJVJEamOQDB1kOOGkoU7DlTSdsmNd9du.ToTk.ly96S6m', '2025-10-26 16:51:23.489258+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-03 00:59:35.598499+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "5134f328-1aa9-41f1-aa85-27baab3ffb03", "email": "les17mari@gmail.com", "full_name": "Mariluz", "email_verified": true, "phone_verified": false}', NULL, '2025-10-26 16:51:23.462206+00', '2025-11-07 16:28:06.680756+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '7188adff-27f9-41a3-a484-e3170491f2b4', 'authenticated', 'authenticated', 'jr27efootball@gmail.com', '$2a$10$1w7eVmSSRzeq9TOZiB2NqO8Tbb2Y01HNYppTZUYLLNO4V1ltta7py', '2025-10-26 08:31:29.213865+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-10-26 08:31:46.123306+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "7188adff-27f9-41a3-a484-e3170491f2b4", "email": "jr27efootball@gmail.com", "full_name": "Anakin", "email_verified": true, "phone_verified": false}', NULL, '2025-10-26 08:31:29.191933+00', '2025-10-26 08:31:46.125874+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'authenticated', 'authenticated', 'ceilita1580@gmail.com', '$2a$10$oCqPHKHXoSIKF1Ot4WxwpeKFuzP7/mqO2TAFEN9wGzBsHc6cXDj5G', '2025-10-27 20:25:46.763943+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-10-27 20:25:55.324547+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "7c5383bc-f4b5-4ced-bc6e-14624442eed4", "email": "ceilita1580@gmail.com", "full_name": "Ceila", "email_verified": true, "phone_verified": false}', NULL, '2025-10-27 20:25:46.649936+00', '2025-11-03 18:15:22.206049+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'authenticated', 'authenticated', 'steven27x01@gmail.com', '$2a$10$MmlHn8E6xowCeNpTLrhe5OJwyrKLX3q7fD6mjrvlHEFw2bjKmrTwa', '2025-10-23 09:29:12.359472+00', NULL, '', '2025-10-23 09:28:43.377585+00', '', NULL, '', '', NULL, '2025-10-26 06:49:42.479322+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "9e3287a0-abfc-4234-8ecf-2f0a8ca5a801", "email": "steven27x01@gmail.com", "full_name": "Steven", "email_verified": true, "phone_verified": false}', NULL, '2025-10-23 09:28:43.3436+00', '2025-10-26 06:49:42.484219+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '63446142-dc7c-4d0e-a6c9-492b98b62121', 'authenticated', 'authenticated', 'blasesther36@gmail.com', '$2a$10$HXs9d3XfZqXpsPuKEVjNKeMGtdSrz1e3mt5ut7vZrrkCmhMEtO1Hi', '2025-11-02 03:39:17.942358+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-02 03:39:36.604696+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "63446142-dc7c-4d0e-a6c9-492b98b62121", "email": "blasesther36@gmail.com", "full_name": "Esther Elizabeth Blas Gutierrez", "email_verified": true, "phone_verified": false}', NULL, '2025-11-02 03:39:17.815785+00', '2025-11-03 22:58:35.081904+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '0d7819d0-3444-4968-8793-f7a11d7d3ea4', 'authenticated', 'authenticated', 'jhuniorcruzcruz@gmail.com', '$2a$10$11KzZBKZqIZrheyc2P5BpecctjQesIZnvnMaWmVoiZsCsn41VHUAG', '2025-10-26 07:12:36.022447+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-01 08:18:32.616353+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "0d7819d0-3444-4968-8793-f7a11d7d3ea4", "email": "jhuniorcruzcruz@gmail.com", "full_name": "Mylo", "email_verified": true, "phone_verified": false}', NULL, '2025-10-26 07:12:35.99256+00', '2025-11-01 08:18:32.638101+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', 'aa3ac35a-e193-454d-bf07-3b89386c0c32', 'authenticated', 'authenticated', 'hernan.cruz980@gmail.com', '$2a$10$O/tEaICY9d3jx6HHs3s1R.BBx2GgNiTNIJvOtt/58ZpB3OO9gvhC2', '2025-11-01 17:47:27.547454+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-01 17:47:56.401155+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "aa3ac35a-e193-454d-bf07-3b89386c0c32", "email": "hernan.cruz980@gmail.com", "full_name": "Hernan", "email_verified": true, "phone_verified": false}', NULL, '2025-11-01 17:47:27.421593+00', '2025-11-12 23:33:09.318158+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '55b7c1c0-fdb8-4cdf-9938-761ddb309d2f', 'authenticated', 'authenticated', 'maricarmenbeatrizhilariocruz@gmail.com', '$2a$10$QEwg72sXJv26bZ9YHRHzuO9Jhhmqwftb00wZUKF0MIW5E0S7PHhIC', '2025-11-02 03:43:11.153657+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-02 03:43:11.158634+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "55b7c1c0-fdb8-4cdf-9938-761ddb309d2f", "email": "maricarmenbeatrizhilariocruz@gmail.com", "full_name": "maricarmen", "email_verified": true, "phone_verified": false}', NULL, '2025-11-02 03:43:11.130302+00', '2025-11-02 03:43:11.163145+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '7ac519cb-b5fe-460f-9909-255634767327', 'authenticated', 'authenticated', 'jc392355@gmail.com', '$2a$10$Odtf9t1HuY3M2I3WT1L.Fu1xZ8.3wg2UVBCipO4SUTm6ySaAuSS0K', '2025-10-30 16:05:03.252432+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-10-30 16:05:13.747804+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "7ac519cb-b5fe-460f-9909-255634767327", "email": "jc392355@gmail.com", "full_name": "José Alvarado Cruz", "email_verified": true, "phone_verified": false}', NULL, '2025-10-30 16:05:03.136396+00', '2025-10-30 16:05:13.75248+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'authenticated', 'authenticated', 'jr11steven@gmail.com', '$2a$10$1g0SzZW3SEW0HWJHB5oFRuO7XzR5dXDH38RnUIp4z0QrWWAV9UpLG', '2025-10-22 10:46:06.773053+00', NULL, '', '2025-10-22 10:45:44.919766+00', '', '2025-10-26 01:42:59.487804+00', '', '', NULL, '2025-11-02 15:24:45.962609+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "75d12d56-fc94-42da-9da1-c5c8459d8f29", "name": "Jhunior Cruz", "email": "jr11steven@gmail.com", "email_verified": true, "phone_verified": false}', NULL, '2025-10-22 10:45:44.853511+00', '2025-11-05 16:27:38.1969+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('75d12d56-fc94-42da-9da1-c5c8459d8f29', '75d12d56-fc94-42da-9da1-c5c8459d8f29', '{"sub": "75d12d56-fc94-42da-9da1-c5c8459d8f29", "name": "Jhunior Cruz", "email": "jr11steven@gmail.com", "email_verified": true, "phone_verified": false}', 'email', '2025-10-22 10:45:44.893007+00', '2025-10-22 10:45:44.89306+00', '2025-10-22 10:45:44.89306+00', '623172c3-ad19-4b5d-96f0-87580ebd5de5');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', '{"sub": "9e3287a0-abfc-4234-8ecf-2f0a8ca5a801", "email": "steven27x01@gmail.com", "full_name": "Steven", "email_verified": true, "phone_verified": false}', 'email', '2025-10-23 09:28:43.360057+00', '2025-10-23 09:28:43.360112+00', '2025-10-23 09:28:43.360112+00', 'd58e0d84-d5cc-4b9d-9ff4-0a752921b48e');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('0d7819d0-3444-4968-8793-f7a11d7d3ea4', '0d7819d0-3444-4968-8793-f7a11d7d3ea4', '{"sub": "0d7819d0-3444-4968-8793-f7a11d7d3ea4", "email": "jhuniorcruzcruz@gmail.com", "full_name": "Mylo", "email_verified": false, "phone_verified": false}', 'email', '2025-10-26 07:12:36.013883+00', '2025-10-26 07:12:36.01394+00', '2025-10-26 07:12:36.01394+00', 'ccaab638-a334-4051-829f-6e3675ba256f');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('7188adff-27f9-41a3-a484-e3170491f2b4', '7188adff-27f9-41a3-a484-e3170491f2b4', '{"sub": "7188adff-27f9-41a3-a484-e3170491f2b4", "email": "jr27efootball@gmail.com", "full_name": "Anakin", "email_verified": false, "phone_verified": false}', 'email', '2025-10-26 08:31:29.207713+00', '2025-10-26 08:31:29.207767+00', '2025-10-26 08:31:29.207767+00', '70c908dd-b3bc-4fc9-976a-1f9b479d3cba');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('5134f328-1aa9-41f1-aa85-27baab3ffb03', '5134f328-1aa9-41f1-aa85-27baab3ffb03', '{"sub": "5134f328-1aa9-41f1-aa85-27baab3ffb03", "email": "les17mari@gmail.com", "full_name": "Mariluz", "email_verified": false, "phone_verified": false}', 'email', '2025-10-26 16:51:23.480335+00', '2025-10-26 16:51:23.480383+00', '2025-10-26 16:51:23.480383+00', '6d0570e1-965e-47ed-8cd9-afaea762e121');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('7c5383bc-f4b5-4ced-bc6e-14624442eed4', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', '{"sub": "7c5383bc-f4b5-4ced-bc6e-14624442eed4", "email": "ceilita1580@gmail.com", "full_name": "Ceila", "email_verified": false, "phone_verified": false}', 'email', '2025-10-27 20:25:46.736186+00', '2025-10-27 20:25:46.736237+00', '2025-10-27 20:25:46.736237+00', '69e7f3c3-4e80-46b1-9181-5d378182aec3');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('7ac519cb-b5fe-460f-9909-255634767327', '7ac519cb-b5fe-460f-9909-255634767327', '{"sub": "7ac519cb-b5fe-460f-9909-255634767327", "email": "jc392355@gmail.com", "full_name": "José Alvarado Cruz", "email_verified": false, "phone_verified": false}', 'email', '2025-10-30 16:05:03.219979+00', '2025-10-30 16:05:03.220645+00', '2025-10-30 16:05:03.220645+00', '53c52ffa-690f-4101-bd83-7276578c3f7e');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('adba3600-c94a-46ad-8a66-03fa6e32e79e', 'adba3600-c94a-46ad-8a66-03fa6e32e79e', '{"sub": "adba3600-c94a-46ad-8a66-03fa6e32e79e", "email": "cruz27@gmail.com", "full_name": "Cruz", "email_verified": false, "phone_verified": false}', 'email', '2025-11-01 08:20:21.848609+00', '2025-11-01 08:20:21.850278+00', '2025-11-01 08:20:21.850278+00', '45195a0a-c8b1-4203-a22c-df9b8a85af4c');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('aa3ac35a-e193-454d-bf07-3b89386c0c32', 'aa3ac35a-e193-454d-bf07-3b89386c0c32', '{"sub": "aa3ac35a-e193-454d-bf07-3b89386c0c32", "email": "hernan.cruz980@gmail.com", "full_name": "Hernan", "email_verified": false, "phone_verified": false}', 'email', '2025-11-01 17:47:27.507586+00', '2025-11-01 17:47:27.507634+00', '2025-11-01 17:47:27.507634+00', '614d7a08-8155-4703-86cf-1c9bebcb70cb');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('63446142-dc7c-4d0e-a6c9-492b98b62121', '63446142-dc7c-4d0e-a6c9-492b98b62121', '{"sub": "63446142-dc7c-4d0e-a6c9-492b98b62121", "email": "blasesther36@gmail.com", "full_name": "Esther Elizabeth Blas Gutierrez", "email_verified": false, "phone_verified": false}', 'email', '2025-11-02 03:39:17.900527+00', '2025-11-02 03:39:17.901155+00', '2025-11-02 03:39:17.901155+00', '0b023250-97b5-4b7b-9d77-b8443b6272d3');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('55b7c1c0-fdb8-4cdf-9938-761ddb309d2f', '55b7c1c0-fdb8-4cdf-9938-761ddb309d2f', '{"sub": "55b7c1c0-fdb8-4cdf-9938-761ddb309d2f", "email": "maricarmenbeatrizhilariocruz@gmail.com", "full_name": "maricarmen", "email_verified": false, "phone_verified": false}', 'email', '2025-11-02 03:43:11.141021+00', '2025-11-02 03:43:11.141069+00', '2025-11-02 03:43:11.141069+00', '1a79c697-5cf9-4376-ae3d-7f9b93ad2d4c');
INSERT INTO public.profiles (id, income_type, savings_target, debt_to_income_threshold, utilization_threshold, reminders, created_at) VALUES ('9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'mensual', '44.850548808595235', '45', '45', 't', '2025-10-23 11:35:21.309434+00');
INSERT INTO public.profiles (id, income_type, savings_target, debt_to_income_threshold, utilization_threshold, reminders, created_at) VALUES ('0d7819d0-3444-4968-8793-f7a11d7d3ea4', 'mensual', '15', '14.6167063973682', '50.07811385566553', 't', '2025-10-26 07:12:35.991356+00');
INSERT INTO public.profiles (id, income_type, savings_target, debt_to_income_threshold, utilization_threshold, reminders, created_at) VALUES ('7188adff-27f9-41a3-a484-e3170491f2b4', 'mensual', '10', '40', '50', 'f', '2025-10-26 08:31:29.19066+00');
INSERT INTO public.profiles (id, income_type, savings_target, debt_to_income_threshold, utilization_threshold, reminders, created_at) VALUES ('5134f328-1aa9-41f1-aa85-27baab3ffb03', 'mensual', '10', '40', '50', 'f', '2025-10-26 16:51:23.461165+00');
INSERT INTO public.profiles (id, income_type, savings_target, debt_to_income_threshold, utilization_threshold, reminders, created_at) VALUES ('7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'mensual', '10', '40', '50', 'f', '2025-10-27 20:25:46.648206+00');
INSERT INTO public.profiles (id, income_type, savings_target, debt_to_income_threshold, utilization_threshold, reminders, created_at) VALUES ('7ac519cb-b5fe-460f-9909-255634767327', 'mensual', '10', '40', '50', 'f', '2025-10-30 16:05:03.133474+00');
INSERT INTO public.profiles (id, income_type, savings_target, debt_to_income_threshold, utilization_threshold, reminders, created_at) VALUES ('adba3600-c94a-46ad-8a66-03fa6e32e79e', 'mensual', '10', '40', '50', 'f', '2025-11-01 08:20:21.778846+00');
INSERT INTO public.profiles (id, income_type, savings_target, debt_to_income_threshold, utilization_threshold, reminders, created_at) VALUES ('aa3ac35a-e193-454d-bf07-3b89386c0c32', 'mensual', '10', '40', '50', 'f', '2025-11-01 17:47:27.41812+00');
INSERT INTO public.profiles (id, income_type, savings_target, debt_to_income_threshold, utilization_threshold, reminders, created_at) VALUES ('63446142-dc7c-4d0e-a6c9-492b98b62121', 'mensual', '10', '40', '50', 'f', '2025-11-02 03:39:17.814095+00');
INSERT INTO public.profiles (id, income_type, savings_target, debt_to_income_threshold, utilization_threshold, reminders, created_at) VALUES ('55b7c1c0-fdb8-4cdf-9938-761ddb309d2f', 'mensual', '10', '40', '50', 'f', '2025-11-02 03:43:11.129344+00');
INSERT INTO public.profiles (id, income_type, savings_target, debt_to_income_threshold, utilization_threshold, reminders, created_at) VALUES ('75d12d56-fc94-42da-9da1-c5c8459d8f29', 'mensual', '40.9720308196503', '35', '34.5189983060406', 't', '2025-10-23 11:35:21.309434+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('ab1ad248-031c-4b4b-bd77-ff8247da6db9', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'BBVA', '1000', '10000', NULL, '2025-10-24', 't', '2025-10-23 20:12:14.104278+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('42554112-b27d-4746-b9c5-219577ab580e', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'CAJA TRUJILLO', '200', '800', NULL, '2025-10-25', 't', '2025-10-24 07:24:31.693028+00', '2025-10-24 07:24:48.629837+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('7efb5b9b-13c8-4d6a-8de6-706eed62ad00', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'BBVA', '1000', '1000', '1500', '2025-10-25', 't', '2025-10-24 07:25:34.252889+00', '2025-10-24 07:26:02.423979+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('65e77534-e8bd-40c2-a6e3-f7e0138bf305', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'Prestamo personal', '200', '400', NULL, '2025-10-25', 't', '2025-10-24 08:04:09.46086+00', '2025-10-24 08:04:17.75344+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('9189e56b-3632-4038-95a4-e6857ed045f1', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'BCP', '300', '300', '700', '2025-10-25', 't', '2025-10-24 08:23:37.033703+00', '2025-10-24 08:23:56.063564+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('e694b1cd-9be6-44c2-a64e-15fc557c35da', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'MASTERCARD', '300', '300', '500', '2025-10-24', 't', '2025-10-23 21:22:02.249431+00', '2025-10-25 03:05:59.530231+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('c4ca17ba-c6bb-4eea-8401-89fef47b2b49', '0d7819d0-3444-4968-8793-f7a11d7d3ea4', 'BBVA', '400', '400', '700', '2025-10-27', 'f', '2025-10-26 08:01:58.576155+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('025a6fb3-bfcc-4032-84e1-b361f88be97f', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'Hipoteca', '1830', '100000', NULL, '2025-11-23', 'f', '2025-10-27 20:29:38.533796+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('16cb37cc-3f29-40d9-a3bb-5200488c6f4e', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'Hipoteca', '1830', '100000', NULL, '2025-11-23', 't', '2025-10-27 20:29:38.062847+00', '2025-10-27 15:30:19.940625+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('89c4584d-2d2f-4f3f-a5f4-e15bc82a3761', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'prestamo colombianos', '150', '300', NULL, '2025-10-26', 't', '2025-10-26 03:01:20.449268+00', '2025-10-30 05:35:35.976531+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('af993a2b-6f1e-4c99-bf56-dc56668b7eef', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'BBVA', '400', '400', '800', '2025-11-23', 't', '2025-10-23 21:20:53.803591+00', '2025-11-01 02:42:43.673855+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('ccedefb6-1e92-4d7e-a1cf-139733d4e633', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'BCP', '200', '800', NULL, '2025-10-24', 't', '2025-10-23 20:01:25.329053+00', '2025-11-01 02:56:05.06083+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('2971ed29-8ecd-431a-af65-717629014897', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-11-02', 'f', '2025-11-01 08:04:17.129291+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('82b7349c-8526-421c-937b-dc0df8164d4b', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-11-02', 'f', '2025-11-01 08:04:18.420225+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('1a1218f3-aa50-4c82-a3e6-5e13207f0895', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-11-02', 'f', '2025-11-01 08:04:19.094103+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('1fcdc59b-f8a6-4217-a23c-f91ad42ca8c3', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-11-02', 'f', '2025-11-01 08:04:19.310103+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('7ab00243-d92e-4ad8-b79e-16ba27ce02a7', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-11-02', 'f', '2025-11-01 08:04:19.462173+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('b90164ac-0c57-4663-9586-35b11ff26c95', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-11-02', 'f', '2025-11-01 08:04:19.641658+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('da858cfd-4a08-4f85-97b7-0e6be13a6742', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-12-01', 'f', '2025-11-01 08:04:25.217841+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('3d9f7394-466f-41c6-bdfb-5dc03c85cbbc', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-12-01', 'f', '2025-11-01 08:04:25.71972+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('7a4b187b-e8b2-4c2c-81f3-e99a8ab4c23b', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-12-01', 'f', '2025-11-01 08:04:25.919215+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('0fcc6d98-8c78-44d8-8440-3d7a29da39b9', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-12-01', 'f', '2025-11-01 08:04:26.107536+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('54336a5d-17e2-45ab-a25f-b551ede28bfc', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-12-01', 'f', '2025-11-01 08:04:26.277679+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('f62f2d8f-7a5c-4728-9f8f-0404c8f91ff4', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-12-01', 't', '2025-11-01 08:04:39.136859+00', '2025-11-01 03:15:58.545813+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('d7a2dabb-4520-4922-b001-1bd723ef2d66', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-12-01', 't', '2025-11-01 08:04:26.86977+00', '2025-11-01 03:16:20.423131+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('8e3a8288-4d5d-469f-b836-2d76edca48be', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-12-01', 't', '2025-11-01 08:04:26.679668+00', '2025-11-01 03:16:31.986639+00');
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('2d9cf338-7136-43be-ade8-c468c9c28016', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'CAJA TRUJILLO', '135', '1000', NULL, '2025-11-02', 'f', '2025-11-01 08:17:24.639736+00', NULL);
INSERT INTO public.debts (id, user_id, name, amount, total_debt, credit_limit, due_date, paid, created_at, paid_at) VALUES ('8ec30a6a-06e5-4278-b9fa-7cd02679a8e5', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'bbva', '300', '300', '800', '2025-12-01', 't', '2025-11-01 08:04:26.478983+00', '2025-11-03 18:50:28.152887+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('99188088-626d-4b89-8b02-70b59104dfc6', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'income', '1500', '2025-10-23 14:21:01.1634+00', 'recibo', NULL, '2025-10-23 14:20:59.71074+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('fd0f1539-90b6-44f0-a544-965f6387c2ab', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '100', '2025-10-23 20:00:03.250804+00', 'comida', 'Comida', '2025-10-23 20:00:18.114679+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('e59efca5-60c6-4307-ada5-cf4038180557', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'income', '2000', '2025-10-23 20:00:39.503179+00', 'recibo', NULL, '2025-10-23 20:00:38.590538+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('33565d54-b067-485f-9099-7ba74759889b', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '500', '2025-10-23 20:03:22.257198+00', 'educacion', 'Universidad', '2025-10-23 20:03:30.438107+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('9512990a-338e-4099-88fc-a61106ddba91', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '400', '2025-10-23 20:04:23.957829+00', 'salud', 'Emergencia', '2025-10-23 20:04:34.885792+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('0e501896-9af4-4f41-bd70-5ad7e1809e72', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'income', '4100', '2025-10-23 20:10:42.147136+00', 'planilla', NULL, '2025-10-23 20:10:41.637499+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('12795c3c-0756-4814-9f1f-3ca73a2cacc7', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'expense', '700', '2025-10-23 20:10:47.358384+00', 'educacion', 'Universidad Hijo', '2025-10-23 20:11:01.795752+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('2ca8bd10-db57-40a4-92bb-73bb1de5e6ec', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'expense', '300', '2025-10-23 20:11:10.475477+00', 'vivienda', 'Aquiler cuarto', '2025-10-23 20:11:23.842818+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('fd30dcd4-655c-4c50-b76d-3ec9399190f8', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '1000', '2025-10-23 21:10:05.946756+00', 'educacion', 'Upn', '2025-10-24 02:10:18.070374+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('e80e94ff-4745-4f33-b973-a4bf25bff934', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'expense', '200', '2025-10-24 07:24:48.309131+00', 'debt', 'Pago deuda CAJA TRUJILLO', '2025-10-24 07:24:49.633897+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('0085dc1f-e043-41d4-90b1-f948c731a9e3', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'expense', '1000', '2025-10-24 07:26:02.131412+00', 'debt', 'Pago deuda BBVA', '2025-10-24 07:26:03.407527+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('c65f3fcf-491f-42ac-908b-6287e181758a', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'expense', '200', '2025-10-24 08:04:17.577409+00', 'debt', 'Pago deuda Prestamo personal', '2025-10-24 08:04:18.80174+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('cbd1db7a-e2cb-4cf2-ba88-d21856389e03', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'expense', '300', '2025-10-24 08:23:55.710346+00', 'debt', 'Pago deuda BCP', '2025-10-24 08:23:57.116974+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('26580b08-1ab6-4753-9717-bda5b4e48426', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'expense', '50', '2025-10-24 08:28:16.905107+00', 'comida', 'comida', '2025-10-24 08:28:31.212133+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('de685388-041f-4500-abef-fd58ffa29638', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'expense', '500', '2025-10-24 08:28:36.421158+00', 'salud', 'Emergencia', '2025-10-24 08:28:47.231144+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('f966a5b4-a1da-40b4-8660-e11f7e0707dc', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'expense', '100', '2025-10-24 08:28:52.288352+00', 'transporte', 'Pasajes', '2025-10-24 08:29:04.061964+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('cef7e153-d7cf-4915-84d8-c6f8334c7ed1', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'expense', '200', '2025-10-24 08:29:06.136755+00', 'otros', 'Salida', '2025-10-24 08:29:18.771494+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('e0d58a71-e1a7-4916-81e3-8f27ba1891d4', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'income', '3800', '2025-10-24 18:28:03.794892+00', 'recibo', NULL, '2025-10-24 23:28:04.471441+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('639c91bf-0bec-41c8-9109-3ac677a052eb', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '300', '2025-10-25 03:05:59.089737+00', 'debt', 'Pago deuda MASTERCARD', '2025-10-25 08:05:59.557622+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('d6be8950-cf59-4c6e-bea0-ba3967216787', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '1500', '2025-10-25 07:55:13.840084+00', 'vivienda', 'Pago casa', '2025-10-25 12:55:34.104684+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('8b6c4d3d-10b2-41e0-8d61-ffe57a51cc4b', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '2000', '2025-10-25 07:56:01.446155+00', 'otros', 'Paseo', '2025-10-25 12:56:15.837956+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('d5a8111c-a622-4bdb-956f-670e0ea823e4', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '500', '2025-10-25 08:17:10.898171+00', 'comida', NULL, '2025-10-25 13:17:21.438543+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('e9feac1e-c9bb-4ab6-8d4a-b31ed15cbe09', '0d7819d0-3444-4968-8793-f7a11d7d3ea4', 'income', '3050', '2025-10-26 02:14:44.018046+00', 'planilla', NULL, '2025-10-26 07:14:44.583648+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('e1524233-8e3a-46bc-a4ec-71c4473ac4a3', '0d7819d0-3444-4968-8793-f7a11d7d3ea4', 'expense', '500', '2025-10-26 03:01:06.323766+00', 'educacion', 'UCV', '2025-10-26 08:01:15.988061+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('07d2786e-5c13-41fa-a633-5b3c3df73e63', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'income', '3663', '2025-10-27 15:26:49.396189+00', 'planilla', NULL, '2025-10-27 20:26:49.774261+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('b067ad38-a4e9-4f74-b6d6-78f1bec013ce', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'expense', '430', '2025-10-27 15:27:14.523253+00', 'vivienda', 'Cuarto hija', '2025-10-27 20:27:39.594156+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('cba25951-da85-4467-8c33-7c3b8bcf9cda', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'expense', '800', '2025-10-27 15:27:50.710213+00', 'educacion', 'Universidad hijo', '2025-10-27 20:28:08.833656+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('fa34b892-20a4-47c3-817f-38ab2862c54c', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'expense', '1830', '2025-10-27 15:30:19.570125+00', 'debt', 'Pago deuda Hipoteca', '2025-10-27 20:30:19.959937+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('ff5569b2-1869-4f60-9a7d-a0126ab616dc', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'expense', '450', '2025-10-27 15:30:36.813613+00', 'otros', 'Diezmo ', '2025-10-27 20:30:55.856725+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('022976fd-6bdd-4669-a567-824bcee58f02', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '150', '2025-10-30 05:35:35.700583+00', 'debt', 'Pago deuda prestamo colombianos', '2025-10-30 10:35:36.308735+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('142def58-e68c-4f07-91f3-dfbf15639e3b', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '400', '2025-11-01 02:42:43.34811+00', 'debt', 'Pago deuda BBVA', '2025-11-01 07:42:43.744006+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('14927ac0-26b7-4c50-9aef-8dcac061ccac', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '200', '2025-11-01 02:56:04.114203+00', 'debt', 'Pago deuda BCP', '2025-11-01 07:56:05.115857+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('658a1cd5-dbfb-4a1b-bdeb-8f05bcc60388', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '300', '2025-11-01 03:15:58.055859+00', 'debt', 'Pago deuda bbva', '2025-11-01 08:15:58.671747+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('93dd2b44-b6f9-4f1d-9334-9bdc09e1669d', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'income', '4500', '2025-11-01 03:16:11.237821+00', 'planilla', NULL, '2025-11-01 08:16:11.595456+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('29c3b28b-aecc-4740-8891-99a06e485ca8', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '300', '2025-11-01 03:16:20.247988+00', 'debt', 'Pago deuda bbva', '2025-11-01 08:16:20.604752+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('4079ac25-0419-47cf-a608-285a71eee16c', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '300', '2025-11-01 03:16:31.776257+00', 'debt', 'Pago deuda bbva', '2025-11-01 08:16:32.166473+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('0160592f-33c0-490f-b142-dc887a4b2bbf', '0d7819d0-3444-4968-8793-f7a11d7d3ea4', 'income', '1150', '2025-11-01 03:18:45.599516+00', 'recibo', NULL, '2025-11-01 08:18:45.949883+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('153f2134-c459-4954-8b18-d0a6ce5c4bf6', '0d7819d0-3444-4968-8793-f7a11d7d3ea4', 'expense', '115', '2025-11-01 03:18:50.385177+00', 'otros', 'Diezmo', '2025-11-01 08:19:05.345299+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('35beb8aa-ee37-4f2e-add7-120b176bb410', '63446142-dc7c-4d0e-a6c9-492b98b62121', 'income', '1260', '2025-11-01 22:40:03.386976+00', 'recibo', NULL, '2025-11-02 03:40:03.536144+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('ec29d475-fcee-46b1-aa4d-844c744fda4f', '63446142-dc7c-4d0e-a6c9-492b98b62121', 'expense', '550', '2025-11-01 22:40:10.111145+00', 'vivienda', NULL, '2025-11-02 03:40:22.959346+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('24116849-a583-4c9a-86a9-d76dbdb9c8e3', '63446142-dc7c-4d0e-a6c9-492b98b62121', 'expense', '144', '2025-11-01 22:41:02.193254+00', 'comida', NULL, '2025-11-02 03:41:12.57214+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('240250e4-e3bf-4236-ba36-37ba29fd9dc9', '63446142-dc7c-4d0e-a6c9-492b98b62121', 'expense', '126', '2025-11-01 22:42:38.924773+00', 'otros', 'Diezmo', '2025-11-02 03:42:53.142983+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('71489cdc-baa0-4650-8a47-642eec1dce79', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'expense', '700', '2025-11-03 13:17:05.537095+00', 'comida', NULL, '2025-11-03 18:17:37.505148+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('3c072df7-4c93-408d-9eb0-61036e390f66', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'expense', '400', '2025-11-03 13:17:48.126742+00', 'transporte', NULL, '2025-11-03 18:17:57.852645+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('6cc61341-d734-4aeb-9ca6-9e6891063599', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'expense', '1800', '2025-11-03 13:18:06.275559+00', 'vivienda', NULL, '2025-11-03 18:18:18.278083+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('9efc5665-0139-408e-8557-a9cc835cb285', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'expense', '200', '2025-11-03 13:18:24.303907+00', 'salud', NULL, '2025-11-03 18:18:37.356032+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('1e8f7be4-4840-4b15-9cd9-18480442604f', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'income', '5000', '2025-11-03 13:19:14.697813+00', 'recibo', NULL, '2025-11-03 18:19:14.40125+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('791fb44d-8f1d-44a2-b6b2-a3b4679f50fb', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'expense', '850', '2025-11-03 13:19:29.572128+00', 'educacion', NULL, '2025-11-03 18:19:45.319854+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('b0d50233-4e08-4631-ad10-a495169f7825', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'expense', '300', '2025-11-03 13:20:17.29715+00', 'otros', NULL, '2025-11-03 18:20:33.344088+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('c160b2a5-535d-49aa-abad-093ef2fa9bd2', '63446142-dc7c-4d0e-a6c9-492b98b62121', 'expense', '10', '2025-11-03 17:58:39.797291+00', 'otros', 'ahorro', '2025-11-03 22:58:49.095693+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('791092f2-507f-4ba8-b69e-a9d268339a29', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'expense', '300', '2025-11-03 18:50:27.291069+00', 'debt', 'Pago deuda bbva', '2025-11-03 23:50:27.760167+00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('b7cde804-4272-4400-971b-80d3a3e0bd2d', '5134f328-1aa9-41f1-aa85-27baab3ffb03', 'income', '20', '2025-11-07 11:38:56.909723+00', 'recibo', NULL, '2025-11-07 16:28:32.266229+00');
