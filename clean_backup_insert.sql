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


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

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


ALTER TABLE public.debts OWNER TO postgres;

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


ALTER TABLE public.profiles OWNER TO postgres;

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


ALTER TABLE public.transactions OWNER TO postgres;

--
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '759a100a-2152-4bb8-b18b-d4d135b439fe', '{"action":"user_confirmation_requested","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-10-22 10:45:44.904195+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '2c1402f4-5106-4760-951b-50af78f0b506', '{"action":"user_signedup","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-10-22 10:46:06.77124+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '19b03643-c60a-4d69-8bb6-512443ab859f', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-22 10:51:53.11695+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '37ccfbac-3e87-443c-8b37-15a5948bfa0d', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 09:20:21.261575+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '495d3f0f-746c-4502-9ede-8845f810caa7', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 09:20:21.278992+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '38577018-458c-4819-8b00-af7aed8076f8', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-23 09:20:37.486673+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'a326ac00-ed52-4583-b998-db4035bc59ba', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 09:21:04.306902+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '6574c6a5-326b-4f7a-90aa-9a5b60230f8a', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-23 09:21:59.648266+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'f5b13129-0c83-479f-8f18-0c85168c3369', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 09:22:35.048979+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'e7b1cc3a-75b1-4b2e-83d8-cc693d2efbf3', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-23 09:23:35.817942+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '806628ba-3e37-4afc-b747-3dd9b4babdc4', '{"action":"user_confirmation_requested","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-10-23 09:28:43.36761+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '6d7077f1-db32-4dba-9ba1-eea3fe99bff6', '{"action":"user_signedup","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-10-23 09:29:12.358492+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'efb87073-424f-4fd7-91ca-94b7c0baddd1', '{"action":"login","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 09:29:31.619062+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '4dfb9370-1637-447e-9600-ed806c575d31', '{"action":"token_refreshed","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 10:48:43.414924+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '1c68dbe1-7f38-4813-bde0-e0a9e42b83ec', '{"action":"token_revoked","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 10:48:43.422842+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'd77d8c1b-74ac-4e8f-9b5a-b73b09eaed27', '{"action":"logout","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-23 10:49:17.548526+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '88e2a040-8863-4957-bffe-d2f72452f44a', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 10:49:30.742057+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '494e2100-0a76-497d-ba48-46165dc48dcf', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-23 10:49:37.616571+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '12fde2a7-0345-4195-8716-50544fea8a2a', '{"action":"login","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 10:49:50.257601+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '26bb8951-91a3-4f2e-9436-6b8737450308', '{"action":"token_refreshed","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 11:49:12.678084+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '5344cfac-32ff-497a-b999-46674972383d', '{"action":"token_revoked","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 11:49:12.68771+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'ae525098-276c-4a03-b706-a45662eb17a3', '{"action":"logout","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-23 11:49:31.665795+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '5604b8f2-4655-4a02-8221-2337fca02361', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 11:49:56.097281+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '48022a34-ebb4-498f-8d2f-9baa320af465', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-23 11:50:26.316936+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '9dbb4cc1-3a2e-4b8a-a209-d743ea27be84', '{"action":"login","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 11:50:37.945152+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'a8691034-3710-40be-9e14-2623a9911b44', '{"action":"logout","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-23 11:51:41.660242+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '93e38ede-f7db-4848-a7e8-460a88f4e0ac', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 11:52:03.133926+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'bbc3766a-91da-41a2-bb46-fc5bd2a5a4f2', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 13:56:28.392031+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'ca0a4145-8dd7-4e8b-9093-e21eee55fed9', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 13:56:28.418007+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '5fa0d7e9-47d5-4661-94e5-afc73c9cdb62', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 13:56:49.83978+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '7b02d21a-a4b0-4151-8dfc-2cca817c5714', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-23 14:20:28.287705+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'd4087548-477d-4b77-830c-b5598ac8fb57', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 14:20:53.557771+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'b10485fa-6345-4f62-a518-e1e270d6aa64', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 19:59:31.444766+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '0f26cd48-349c-4b29-928f-f7a0b0420abe', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 19:59:31.454028+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'ad061dc3-ca43-424c-9b78-6ff4351f835f', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 19:59:59.145951+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '6698e569-c04e-472a-bb91-f5e7047a810c', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-23 20:08:29.504513+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'b5feb050-794d-4d2e-9291-adb3048c4bcc', '{"action":"login","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 20:08:48.436889+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '6c76cf8d-18a2-4ab3-be18-4a398010a117', '{"action":"login","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 20:34:02.016346+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'b8e02ad0-d113-459a-aabf-8a03d8755a51', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-23 21:19:49.285712+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '3ce25a8a-5e9e-4ecb-a6b9-bec7b685e4bd', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 22:52:56.270082+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '776ed41a-27dd-4ad7-a0a6-e5a597ba2c5e', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-23 22:52:56.292883+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '3dca5b0c-cbd5-4e13-afb2-b7c52755e417', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 02:07:51.333858+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '4012dd63-d01e-4068-8300-ec95281c420a', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 02:07:51.358804+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '9452423a-18fe-4911-a9ae-a6befd4c0348', '{"action":"login","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-24 06:01:13.243234+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '8a7cf408-5507-48a5-9f27-0e8cfecc6aee', '{"action":"login","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-24 07:23:42.967651+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '94965b95-682c-44f8-8648-d0e3e024120c', '{"action":"token_refreshed","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 08:23:10.895+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'aa96f262-6253-4b29-9ef7-47be02d741af', '{"action":"token_revoked","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 08:23:10.911327+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'c563acbe-f9eb-44c7-8dc5-b9e555037716', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 09:21:43.120939+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '2f812ac0-7a74-42d5-9370-dc4f454c9fbd', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 09:21:43.131938+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '14bea233-dd39-492b-8c91-d9584f46f3e9', '{"action":"token_refreshed","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 09:22:36.892133+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'c6815481-7058-491b-926d-b9ec905a4958', '{"action":"token_revoked","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 09:22:36.892762+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'a7395637-a460-44c8-ab28-08f1c827a8ab', '{"action":"token_refreshed","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 10:31:51.328547+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '36150c34-a722-4fd3-a295-f0d8fa8703b3', '{"action":"token_revoked","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 10:31:51.349966+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '633b04ce-e724-4ce7-9b88-fb2064eddfe0', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 12:43:11.938853+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '7a1ac240-7222-43a5-bb94-ce8f32aa58bd', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 12:43:11.961842+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'e5550cf0-7455-498b-8ad8-f3ec7e288c4c', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 21:27:08.617515+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '27a4b5f5-0152-4777-9203-baecc536b3b8', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 21:27:08.631708+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '22d591f7-43be-408a-8032-49517bf9d0e9', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 22:45:07.057076+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '4d04cc36-5302-4581-a049-9dcbd3732da8', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-24 22:45:07.068171+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '903407b3-f2e3-45a2-baa1-532546bae19f', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-25 08:05:21.844936+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '11f70cb6-4ce7-48e5-81e7-4597127dd8c8', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-25 08:05:21.87158+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '85245013-3d80-4bd6-8b5c-f5548a8488e6', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-25 09:04:49.362944+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'fddf2527-93aa-4331-abfe-d0b8be8740aa', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-25 09:04:49.373993+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '0be42aa6-b988-4f0a-999c-10246ec531ef', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-25 09:04:51.776702+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '09e035af-f61e-49ee-8c7f-ce05d14e852b', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-25 09:14:07.323459+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '3670b8ee-1854-48f6-a06b-94858c1e0efc', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-25 09:21:15.507222+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'c58e6e0f-5985-4a8c-aa5c-82faa3d2ab74', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-25 12:33:02.175826+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '87ac4998-a6be-4341-98a9-f999cfcb163b', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-25 12:54:36.062698+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'e95f36ef-837e-473b-819c-ff3de64b3114', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-25 12:54:51.192116+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '5028ab4b-89b7-4793-8cda-87339bd40ea2', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-25 23:30:05.564724+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '37d8123f-f49d-44b6-ae94-2978879569e0', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-25 23:30:05.577784+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'adef3064-0bb3-428a-8ad2-62552ceb5274', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 00:51:58.241711+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '8254eff0-acaf-4ee8-8a77-46c270198aaf', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 00:51:58.257832+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '43fa3210-7eee-4abe-a1e3-788db9f6e6f2', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 01:42:48.236913+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '685fa6cb-7895-431d-bf65-bdbe4169251e', '{"action":"user_recovery_requested","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"user"}', '2025-10-26 01:42:59.479079+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '8117bc13-d7e5-4700-be25-4ad2945b5e02', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 01:43:12.192049+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'e6d58da1-d58a-4576-b2f4-4d36bd7b69ba', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider_type":"recovery"}}', '2025-10-26 01:43:12.980113+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '2748fa2a-b815-4806-99d1-35e632be570e', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 01:43:49.428973+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '32bca0cf-0ceb-44f3-8a91-cf07b7924590', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 03:00:39.530913+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '67b87a64-fd46-4eff-8443-0033808c4e70', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 03:00:39.547785+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '8a48430d-1a52-40ae-8fab-9f35a9559ab7', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 03:21:22.547373+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'd135f55c-456f-4235-809f-dee5b4e4aa48', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 03:27:26.396931+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'dc4225b6-c8e7-41aa-99a0-b56ea51916cc', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 05:49:40.905834+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '41ad2368-23fb-40f8-b8b2-4bac6dc91d3d', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 05:49:40.932372+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'fc8cf7bc-2af6-4c94-ac0a-513d9b4ad8b6', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 05:56:04.786391+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'f5c1d1a7-fcb7-45eb-a534-21072201b420', '{"action":"login","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 06:27:12.853282+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '29e95d13-312c-4350-8348-01982720dc88', '{"action":"logout","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 06:27:59.724037+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'e97e88a2-1fd5-40e2-923b-a43f7aa94300', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 06:28:12.715091+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '26d2bc46-b616-4a58-8019-6ca2d1047c97', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 06:38:54.089429+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '972d0678-14ca-4216-bfff-6a8a689f529a', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 06:48:39.599264+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'cdb568e3-b64b-4bed-a9cf-6943d075d8c1', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 06:49:25.114037+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'a071ccc8-1ac2-4689-a1ca-f5505ae426ff', '{"action":"login","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 06:49:42.478316+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'ecfb6827-a04f-498f-b56e-b819761a9c59', '{"action":"logout","actor_id":"9e3287a0-abfc-4234-8ecf-2f0a8ca5a801","actor_name":"Steven","actor_username":"steven27x01@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 07:12:03.499114+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'a8f45b77-7048-4150-9495-bb3b0e9b269e', '{"action":"user_signedup","actor_id":"0d7819d0-3444-4968-8793-f7a11d7d3ea4","actor_name":"Mylo","actor_username":"jhuniorcruzcruz@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-10-26 07:12:36.021229+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '401e81c9-f706-4662-ae17-339680b9a058', '{"action":"login","actor_id":"0d7819d0-3444-4968-8793-f7a11d7d3ea4","actor_name":"Mylo","actor_username":"jhuniorcruzcruz@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 07:12:36.031781+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '45ebee8f-302a-46ae-9c22-72192a15137e', '{"action":"login","actor_id":"0d7819d0-3444-4968-8793-f7a11d7d3ea4","actor_name":"Mylo","actor_username":"jhuniorcruzcruz@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 07:13:06.879117+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'afbd6391-a56a-47e0-a9fa-9adc3662f08e', '{"action":"logout","actor_id":"0d7819d0-3444-4968-8793-f7a11d7d3ea4","actor_name":"Mylo","actor_username":"jhuniorcruzcruz@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 07:16:29.969441+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '8af32565-62d0-49d7-bf57-9ea195209a10', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 07:16:39.082492+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'bade3684-8393-430e-b2ca-c2b3ddf071a5', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 08:00:44.064114+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '3cf77101-0cfa-4a4f-a967-ddf9f2b3fd11', '{"action":"login","actor_id":"0d7819d0-3444-4968-8793-f7a11d7d3ea4","actor_name":"Mylo","actor_username":"jhuniorcruzcruz@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 08:00:59.881688+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'ae019734-6241-40e4-a835-5a9fbf2ea79c', '{"action":"logout","actor_id":"0d7819d0-3444-4968-8793-f7a11d7d3ea4","actor_name":"Mylo","actor_username":"jhuniorcruzcruz@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 08:03:31.518734+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '2dec4ff5-0f9c-4ed6-90a7-974a6fbb23cc', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 08:03:55.671283+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'c1ba9fe5-d343-4dad-9951-202da67ff038', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 08:30:37.192079+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '0243f44a-15cc-4035-a09f-14b3da77ef99', '{"action":"user_signedup","actor_id":"7188adff-27f9-41a3-a484-e3170491f2b4","actor_name":"Anakin","actor_username":"jr27efootball@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-10-26 08:31:29.213279+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'aff7e583-7555-470a-b872-17ad61315fb0', '{"action":"login","actor_id":"7188adff-27f9-41a3-a484-e3170491f2b4","actor_name":"Anakin","actor_username":"jr27efootball@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 08:31:29.223448+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'e9f2ac56-1ed1-488a-8103-11b0d8f52914', '{"action":"login","actor_id":"7188adff-27f9-41a3-a484-e3170491f2b4","actor_name":"Anakin","actor_username":"jr27efootball@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 08:31:46.121951+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'c072782d-cc0b-4387-9184-5f9a78c2b374', '{"action":"logout","actor_id":"7188adff-27f9-41a3-a484-e3170491f2b4","actor_name":"Anakin","actor_username":"jr27efootball@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 08:32:00.553473+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '3f7494a2-f833-4f51-a5fd-f783964c135d', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 08:32:10.215648+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '92e83718-5a7d-4d10-b339-99d2d3ec0a4a', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 09:34:10.074638+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '8d16104c-757d-4004-b654-c5283d6b0e9a', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 09:34:10.094855+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'f2f56850-c1dc-4d75-b681-8c4b337b8a0b', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 10:36:31.116873+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'cebc8ffc-9289-40b9-8ae6-54a6cb844ade', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 10:36:31.13474+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'a8b3e32f-8508-4810-8c3e-96d61e13ffb4', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 10:36:36.110583+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'bd1d7b85-8b5a-421b-9675-cd9e556c06e0', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 10:37:12.02006+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '39b7c736-fe71-4d6b-9f7e-dca5dc751543', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 15:57:32.548849+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '753b8ac0-97ef-4e75-9e43-4622cde96900', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-26 15:57:32.569222+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '15616891-ad20-468d-b8ea-a1a276be63c1', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 16:50:03.541873+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'de00b00d-22b6-4321-b564-3e35fa305e70', '{"action":"user_signedup","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-10-26 16:51:23.487963+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '6b33cf01-1079-4ab5-848c-dcd5b2712865', '{"action":"login","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 16:51:23.495271+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '028718bd-d20c-4192-825a-6c3d0d4a0f55', '{"action":"login","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 16:51:34.811664+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '2d4b3093-ddbc-4bc0-8eb5-4367481b01df', '{"action":"logout","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 16:52:05.298605+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '3411cd55-76e3-4dbb-b1d0-04e7831ef987', '{"action":"login","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 16:57:08.879196+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '951b96cf-e6dd-4c53-aa87-2666c6f90579', '{"action":"logout","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-26 16:57:19.026783+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'bc6c84d9-c1f1-4b35-9ac4-d3d6e5924a99', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-26 19:25:04.491884+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '4f8f9e33-4175-4e5e-a623-9a870ade8a66', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-27 00:46:04.03952+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '5a6457bc-7d83-4e44-a719-17122490e337', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-27 00:46:04.047536+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '7998ddf4-d994-42e6-abd6-80cbcad4429c', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-27 00:46:13.305196+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '063ad607-8b99-4a4d-8c25-74eb0c5f715b', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-27 01:03:08.870547+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'cf7da0bc-ec50-4577-bdf1-335aa83a6b42', '{"action":"user_repeated_signup","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-10-27 03:24:11.273965+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'b3b5d351-21d4-4758-98ee-2cea5cea058d', '{"action":"login","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-27 03:25:54.757773+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '67621abf-d008-4a90-bcf0-ef162a0bec13', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-27 11:17:31.301613+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '96040005-5079-4477-bcbb-cd13cc172f7b', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-27 11:17:31.328518+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'd19c46f4-18e6-425b-bb67-9b273a1af6a8', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-27 11:17:38.830801+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'ef560a81-7e48-47a9-b9aa-8d3164c1f015', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-27 11:17:47.022205+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '2e8dd794-92fb-44b8-acce-6c5c839cc842', '{"action":"token_refreshed","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-27 16:19:19.606894+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '3cc305a2-6e56-4d74-9241-8a8db2315597', '{"action":"token_revoked","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-27 16:19:19.631312+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'ffae93af-febf-4308-beba-2fe2913c78fd', '{"action":"user_signedup","actor_id":"7c5383bc-f4b5-4ced-bc6e-14624442eed4","actor_name":"Ceila","actor_username":"ceilita1580@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-10-27 20:25:46.75719+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '55de1ad9-93e6-4757-b8d4-33862ef7de0a', '{"action":"login","actor_id":"7c5383bc-f4b5-4ced-bc6e-14624442eed4","actor_name":"Ceila","actor_username":"ceilita1580@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-27 20:25:46.784705+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '3bb7b996-a1da-4d8c-9836-2247235d4e53', '{"action":"login","actor_id":"7c5383bc-f4b5-4ced-bc6e-14624442eed4","actor_name":"Ceila","actor_username":"ceilita1580@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-27 20:25:55.323021+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'bb47db68-54ba-482b-bb0b-6e94962054e5', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-27 23:24:53.342717+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '068134a8-bcc4-4b8e-b153-8ca1195c2796', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-27 23:24:53.353217+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '860ac77f-858c-40cc-982f-9ec2aec128c4', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-29 16:28:07.984886+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '82951341-d37c-46e1-aeca-e9a86d8272f0', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-29 16:28:08.013434+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '136ecbfd-ee53-4b4c-aa63-65a0f8fc5928', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-30 10:34:17.137993+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'ead8a7cf-b4f4-4410-a57a-05bb2ba252b6', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-10-30 10:34:17.164726+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '4da97ba2-1c9f-4811-b66e-1f14d16ef412', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-30 10:34:23.653178+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '338e6cb1-a532-460c-b551-c0e615203d08', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-30 10:34:56.668388+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'be39a797-a820-4dc4-8410-adc8a800693c', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-10-30 10:39:04.979179+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '2945292b-e401-4d9c-84cd-4a7bfca10f4a', '{"action":"user_signedup","actor_id":"7ac519cb-b5fe-460f-9909-255634767327","actor_name":"José Alvarado Cruz","actor_username":"jc392355@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-10-30 16:05:03.238569+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '502ca372-bdc4-4b8c-b308-e64589159fee', '{"action":"login","actor_id":"7ac519cb-b5fe-460f-9909-255634767327","actor_name":"José Alvarado Cruz","actor_username":"jc392355@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-30 16:05:03.266313+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '76d580f5-830f-4789-ac3c-a581f16eb4c1', '{"action":"login","actor_id":"7ac519cb-b5fe-460f-9909-255634767327","actor_name":"José Alvarado Cruz","actor_username":"jc392355@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-30 16:05:13.746782+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '0badeb70-3da4-4903-ab76-9a4881faee1c', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-10-31 02:21:10.622676+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '9ee0c6c6-29b5-4274-818a-c0bc3783d737', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-01 07:42:36.046555+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '9370e56b-0461-4c42-aaff-19fa1f0183f3', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-01 07:42:36.074551+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'e4be11de-a7cf-4191-a16d-983e02a403d9', '{"action":"logout","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-11-01 08:17:58.02717+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '3e152558-50b6-4f3a-a43a-87831cdde11f', '{"action":"login","actor_id":"0d7819d0-3444-4968-8793-f7a11d7d3ea4","actor_name":"Mylo","actor_username":"jhuniorcruzcruz@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-01 08:18:32.607835+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '3e647393-04e6-45d4-9b5e-964ad9fd50a2', '{"action":"logout","actor_id":"0d7819d0-3444-4968-8793-f7a11d7d3ea4","actor_name":"Mylo","actor_username":"jhuniorcruzcruz@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-11-01 08:19:16.532748+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'e89482d0-11e7-4123-962e-2f90a2e961ce', '{"action":"user_signedup","actor_id":"adba3600-c94a-46ad-8a66-03fa6e32e79e","actor_name":"Cruz","actor_username":"cruz27@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-01 08:20:21.872561+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'c134c0be-7b25-426d-851d-99b2aea35e4a', '{"action":"login","actor_id":"adba3600-c94a-46ad-8a66-03fa6e32e79e","actor_name":"Cruz","actor_username":"cruz27@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-01 08:20:21.903505+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '54fce793-9789-443c-a0dc-29f36a149a62', '{"action":"login","actor_id":"adba3600-c94a-46ad-8a66-03fa6e32e79e","actor_name":"Cruz","actor_username":"cruz27@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-01 08:20:33.229651+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'c34b50b7-2fd3-4fb4-8bc1-93eadb0fccca', '{"action":"logout","actor_id":"adba3600-c94a-46ad-8a66-03fa6e32e79e","actor_name":"Cruz","actor_username":"cruz27@gmail.com","actor_via_sso":false,"log_type":"account"}', '2025-11-01 08:20:42.15925+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'e3a00b51-4592-487d-969d-de64b51834cc', '{"action":"user_signedup","actor_id":"aa3ac35a-e193-454d-bf07-3b89386c0c32","actor_name":"Hernan","actor_username":"hernan.cruz980@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-01 17:47:27.532851+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '95c9f3de-b212-4470-b286-d0059947587e', '{"action":"login","actor_id":"aa3ac35a-e193-454d-bf07-3b89386c0c32","actor_name":"Hernan","actor_username":"hernan.cruz980@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-01 17:47:27.571231+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'b7151056-c1d7-477a-893b-72bd4ff5eb02', '{"action":"login","actor_id":"aa3ac35a-e193-454d-bf07-3b89386c0c32","actor_name":"Hernan","actor_username":"hernan.cruz980@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-01 17:47:56.39887+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'df4b9162-4e25-49b6-9bc3-c7e103ae26c3', '{"action":"token_refreshed","actor_id":"aa3ac35a-e193-454d-bf07-3b89386c0c32","actor_name":"Hernan","actor_username":"hernan.cruz980@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-01 22:41:11.000999+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '393c5921-2bc9-438e-a6a4-f4210117c876', '{"action":"token_revoked","actor_id":"aa3ac35a-e193-454d-bf07-3b89386c0c32","actor_name":"Hernan","actor_username":"hernan.cruz980@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-01 22:41:11.022162+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'd18e2311-0ae6-4028-9b97-bf168b1aa69c', '{"action":"user_signedup","actor_id":"63446142-dc7c-4d0e-a6c9-492b98b62121","actor_name":"Esther Elizabeth Blas Gutierrez","actor_username":"blasesther36@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-02 03:39:17.927258+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '4fecdd83-d9b4-462f-a30f-6b2e446b9975', '{"action":"login","actor_id":"63446142-dc7c-4d0e-a6c9-492b98b62121","actor_name":"Esther Elizabeth Blas Gutierrez","actor_username":"blasesther36@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-02 03:39:17.960834+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'a7dcb171-09bf-46e1-8ab8-734e2cc9245d', '{"action":"login","actor_id":"63446142-dc7c-4d0e-a6c9-492b98b62121","actor_name":"Esther Elizabeth Blas Gutierrez","actor_username":"blasesther36@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-02 03:39:36.603587+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '0aa2fa5d-ab2b-4b23-b0db-88a07766304d', '{"action":"user_signedup","actor_id":"55b7c1c0-fdb8-4cdf-9938-761ddb309d2f","actor_name":"maricarmen","actor_username":"maricarmenbeatrizhilariocruz@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-11-02 03:43:11.151102+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '615706dd-5214-4e8d-b517-0837e2e3a10e', '{"action":"login","actor_id":"55b7c1c0-fdb8-4cdf-9938-761ddb309d2f","actor_name":"maricarmen","actor_username":"maricarmenbeatrizhilariocruz@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-02 03:43:11.158028+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '82585f77-b286-4cce-bb5e-33669b0935be', '{"action":"token_refreshed","actor_id":"63446142-dc7c-4d0e-a6c9-492b98b62121","actor_name":"Esther Elizabeth Blas Gutierrez","actor_username":"blasesther36@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-02 04:41:28.292223+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'ca940e35-8761-48fb-a070-8ddf400fc197', '{"action":"token_revoked","actor_id":"63446142-dc7c-4d0e-a6c9-492b98b62121","actor_name":"Esther Elizabeth Blas Gutierrez","actor_username":"blasesther36@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-02 04:41:28.318146+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '237c247f-fd98-46d0-8481-b6f14ac450b3', '{"action":"token_refreshed","actor_id":"aa3ac35a-e193-454d-bf07-3b89386c0c32","actor_name":"Hernan","actor_username":"hernan.cruz980@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-02 13:46:07.149741+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '7a5b83e1-cd44-4a90-83be-567143009dd8', '{"action":"token_revoked","actor_id":"aa3ac35a-e193-454d-bf07-3b89386c0c32","actor_name":"Hernan","actor_username":"hernan.cruz980@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-02 13:46:07.177532+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '547dc8c9-4b13-4313-91ae-0553c27c0bee', '{"action":"login","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-02 15:24:45.929537+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '0530d88d-f275-46cd-acc9-aca87b2b5129', '{"action":"login","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-11-03 00:59:35.568486+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '1448cdae-c804-4c09-8168-cd743289fb33', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-03 06:36:07.028312+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'f1fd32ee-ab2f-4d21-bd1b-668ecd0488e2', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-03 06:36:07.057946+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '48c32759-4d94-4832-8e21-cf4547aba6f2', '{"action":"token_refreshed","actor_id":"7c5383bc-f4b5-4ced-bc6e-14624442eed4","actor_name":"Ceila","actor_username":"ceilita1580@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-03 18:15:22.138492+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '6647ef3e-e3ae-4761-9817-8fbde4e92cd0', '{"action":"token_revoked","actor_id":"7c5383bc-f4b5-4ced-bc6e-14624442eed4","actor_name":"Ceila","actor_username":"ceilita1580@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-03 18:15:22.164717+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'aff8b83f-6f4b-48c3-bc1f-c69fa8419eee', '{"action":"token_refreshed","actor_id":"63446142-dc7c-4d0e-a6c9-492b98b62121","actor_name":"Esther Elizabeth Blas Gutierrez","actor_username":"blasesther36@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-03 22:58:35.034802+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'bd8ec523-da35-490f-94c1-a741fdb672cf', '{"action":"token_revoked","actor_id":"63446142-dc7c-4d0e-a6c9-492b98b62121","actor_name":"Esther Elizabeth Blas Gutierrez","actor_username":"blasesther36@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-03 22:58:35.054347+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '193f2efb-b108-4d9c-a3d2-4587fd9ce1c8', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-03 23:50:11.04415+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'e1388197-7aa2-4dc4-a646-78015251ee9c', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-03 23:50:11.063799+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '5ffd13c7-d4c4-4871-8281-42222f2e6f5e', '{"action":"token_refreshed","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-05 16:27:38.125538+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '58fd24a7-d74c-4419-a643-f2d50f9de491', '{"action":"token_revoked","actor_id":"75d12d56-fc94-42da-9da1-c5c8459d8f29","actor_username":"jr11steven@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-05 16:27:38.153293+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '904a3600-3a4b-444b-99b5-15824a18b21a', '{"action":"token_refreshed","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-07 16:28:06.62379+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '8a0ac37a-6ac7-4fd5-856c-618136830f34', '{"action":"token_revoked","actor_id":"5134f328-1aa9-41f1-aa85-27baab3ffb03","actor_name":"Mariluz","actor_username":"les17mari@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-07 16:28:06.647067+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '97fa3961-a6d2-47a0-b031-a0a3bc72441b', '{"action":"token_refreshed","actor_id":"aa3ac35a-e193-454d-bf07-3b89386c0c32","actor_name":"Hernan","actor_username":"hernan.cruz980@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-12 23:33:09.251401+00', '');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '6205f970-4d2e-4af6-b49b-15dde55c4940', '{"action":"token_revoked","actor_id":"aa3ac35a-e193-454d-bf07-3b89386c0c32","actor_name":"Hernan","actor_username":"hernan.cruz980@gmail.com","actor_via_sso":false,"log_type":"token"}', '2025-11-12 23:33:09.278648+00', '');
INSERT INTO   VALUES ('087d5b65-9eb6-4700-85eb-6cf734ac85f3', '75d12d56-fc94-42da-9da1-c5c8459d8f29', '98836849-42fa-474d-8570-6ab84954ad48', 's256', '_5RjUDnEuSg7xF4FyGPLbJnmTy_gjb-KHZHT8PiIHNs', 'email', '', '', '2025-10-22 10:45:44.908328+00', '2025-10-22 10:46:06.779056+00', 'email/signup', '2025-10-22 10:46:06.779017+00');
INSERT INTO   VALUES ('3791f71c-445c-4ae5-ac88-dc1d465c9254', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', '1e1ac467-a457-449e-bee9-758c40ac8e61', 's256', 'WYtoLqq5W_jGdade2hpy8ZXGfc3YAYMg7KjbPZ3nb98', 'email', '', '', '2025-10-23 09:28:43.368969+00', '2025-10-23 09:29:12.369407+00', 'email/signup', '2025-10-23 09:29:12.36937+00');
INSERT INTO   VALUES ('75d12d56-fc94-42da-9da1-c5c8459d8f29', '75d12d56-fc94-42da-9da1-c5c8459d8f29', '{"sub": "75d12d56-fc94-42da-9da1-c5c8459d8f29", "name": "Jhunior Cruz", "email": "jr11steven@gmail.com", "email_verified": true, "phone_verified": false}', 'email', '2025-10-22 10:45:44.893007+00', '2025-10-22 10:45:44.89306+00', '2025-10-22 10:45:44.89306+00', '623172c3-ad19-4b5d-96f0-87580ebd5de5');
INSERT INTO   VALUES ('9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', '{"sub": "9e3287a0-abfc-4234-8ecf-2f0a8ca5a801", "email": "steven27x01@gmail.com", "full_name": "Steven", "email_verified": true, "phone_verified": false}', 'email', '2025-10-23 09:28:43.360057+00', '2025-10-23 09:28:43.360112+00', '2025-10-23 09:28:43.360112+00', 'd58e0d84-d5cc-4b9d-9ff4-0a752921b48e');
INSERT INTO   VALUES ('0d7819d0-3444-4968-8793-f7a11d7d3ea4', '0d7819d0-3444-4968-8793-f7a11d7d3ea4', '{"sub": "0d7819d0-3444-4968-8793-f7a11d7d3ea4", "email": "jhuniorcruzcruz@gmail.com", "full_name": "Mylo", "email_verified": false, "phone_verified": false}', 'email', '2025-10-26 07:12:36.013883+00', '2025-10-26 07:12:36.01394+00', '2025-10-26 07:12:36.01394+00', 'ccaab638-a334-4051-829f-6e3675ba256f');
INSERT INTO   VALUES ('7188adff-27f9-41a3-a484-e3170491f2b4', '7188adff-27f9-41a3-a484-e3170491f2b4', '{"sub": "7188adff-27f9-41a3-a484-e3170491f2b4", "email": "jr27efootball@gmail.com", "full_name": "Anakin", "email_verified": false, "phone_verified": false}', 'email', '2025-10-26 08:31:29.207713+00', '2025-10-26 08:31:29.207767+00', '2025-10-26 08:31:29.207767+00', '70c908dd-b3bc-4fc9-976a-1f9b479d3cba');
INSERT INTO   VALUES ('5134f328-1aa9-41f1-aa85-27baab3ffb03', '5134f328-1aa9-41f1-aa85-27baab3ffb03', '{"sub": "5134f328-1aa9-41f1-aa85-27baab3ffb03", "email": "les17mari@gmail.com", "full_name": "Mariluz", "email_verified": false, "phone_verified": false}', 'email', '2025-10-26 16:51:23.480335+00', '2025-10-26 16:51:23.480383+00', '2025-10-26 16:51:23.480383+00', '6d0570e1-965e-47ed-8cd9-afaea762e121');
INSERT INTO   VALUES ('7c5383bc-f4b5-4ced-bc6e-14624442eed4', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', '{"sub": "7c5383bc-f4b5-4ced-bc6e-14624442eed4", "email": "ceilita1580@gmail.com", "full_name": "Ceila", "email_verified": false, "phone_verified": false}', 'email', '2025-10-27 20:25:46.736186+00', '2025-10-27 20:25:46.736237+00', '2025-10-27 20:25:46.736237+00', '69e7f3c3-4e80-46b1-9181-5d378182aec3');
INSERT INTO   VALUES ('7ac519cb-b5fe-460f-9909-255634767327', '7ac519cb-b5fe-460f-9909-255634767327', '{"sub": "7ac519cb-b5fe-460f-9909-255634767327", "email": "jc392355@gmail.com", "full_name": "José Alvarado Cruz", "email_verified": false, "phone_verified": false}', 'email', '2025-10-30 16:05:03.219979+00', '2025-10-30 16:05:03.220645+00', '2025-10-30 16:05:03.220645+00', '53c52ffa-690f-4101-bd83-7276578c3f7e');
INSERT INTO   VALUES ('adba3600-c94a-46ad-8a66-03fa6e32e79e', 'adba3600-c94a-46ad-8a66-03fa6e32e79e', '{"sub": "adba3600-c94a-46ad-8a66-03fa6e32e79e", "email": "cruz27@gmail.com", "full_name": "Cruz", "email_verified": false, "phone_verified": false}', 'email', '2025-11-01 08:20:21.848609+00', '2025-11-01 08:20:21.850278+00', '2025-11-01 08:20:21.850278+00', '45195a0a-c8b1-4203-a22c-df9b8a85af4c');
INSERT INTO   VALUES ('aa3ac35a-e193-454d-bf07-3b89386c0c32', 'aa3ac35a-e193-454d-bf07-3b89386c0c32', '{"sub": "aa3ac35a-e193-454d-bf07-3b89386c0c32", "email": "hernan.cruz980@gmail.com", "full_name": "Hernan", "email_verified": false, "phone_verified": false}', 'email', '2025-11-01 17:47:27.507586+00', '2025-11-01 17:47:27.507634+00', '2025-11-01 17:47:27.507634+00', '614d7a08-8155-4703-86cf-1c9bebcb70cb');
INSERT INTO   VALUES ('63446142-dc7c-4d0e-a6c9-492b98b62121', '63446142-dc7c-4d0e-a6c9-492b98b62121', '{"sub": "63446142-dc7c-4d0e-a6c9-492b98b62121", "email": "blasesther36@gmail.com", "full_name": "Esther Elizabeth Blas Gutierrez", "email_verified": false, "phone_verified": false}', 'email', '2025-11-02 03:39:17.900527+00', '2025-11-02 03:39:17.901155+00', '2025-11-02 03:39:17.901155+00', '0b023250-97b5-4b7b-9d77-b8443b6272d3');
INSERT INTO   VALUES ('55b7c1c0-fdb8-4cdf-9938-761ddb309d2f', '55b7c1c0-fdb8-4cdf-9938-761ddb309d2f', '{"sub": "55b7c1c0-fdb8-4cdf-9938-761ddb309d2f", "email": "maricarmenbeatrizhilariocruz@gmail.com", "full_name": "maricarmen", "email_verified": false, "phone_verified": false}', 'email', '2025-11-02 03:43:11.141021+00', '2025-11-02 03:43:11.141069+00', '2025-11-02 03:43:11.141069+00', '1a79c697-5cf9-4376-ae3d-7f9b93ad2d4c');
INSERT INTO   VALUES ('45b5beac-7054-419d-9134-b3285a72f64b', '2025-10-23 11:52:03.137926+00', '2025-10-23 11:52:03.137926+00', 'password', '0555f7cd-cc8c-4fb7-a000-b3f7b9bf52dd');
INSERT INTO   VALUES ('b143319e-cc95-41de-84e3-05e4c6a0e0e5', '2025-10-23 14:20:53.576725+00', '2025-10-23 14:20:53.576725+00', 'password', 'c42687db-1275-4f74-bc78-309848fa6755');
INSERT INTO   VALUES ('f9aa683a-1e17-4cbe-8bce-7b6f887046ca', '2025-10-23 20:08:48.453096+00', '2025-10-23 20:08:48.453096+00', 'password', 'af277fdc-6ec9-4355-9046-ca4df3df0676');
INSERT INTO   VALUES ('cd5fea76-62ab-4ec8-83e4-194b7af5048f', '2025-10-23 20:34:02.108205+00', '2025-10-23 20:34:02.108205+00', 'password', 'af71b724-9be4-41af-854e-f60e91ed8917');
INSERT INTO   VALUES ('6be58b04-4e96-436a-a8f5-3b1bd11dc0da', '2025-10-24 06:01:13.349008+00', '2025-10-24 06:01:13.349008+00', 'password', '2c2d2b63-a29a-45c5-8586-42a66adf7872');
INSERT INTO   VALUES ('34d57ec1-d82d-4b12-ab6f-55e369fe5f59', '2025-10-24 07:23:43.006205+00', '2025-10-24 07:23:43.006205+00', 'password', 'bf0dbd7d-5bee-438a-ae2a-5471cf9ada79');
INSERT INTO   VALUES ('688f4434-705f-4e60-91c6-fbbdd487838d', '2025-10-26 01:43:12.996077+00', '2025-10-26 01:43:12.996077+00', 'recovery', 'b479d468-84ce-4645-aad1-d71bad3e52b9');
INSERT INTO   VALUES ('d0827106-1917-4372-a13b-6427b45860bc', '2025-10-26 07:12:36.03613+00', '2025-10-26 07:12:36.03613+00', 'password', '949c5633-04d6-4a10-aef6-8e4d2c6916ae');
INSERT INTO   VALUES ('2922415b-7fcb-4709-801c-519196d5a41a', '2025-10-26 08:31:29.233517+00', '2025-10-26 08:31:29.233517+00', 'password', '649673b6-6438-461c-9fe3-0a41b1a7ca9e');
INSERT INTO   VALUES ('170433e1-d4af-474e-8a30-9c8ea6471081', '2025-10-26 16:51:23.507966+00', '2025-10-26 16:51:23.507966+00', 'password', '41607b2d-fa3e-4ce6-ad5f-316832030cfe');
INSERT INTO   VALUES ('989ff94b-46cb-4ae7-9a4c-b27d0826d689', '2025-10-27 03:25:54.822959+00', '2025-10-27 03:25:54.822959+00', 'password', '15d691ed-fec1-4247-b7a9-67e0cd8be1a4');
INSERT INTO   VALUES ('c5038aeb-57da-48b9-b7f4-a0e6b40aecca', '2025-10-27 20:25:46.812828+00', '2025-10-27 20:25:46.812828+00', 'password', 'c6d23ecb-91ff-4592-9f30-81e6ed08f9ce');
INSERT INTO   VALUES ('e6371791-4c33-41bd-93d8-5ba54ece8e19', '2025-10-27 20:25:55.327372+00', '2025-10-27 20:25:55.327372+00', 'password', 'c3d11d6f-95e7-4578-8e48-de3462859e20');
INSERT INTO   VALUES ('f11e3189-a4cc-4424-bab9-45214c250742', '2025-10-30 16:05:03.298151+00', '2025-10-30 16:05:03.298151+00', 'password', '38386415-16ba-4f51-ad39-bb9f503d3bbc');
INSERT INTO   VALUES ('5b552e6b-af60-4033-8332-b906a524b0ac', '2025-10-30 16:05:13.752793+00', '2025-10-30 16:05:13.752793+00', 'password', '66948bf5-856c-44dd-9b63-10388adba798');
INSERT INTO   VALUES ('5bf0c205-c61f-4fd6-9781-ca0553db1022', '2025-11-01 08:20:21.939379+00', '2025-11-01 08:20:21.939379+00', 'password', 'db88956a-5eae-4eb5-b0c4-8de24089e21f');
INSERT INTO   VALUES ('228f56ff-9ea9-4e42-95a0-f13c6741e401', '2025-11-01 17:47:27.625129+00', '2025-11-01 17:47:27.625129+00', 'password', '66d2dd0e-24cb-4edc-8ef5-1f5aa113907d');
INSERT INTO   VALUES ('ce4648f2-82ad-48a5-93e7-7543884c407b', '2025-11-01 17:47:56.407888+00', '2025-11-01 17:47:56.407888+00', 'password', 'e32bd300-93c1-4202-b165-0bd67ec4d742');
INSERT INTO   VALUES ('eb186b5d-dc0c-4d0a-a750-8444ace5b044', '2025-11-02 03:39:18.005178+00', '2025-11-02 03:39:18.005178+00', 'password', 'a2d3918e-aff9-4b18-8b91-d5818f122ed7');
INSERT INTO   VALUES ('4533c924-2841-4f30-84ac-57341938e8e6', '2025-11-02 03:39:36.608693+00', '2025-11-02 03:39:36.608693+00', 'password', '58574216-e121-48b9-8506-3853827a6d48');
INSERT INTO   VALUES ('a62de13e-59c8-4873-b350-17cf8417e3fc', '2025-11-02 03:43:11.163634+00', '2025-11-02 03:43:11.163634+00', 'password', 'd882de9c-c207-4014-a897-a0a4547a7f0a');
INSERT INTO   VALUES ('204486aa-f189-4251-aec7-f08365e60630', '2025-11-02 15:24:46.006437+00', '2025-11-02 15:24:46.006437+00', 'password', '5d639cfe-3b52-4fe2-8b6a-e80372cdf9e7');
INSERT INTO   VALUES ('e07ee82f-a3f3-4071-a43e-6a656d14fc45', '2025-11-03 00:59:35.688362+00', '2025-11-03 00:59:35.688362+00', 'password', '474c639e-2f47-42f6-970b-287ef13af7f3');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '48', 'm4vio2jtfl5j', '0d7819d0-3444-4968-8793-f7a11d7d3ea4', 'f', '2025-10-26 07:12:36.034494+00', '2025-10-26 07:12:36.034494+00', NULL, 'd0827106-1917-4372-a13b-6427b45860bc');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '53', 'tzdfyboeasj7', '7188adff-27f9-41a3-a484-e3170491f2b4', 'f', '2025-10-26 08:31:29.229356+00', '2025-10-26 08:31:29.229356+00', NULL, '2922415b-7fcb-4709-801c-519196d5a41a');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '12', 'txhonsuddp6e', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 't', '2025-10-23 11:52:03.13617+00', '2025-10-23 13:56:28.420901+00', NULL, '45b5beac-7054-419d-9134-b3285a72f64b');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '13', 'vg4fwg3lqrfp', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'f', '2025-10-23 13:56:28.44422+00', '2025-10-23 13:56:28.44422+00', 'txhonsuddp6e', '45b5beac-7054-419d-9134-b3285a72f64b');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '60', 'laxvol675ilu', '5134f328-1aa9-41f1-aa85-27baab3ffb03', 'f', '2025-10-26 16:51:23.500927+00', '2025-10-26 16:51:23.500927+00', NULL, '170433e1-d4af-474e-8a30-9c8ea6471081');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '15', '6eatm2ow6kvz', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 't', '2025-10-23 14:20:53.568952+00', '2025-10-23 19:59:31.45537+00', NULL, 'b143319e-cc95-41de-84e3-05e4c6a0e0e5');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '16', 'dp5yibiuwdpp', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'f', '2025-10-23 19:59:31.462978+00', '2025-10-23 19:59:31.462978+00', '6eatm2ow6kvz', 'b143319e-cc95-41de-84e3-05e4c6a0e0e5');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '18', 'oyea6a5y7jjv', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'f', '2025-10-23 20:08:48.446655+00', '2025-10-23 20:08:48.446655+00', NULL, 'f9aa683a-1e17-4cbe-8bce-7b6f887046ca');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '19', 'g4qqfs3kenp6', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'f', '2025-10-23 20:34:02.066674+00', '2025-10-23 20:34:02.066674+00', NULL, 'cd5fea76-62ab-4ec8-83e4-194b7af5048f');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '23', 'qxt55dx35q2z', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'f', '2025-10-24 06:01:13.309619+00', '2025-10-24 06:01:13.309619+00', NULL, '6be58b04-4e96-436a-a8f5-3b1bd11dc0da');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '24', 'aoy5p4wkrpa2', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 't', '2025-10-24 07:23:42.992875+00', '2025-10-24 08:23:10.91356+00', NULL, '34d57ec1-d82d-4b12-ab6f-55e369fe5f59');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '66', 'wsfudcifswh3', '5134f328-1aa9-41f1-aa85-27baab3ffb03', 't', '2025-10-27 03:25:54.784498+00', '2025-10-27 16:19:19.634328+00', NULL, '989ff94b-46cb-4ae7-9a4c-b27d0826d689');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '25', 'b7sycle5sjch', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 't', '2025-10-24 08:23:10.929133+00', '2025-10-24 09:22:36.893335+00', 'aoy5p4wkrpa2', '34d57ec1-d82d-4b12-ab6f-55e369fe5f59');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '69', 'rpvxgtnayzru', '5134f328-1aa9-41f1-aa85-27baab3ffb03', 'f', '2025-10-27 16:19:19.655613+00', '2025-10-27 16:19:19.655613+00', 'wsfudcifswh3', '989ff94b-46cb-4ae7-9a4c-b27d0826d689');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '27', 'vkrmwg6gxb4s', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 't', '2025-10-24 09:22:36.893727+00', '2025-10-24 10:31:51.351494+00', 'b7sycle5sjch', '34d57ec1-d82d-4b12-ab6f-55e369fe5f59');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '28', 'mdt6sel5o4rx', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'f', '2025-10-24 10:31:51.366232+00', '2025-10-24 10:31:51.366232+00', 'vkrmwg6gxb4s', '34d57ec1-d82d-4b12-ab6f-55e369fe5f59');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '70', '2d36sf26nhfq', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'f', '2025-10-27 20:25:46.800527+00', '2025-10-27 20:25:46.800527+00', NULL, 'c5038aeb-57da-48b9-b7f4-a0e6b40aecca');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '76', 'liy5uhxj5h3x', '7ac519cb-b5fe-460f-9909-255634767327', 'f', '2025-10-30 16:05:03.28303+00', '2025-10-30 16:05:03.28303+00', NULL, 'f11e3189-a4cc-4424-bab9-45214c250742');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '77', 'cs7icb7dl5vj', '7ac519cb-b5fe-460f-9909-255634767327', 'f', '2025-10-30 16:05:13.750954+00', '2025-10-30 16:05:13.750954+00', NULL, '5b552e6b-af60-4033-8332-b906a524b0ac');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '81', 'pebkrmo2cbf6', 'adba3600-c94a-46ad-8a66-03fa6e32e79e', 'f', '2025-11-01 08:20:21.921546+00', '2025-11-01 08:20:21.921546+00', NULL, '5bf0c205-c61f-4fd6-9781-ca0553db1022');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '39', '6s4gfo5oajgz', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'f', '2025-10-26 01:43:12.985769+00', '2025-10-26 01:43:12.985769+00', NULL, '688f4434-705f-4e60-91c6-fbbdd487838d');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '83', 'x2xitngtjrfm', 'aa3ac35a-e193-454d-bf07-3b89386c0c32', 'f', '2025-11-01 17:47:27.596909+00', '2025-11-01 17:47:27.596909+00', NULL, '228f56ff-9ea9-4e42-95a0-f13c6741e401');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '84', 'tc3wdbrpdjyc', 'aa3ac35a-e193-454d-bf07-3b89386c0c32', 't', '2025-11-01 17:47:56.404363+00', '2025-11-01 22:41:11.024095+00', NULL, 'ce4648f2-82ad-48a5-93e7-7543884c407b');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '86', '5tsx4hp6w3pc', '63446142-dc7c-4d0e-a6c9-492b98b62121', 'f', '2025-11-02 03:39:17.982243+00', '2025-11-02 03:39:17.982243+00', NULL, 'eb186b5d-dc0c-4d0a-a750-8444ace5b044');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '88', 'hnrfwhgarqde', '55b7c1c0-fdb8-4cdf-9938-761ddb309d2f', 'f', '2025-11-02 03:43:11.160486+00', '2025-11-02 03:43:11.160486+00', NULL, 'a62de13e-59c8-4873-b350-17cf8417e3fc');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '87', 'eftivyvrs7eq', '63446142-dc7c-4d0e-a6c9-492b98b62121', 't', '2025-11-02 03:39:36.606813+00', '2025-11-02 04:41:28.321755+00', NULL, '4533c924-2841-4f30-84ac-57341938e8e6');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '85', '7hxt2hh7v7qy', 'aa3ac35a-e193-454d-bf07-3b89386c0c32', 't', '2025-11-01 22:41:11.040624+00', '2025-11-02 13:46:07.178891+00', 'tc3wdbrpdjyc', 'ce4648f2-82ad-48a5-93e7-7543884c407b');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '91', 'zptk26ghru75', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 't', '2025-11-02 15:24:45.983659+00', '2025-11-03 06:36:07.061503+00', NULL, '204486aa-f189-4251-aec7-f08365e60630');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '71', 'qv74bgvjbemg', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 't', '2025-10-27 20:25:55.3261+00', '2025-11-03 18:15:22.165964+00', NULL, 'e6371791-4c33-41bd-93d8-5ba54ece8e19');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '94', 'd3n7do7s3cxa', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'f', '2025-11-03 18:15:22.188136+00', '2025-11-03 18:15:22.188136+00', 'qv74bgvjbemg', 'e6371791-4c33-41bd-93d8-5ba54ece8e19');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '89', 'b2bgzzikwg2b', '63446142-dc7c-4d0e-a6c9-492b98b62121', 't', '2025-11-02 04:41:28.334706+00', '2025-11-03 22:58:35.054959+00', 'eftivyvrs7eq', '4533c924-2841-4f30-84ac-57341938e8e6');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '95', 'ul7codkh3u6o', '63446142-dc7c-4d0e-a6c9-492b98b62121', 'f', '2025-11-03 22:58:35.07168+00', '2025-11-03 22:58:35.07168+00', 'b2bgzzikwg2b', '4533c924-2841-4f30-84ac-57341938e8e6');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '93', 'lo7uczftrer5', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 't', '2025-11-03 06:36:07.083181+00', '2025-11-03 23:50:11.065751+00', 'zptk26ghru75', '204486aa-f189-4251-aec7-f08365e60630');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '96', 'ttx3cowvbg5e', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 't', '2025-11-03 23:50:11.081498+00', '2025-11-05 16:27:38.159966+00', 'lo7uczftrer5', '204486aa-f189-4251-aec7-f08365e60630');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '97', 'kazuhvuztsj2', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'f', '2025-11-05 16:27:38.183897+00', '2025-11-05 16:27:38.183897+00', 'ttx3cowvbg5e', '204486aa-f189-4251-aec7-f08365e60630');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '92', 'ljxntggzpufc', '5134f328-1aa9-41f1-aa85-27baab3ffb03', 't', '2025-11-03 00:59:35.634078+00', '2025-11-07 16:28:06.648391+00', NULL, 'e07ee82f-a3f3-4071-a43e-6a656d14fc45');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '98', 'u4iodvywko6p', '5134f328-1aa9-41f1-aa85-27baab3ffb03', 'f', '2025-11-07 16:28:06.667581+00', '2025-11-07 16:28:06.667581+00', 'ljxntggzpufc', 'e07ee82f-a3f3-4071-a43e-6a656d14fc45');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '90', 'dcfxjc74h65o', 'aa3ac35a-e193-454d-bf07-3b89386c0c32', 't', '2025-11-02 13:46:07.199885+00', '2025-11-12 23:33:09.280998+00', '7hxt2hh7v7qy', 'ce4648f2-82ad-48a5-93e7-7543884c407b');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '99', 'fpqgogxzqwq6', 'aa3ac35a-e193-454d-bf07-3b89386c0c32', 'f', '2025-11-12 23:33:09.303356+00', '2025-11-12 23:33:09.303356+00', 'dcfxjc74h65o', 'ce4648f2-82ad-48a5-93e7-7543884c407b');
INSERT INTO   VALUES ('20171026211738');
INSERT INTO   VALUES ('20171026211808');
INSERT INTO   VALUES ('20171026211834');
INSERT INTO   VALUES ('20180103212743');
INSERT INTO   VALUES ('20180108183307');
INSERT INTO   VALUES ('20180119214651');
INSERT INTO   VALUES ('20180125194653');
INSERT INTO   VALUES ('00');
INSERT INTO   VALUES ('20210710035447');
INSERT INTO   VALUES ('20210722035447');
INSERT INTO   VALUES ('20210730183235');
INSERT INTO   VALUES ('20210909172000');
INSERT INTO   VALUES ('20210927181326');
INSERT INTO   VALUES ('20211122151130');
INSERT INTO   VALUES ('20211124214934');
INSERT INTO   VALUES ('20211202183645');
INSERT INTO   VALUES ('20220114185221');
INSERT INTO   VALUES ('20220114185340');
INSERT INTO   VALUES ('20220224000811');
INSERT INTO   VALUES ('20220323170000');
INSERT INTO   VALUES ('20220429102000');
INSERT INTO   VALUES ('20220531120530');
INSERT INTO   VALUES ('20220614074223');
INSERT INTO   VALUES ('20220811173540');
INSERT INTO   VALUES ('20221003041349');
INSERT INTO   VALUES ('20221003041400');
INSERT INTO   VALUES ('20221011041400');
INSERT INTO   VALUES ('20221020193600');
INSERT INTO   VALUES ('20221021073300');
INSERT INTO   VALUES ('20221021082433');
INSERT INTO   VALUES ('20221027105023');
INSERT INTO   VALUES ('20221114143122');
INSERT INTO   VALUES ('20221114143410');
INSERT INTO   VALUES ('20221125140132');
INSERT INTO   VALUES ('20221208132122');
INSERT INTO   VALUES ('20221215195500');
INSERT INTO   VALUES ('20221215195800');
INSERT INTO   VALUES ('20221215195900');
INSERT INTO   VALUES ('20230116124310');
INSERT INTO   VALUES ('20230116124412');
INSERT INTO   VALUES ('20230131181311');
INSERT INTO   VALUES ('20230322519590');
INSERT INTO   VALUES ('20230402418590');
INSERT INTO   VALUES ('20230411005111');
INSERT INTO   VALUES ('20230508135423');
INSERT INTO   VALUES ('20230523124323');
INSERT INTO   VALUES ('20230818113222');
INSERT INTO   VALUES ('20230914180801');
INSERT INTO   VALUES ('20231027141322');
INSERT INTO   VALUES ('20231114161723');
INSERT INTO   VALUES ('20231117164230');
INSERT INTO   VALUES ('20240115144230');
INSERT INTO   VALUES ('20240214120130');
INSERT INTO   VALUES ('20240306115329');
INSERT INTO   VALUES ('20240314092811');
INSERT INTO   VALUES ('20240427152123');
INSERT INTO   VALUES ('20240612123726');
INSERT INTO   VALUES ('20240729123726');
INSERT INTO   VALUES ('20240802193726');
INSERT INTO   VALUES ('20240806073726');
INSERT INTO   VALUES ('20241009103726');
INSERT INTO   VALUES ('20250717082212');
INSERT INTO   VALUES ('20250731150234');
INSERT INTO   VALUES ('20250804100000');
INSERT INTO   VALUES ('20250901200500');
INSERT INTO   VALUES ('20250903112500');
INSERT INTO   VALUES ('20250904133000');
INSERT INTO   VALUES ('20250925093508');
INSERT INTO   VALUES ('20251007112900');
INSERT INTO   VALUES ('45b5beac-7054-419d-9134-b3285a72f64b', '75d12d56-fc94-42da-9da1-c5c8459d8f29', '2025-10-23 11:52:03.13509+00', '2025-10-23 13:56:28.467924+00', NULL, 'aal1', NULL, '2025-10-23 13:56:28.46608', 'Dart/3.9 (dart:io)', '38.56.214.129', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('b143319e-cc95-41de-84e3-05e4c6a0e0e5', '75d12d56-fc94-42da-9da1-c5c8459d8f29', '2025-10-23 14:20:53.566058+00', '2025-10-23 19:59:31.477516+00', NULL, 'aal1', NULL, '2025-10-23 19:59:31.476907', 'Dart/3.9 (dart:io)', '38.56.214.129', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('f9aa683a-1e17-4cbe-8bce-7b6f887046ca', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', '2025-10-23 20:08:48.443787+00', '2025-10-23 20:08:48.443787+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '38.56.214.129', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('cd5fea76-62ab-4ec8-83e4-194b7af5048f', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', '2025-10-23 20:34:02.038569+00', '2025-10-23 20:34:02.038569+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '38.56.214.129', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('6be58b04-4e96-436a-a8f5-3b1bd11dc0da', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', '2025-10-24 06:01:13.274018+00', '2025-10-24 06:01:13.274018+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '38.56.214.129', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('989ff94b-46cb-4ae7-9a4c-b27d0826d689', '5134f328-1aa9-41f1-aa85-27baab3ffb03', '2025-10-27 03:25:54.760195+00', '2025-10-27 16:19:19.68227+00', NULL, 'aal1', NULL, '2025-10-27 16:19:19.680306', 'Dart/3.9 (dart:io)', '181.176.112.91', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('34d57ec1-d82d-4b12-ab6f-55e369fe5f59', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', '2025-10-24 07:23:42.983788+00', '2025-10-24 10:31:51.391859+00', NULL, 'aal1', NULL, '2025-10-24 10:31:51.391748', 'Dart/3.9 (dart:io)', '38.56.214.129', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('c5038aeb-57da-48b9-b7f4-a0e6b40aecca', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', '2025-10-27 20:25:46.78711+00', '2025-10-27 20:25:46.78711+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '38.56.214.129', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('f11e3189-a4cc-4424-bab9-45214c250742', '7ac519cb-b5fe-460f-9909-255634767327', '2025-10-30 16:05:03.267109+00', '2025-10-30 16:05:03.267109+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '190.236.29.175', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('688f4434-705f-4e60-91c6-fbbdd487838d', '75d12d56-fc94-42da-9da1-c5c8459d8f29', '2025-10-26 01:43:12.982166+00', '2025-10-26 01:43:12.982166+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '38.56.214.129', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('5b552e6b-af60-4033-8332-b906a524b0ac', '7ac519cb-b5fe-460f-9909-255634767327', '2025-10-30 16:05:13.749046+00', '2025-10-30 16:05:13.749046+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '190.236.29.175', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('d0827106-1917-4372-a13b-6427b45860bc', '0d7819d0-3444-4968-8793-f7a11d7d3ea4', '2025-10-26 07:12:36.033478+00', '2025-10-26 07:12:36.033478+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '38.56.214.129', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('2922415b-7fcb-4709-801c-519196d5a41a', '7188adff-27f9-41a3-a484-e3170491f2b4', '2025-10-26 08:31:29.224121+00', '2025-10-26 08:31:29.224121+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '38.56.214.129', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('5bf0c205-c61f-4fd6-9781-ca0553db1022', 'adba3600-c94a-46ad-8a66-03fa6e32e79e', '2025-11-01 08:20:21.906637+00', '2025-11-01 08:20:21.906637+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '38.56.214.41', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('170433e1-d4af-474e-8a30-9c8ea6471081', '5134f328-1aa9-41f1-aa85-27baab3ffb03', '2025-10-26 16:51:23.496562+00', '2025-10-26 16:51:23.496562+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '38.56.214.129', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('228f56ff-9ea9-4e42-95a0-f13c6741e401', 'aa3ac35a-e193-454d-bf07-3b89386c0c32', '2025-11-01 17:47:27.573582+00', '2025-11-01 17:47:27.573582+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '190.21.156.163', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('eb186b5d-dc0c-4d0a-a750-8444ace5b044', '63446142-dc7c-4d0e-a6c9-492b98b62121', '2025-11-02 03:39:17.964462+00', '2025-11-02 03:39:17.964462+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '132.191.2.142', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('a62de13e-59c8-4873-b350-17cf8417e3fc', '55b7c1c0-fdb8-4cdf-9938-761ddb309d2f', '2025-11-02 03:43:11.158718+00', '2025-11-02 03:43:11.158718+00', NULL, 'aal1', NULL, NULL, 'Dart/3.9 (dart:io)', '190.239.192.228', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('e6371791-4c33-41bd-93d8-5ba54ece8e19', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', '2025-10-27 20:25:55.324633+00', '2025-11-03 18:15:22.217583+00', NULL, 'aal1', NULL, '2025-11-03 18:15:22.217506', 'Dart/3.9 (dart:io)', '181.176.46.84', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('4533c924-2841-4f30-84ac-57341938e8e6', '63446142-dc7c-4d0e-a6c9-492b98b62121', '2025-11-02 03:39:36.604797+00', '2025-11-03 22:58:35.089952+00', NULL, 'aal1', NULL, '2025-11-03 22:58:35.089872', 'Dart/3.9 (dart:io)', '132.251.0.50', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('204486aa-f189-4251-aec7-f08365e60630', '75d12d56-fc94-42da-9da1-c5c8459d8f29', '2025-11-02 15:24:45.963913+00', '2025-11-05 16:27:38.206943+00', NULL, 'aal1', NULL, '2025-11-05 16:27:38.206845', 'Dart/3.9 (dart:io)', '179.6.80.46', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('e07ee82f-a3f3-4071-a43e-6a656d14fc45', '5134f328-1aa9-41f1-aa85-27baab3ffb03', '2025-11-03 00:59:35.600397+00', '2025-11-07 16:28:06.690077+00', NULL, 'aal1', NULL, '2025-11-07 16:28:06.689986', 'Dart/3.9 (dart:io)', '181.176.93.185', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('ce4648f2-82ad-48a5-93e7-7543884c407b', 'aa3ac35a-e193-454d-bf07-3b89386c0c32', '2025-11-01 17:47:56.401245+00', '2025-11-12 23:33:09.326237+00', NULL, 'aal1', NULL, '2025-11-12 23:33:09.326123', 'Dart/3.9 (dart:io)', '190.21.140.170', NULL, NULL, NULL, NULL);
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'adba3600-c94a-46ad-8a66-03fa6e32e79e', 'authenticated', 'authenticated', 'cruz27@gmail.com', '$2a$10$OBQ8XEPG8vshmJeV5cQOKOiI48zPYqegmrMmCWfmLR67REBXH4a1i', '2025-11-01 08:20:21.887652+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-01 08:20:33.23438+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "adba3600-c94a-46ad-8a66-03fa6e32e79e", "email": "cruz27@gmail.com", "full_name": "Cruz", "email_verified": true, "phone_verified": false}', NULL, '2025-11-01 08:20:21.782332+00', '2025-11-01 08:20:33.236809+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '5134f328-1aa9-41f1-aa85-27baab3ffb03', 'authenticated', 'authenticated', 'les17mari@gmail.com', '$2a$10$L6sRyG4EDJVJEamOQDB1kOOGkoU7DlTSdsmNd9du.ToTk.ly96S6m', '2025-10-26 16:51:23.489258+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-03 00:59:35.598499+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "5134f328-1aa9-41f1-aa85-27baab3ffb03", "email": "les17mari@gmail.com", "full_name": "Mariluz", "email_verified": true, "phone_verified": false}', NULL, '2025-10-26 16:51:23.462206+00', '2025-11-07 16:28:06.680756+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '7188adff-27f9-41a3-a484-e3170491f2b4', 'authenticated', 'authenticated', 'jr27efootball@gmail.com', '$2a$10$1w7eVmSSRzeq9TOZiB2NqO8Tbb2Y01HNYppTZUYLLNO4V1ltta7py', '2025-10-26 08:31:29.213865+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-10-26 08:31:46.123306+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "7188adff-27f9-41a3-a484-e3170491f2b4", "email": "jr27efootball@gmail.com", "full_name": "Anakin", "email_verified": true, "phone_verified": false}', NULL, '2025-10-26 08:31:29.191933+00', '2025-10-26 08:31:46.125874+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '7c5383bc-f4b5-4ced-bc6e-14624442eed4', 'authenticated', 'authenticated', 'ceilita1580@gmail.com', '$2a$10$oCqPHKHXoSIKF1Ot4WxwpeKFuzP7/mqO2TAFEN9wGzBsHc6cXDj5G', '2025-10-27 20:25:46.763943+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-10-27 20:25:55.324547+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "7c5383bc-f4b5-4ced-bc6e-14624442eed4", "email": "ceilita1580@gmail.com", "full_name": "Ceila", "email_verified": true, "phone_verified": false}', NULL, '2025-10-27 20:25:46.649936+00', '2025-11-03 18:15:22.206049+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '9e3287a0-abfc-4234-8ecf-2f0a8ca5a801', 'authenticated', 'authenticated', 'steven27x01@gmail.com', '$2a$10$MmlHn8E6xowCeNpTLrhe5OJwyrKLX3q7fD6mjrvlHEFw2bjKmrTwa', '2025-10-23 09:29:12.359472+00', NULL, '', '2025-10-23 09:28:43.377585+00', '', NULL, '', '', NULL, '2025-10-26 06:49:42.479322+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "9e3287a0-abfc-4234-8ecf-2f0a8ca5a801", "email": "steven27x01@gmail.com", "full_name": "Steven", "email_verified": true, "phone_verified": false}', NULL, '2025-10-23 09:28:43.3436+00', '2025-10-26 06:49:42.484219+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '63446142-dc7c-4d0e-a6c9-492b98b62121', 'authenticated', 'authenticated', 'blasesther36@gmail.com', '$2a$10$HXs9d3XfZqXpsPuKEVjNKeMGtdSrz1e3mt5ut7vZrrkCmhMEtO1Hi', '2025-11-02 03:39:17.942358+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-02 03:39:36.604696+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "63446142-dc7c-4d0e-a6c9-492b98b62121", "email": "blasesther36@gmail.com", "full_name": "Esther Elizabeth Blas Gutierrez", "email_verified": true, "phone_verified": false}', NULL, '2025-11-02 03:39:17.815785+00', '2025-11-03 22:58:35.081904+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '0d7819d0-3444-4968-8793-f7a11d7d3ea4', 'authenticated', 'authenticated', 'jhuniorcruzcruz@gmail.com', '$2a$10$11KzZBKZqIZrheyc2P5BpecctjQesIZnvnMaWmVoiZsCsn41VHUAG', '2025-10-26 07:12:36.022447+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-01 08:18:32.616353+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "0d7819d0-3444-4968-8793-f7a11d7d3ea4", "email": "jhuniorcruzcruz@gmail.com", "full_name": "Mylo", "email_verified": true, "phone_verified": false}', NULL, '2025-10-26 07:12:35.99256+00', '2025-11-01 08:18:32.638101+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', 'aa3ac35a-e193-454d-bf07-3b89386c0c32', 'authenticated', 'authenticated', 'hernan.cruz980@gmail.com', '$2a$10$O/tEaICY9d3jx6HHs3s1R.BBx2GgNiTNIJvOtt/58ZpB3OO9gvhC2', '2025-11-01 17:47:27.547454+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-01 17:47:56.401155+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "aa3ac35a-e193-454d-bf07-3b89386c0c32", "email": "hernan.cruz980@gmail.com", "full_name": "Hernan", "email_verified": true, "phone_verified": false}', NULL, '2025-11-01 17:47:27.421593+00', '2025-11-12 23:33:09.318158+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '55b7c1c0-fdb8-4cdf-9938-761ddb309d2f', 'authenticated', 'authenticated', 'maricarmenbeatrizhilariocruz@gmail.com', '$2a$10$QEwg72sXJv26bZ9YHRHzuO9Jhhmqwftb00wZUKF0MIW5E0S7PHhIC', '2025-11-02 03:43:11.153657+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-11-02 03:43:11.158634+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "55b7c1c0-fdb8-4cdf-9938-761ddb309d2f", "email": "maricarmenbeatrizhilariocruz@gmail.com", "full_name": "maricarmen", "email_verified": true, "phone_verified": false}', NULL, '2025-11-02 03:43:11.130302+00', '2025-11-02 03:43:11.163145+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '7ac519cb-b5fe-460f-9909-255634767327', 'authenticated', 'authenticated', 'jc392355@gmail.com', '$2a$10$Odtf9t1HuY3M2I3WT1L.Fu1xZ8.3wg2UVBCipO4SUTm6ySaAuSS0K', '2025-10-30 16:05:03.252432+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-10-30 16:05:13.747804+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "7ac519cb-b5fe-460f-9909-255634767327", "email": "jc392355@gmail.com", "full_name": "José Alvarado Cruz", "email_verified": true, "phone_verified": false}', NULL, '2025-10-30 16:05:03.136396+00', '2025-10-30 16:05:13.75248+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
INSERT INTO   VALUES ('00000000-0000-0000-0000-000000000000', '75d12d56-fc94-42da-9da1-c5c8459d8f29', 'authenticated', 'authenticated', 'jr11steven@gmail.com', '$2a$10$1g0SzZW3SEW0HWJHB5oFRuO7XzR5dXDH38RnUIp4z0QrWWAV9UpLG', '2025-10-22 10:46:06.773053+00', NULL, '', '2025-10-22 10:45:44.919766+00', '', '2025-10-26 01:42:59.487804+00', '', '', NULL, '2025-11-02 15:24:45.962609+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "75d12d56-fc94-42da-9da1-c5c8459d8f29", "name": "Jhunior Cruz", "email": "jr11steven@gmail.com", "email_verified": true, "phone_verified": false}', NULL, '2025-10-22 10:45:44.853511+00', '2025-11-05 16:27:38.1969+00', NULL, NULL, '', '', NULL, '', '0', NULL, '', NULL, 'f', NULL, 'f');
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


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211116024918', '2025-10-21 19:25:41');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211116045059', '2025-10-21 19:25:44');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211116050929', '2025-10-21 19:25:47');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211116051442', '2025-10-21 19:25:49');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211116212300', '2025-10-21 19:25:51');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211116213355', '2025-10-21 19:25:53');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211116213934', '2025-10-21 19:25:55');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211116214523', '2025-10-21 19:25:58');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211122062447', '2025-10-21 19:26:01');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211124070109', '2025-10-21 19:26:03');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211202204204', '2025-10-21 19:26:05');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211202204605', '2025-10-21 19:26:07');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211210212804', '2025-10-21 19:26:14');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20211228014915', '2025-10-21 19:26:16');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20220107221237', '2025-10-21 19:26:18');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20220228202821', '2025-10-21 19:26:20');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20220312004840', '2025-10-21 19:26:22');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20220603231003', '2025-10-21 19:26:26');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20220603232444', '2025-10-21 19:26:28');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20220615214548', '2025-10-21 19:26:30');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20220712093339', '2025-10-21 19:26:33');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20220908172859', '2025-10-21 19:26:35');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20220916233421', '2025-10-21 19:26:37');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20230119133233', '2025-10-21 19:26:39');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20230128025114', '2025-10-21 19:26:42');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20230128025212', '2025-10-21 19:26:44');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20230227211149', '2025-10-21 19:26:46');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20230228184745', '2025-10-21 19:26:48');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20230308225145', '2025-10-21 19:26:50');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20230328144023', '2025-10-21 19:26:53');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20231018144023', '2025-10-21 19:26:55');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20231204144023', '2025-10-21 19:26:59');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20231204144024', '2025-10-21 19:27:01');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20231204144025', '2025-10-21 19:27:03');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240108234812', '2025-10-21 19:27:05');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240109165339', '2025-10-21 19:27:07');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240227174441', '2025-10-21 19:27:11');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240311171622', '2025-10-21 19:27:14');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240321100241', '2025-10-21 19:27:19');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240401105812', '2025-10-21 19:27:25');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240418121054', '2025-10-21 19:27:28');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240523004032', '2025-10-21 19:27:36');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240618124746', '2025-10-21 19:27:38');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240801235015', '2025-10-21 19:27:40');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240805133720', '2025-10-21 19:27:42');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240827160934', '2025-10-21 19:27:44');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240919163303', '2025-10-21 19:27:47');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20240919163305', '2025-10-21 19:27:50');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20241019105805', '2025-10-21 19:27:52');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20241030150047', '2025-10-21 19:28:00');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20241108114728', '2025-10-21 19:28:03');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20241121104152', '2025-10-21 19:28:05');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20241130184212', '2025-10-21 19:28:08');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20241220035512', '2025-10-21 19:28:10');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20241220123912', '2025-10-21 19:28:12');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20241224161212', '2025-10-21 19:28:14');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20250107150512', '2025-10-21 19:28:16');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20250110162412', '2025-10-21 19:28:18');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20250123174212', '2025-10-21 19:28:21');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20250128220012', '2025-10-21 19:28:23');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20250506224012', '2025-10-21 19:28:25');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20250523164012', '2025-10-21 19:28:27');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20250714121412', '2025-10-21 19:28:29');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20250905041441', '2025-10-21 19:28:31');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('0', 'create-migrations-table', 'e18db593bcde2aca2a408c4d1100f6abba2195df', '2025-10-21 19:40:18.329013');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('1', 'initialmigration', '6ab16121fbaa08bbd11b712d05f358f9b555d777', '2025-10-21 19:40:18.347107');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('2', 'storage-schema', '5c7968fd083fcea04050c1b7f6253c9771b99011', '2025-10-21 19:40:18.354537');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('3', 'pathtoken-column', '2cb1b0004b817b29d5b0a971af16bafeede4b70d', '2025-10-21 19:40:18.416633');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('4', 'add-migrations-rls', '427c5b63fe1c5937495d9c635c263ee7a5905058', '2025-10-21 19:40:18.440257');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('5', 'add-size-functions', '79e081a1455b63666c1294a440f8ad4b1e6a7f84', '2025-10-21 19:40:18.44438');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('6', 'change-column-name-in-get-size', 'f93f62afdf6613ee5e7e815b30d02dc990201044', '2025-10-21 19:40:18.450276');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('7', 'add-rls-to-buckets', 'e7e7f86adbc51049f341dfe8d30256c1abca17aa', '2025-10-21 19:40:18.455998');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('8', 'add-public-to-buckets', 'fd670db39ed65f9d08b01db09d6202503ca2bab3', '2025-10-21 19:40:18.461432');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('9', 'fix-search-function', '3a0af29f42e35a4d101c259ed955b67e1bee6825', '2025-10-21 19:40:18.46624');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('10', 'search-files-search-function', '68dc14822daad0ffac3746a502234f486182ef6e', '2025-10-21 19:40:18.47144');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('11', 'add-trigger-to-auto-update-updated_at-column', '7425bdb14366d1739fa8a18c83100636d74dcaa2', '2025-10-21 19:40:18.476581');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('12', 'add-automatic-avif-detection-flag', '8e92e1266eb29518b6a4c5313ab8f29dd0d08df9', '2025-10-21 19:40:18.489226');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('13', 'add-bucket-custom-limits', 'cce962054138135cd9a8c4bcd531598684b25e7d', '2025-10-21 19:40:18.49454');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('14', 'use-bytes-for-max-size', '941c41b346f9802b411f06f30e972ad4744dad27', '2025-10-21 19:40:18.499512');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('15', 'add-can-insert-object-function', '934146bc38ead475f4ef4b555c524ee5d66799e5', '2025-10-21 19:40:18.534328');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('16', 'add-version', '76debf38d3fd07dcfc747ca49096457d95b1221b', '2025-10-21 19:40:18.539832');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('17', 'drop-owner-foreign-key', 'f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101', '2025-10-21 19:40:18.544508');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('18', 'add_owner_id_column_deprecate_owner', 'e7a511b379110b08e2f214be852c35414749fe66', '2025-10-21 19:40:18.553588');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('19', 'alter-default-value-objects-id', '02e5e22a78626187e00d173dc45f58fa66a4f043', '2025-10-21 19:40:18.563709');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('20', 'list-objects-with-delimiter', 'cd694ae708e51ba82bf012bba00caf4f3b6393b7', '2025-10-21 19:40:18.569436');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('21', 's3-multipart-uploads', '8c804d4a566c40cd1e4cc5b3725a664a9303657f', '2025-10-21 19:40:18.576921');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('22', 's3-multipart-uploads-big-ints', '9737dc258d2397953c9953d9b86920b8be0cdb73', '2025-10-21 19:40:18.594069');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('23', 'optimize-search-function', '9d7e604cddc4b56a5422dc68c9313f4a1b6f132c', '2025-10-21 19:40:18.607598');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('24', 'operation-function', '8312e37c2bf9e76bbe841aa5fda889206d2bf8aa', '2025-10-21 19:40:18.612392');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('25', 'custom-metadata', 'd974c6057c3db1c1f847afa0e291e6165693b990', '2025-10-21 19:40:18.617743');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('26', 'objects-prefixes', 'ef3f7871121cdc47a65308e6702519e853422ae2', '2025-10-21 19:40:18.622931');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('27', 'search-v2', '33b8f2a7ae53105f028e13e9fcda9dc4f356b4a2', '2025-10-21 19:40:18.641772');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('28', 'object-bucket-name-sorting', 'ba85ec41b62c6a30a3f136788227ee47f311c436', '2025-10-21 19:40:18.651877');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('29', 'create-prefixes', 'a7b1a22c0dc3ab630e3055bfec7ce7d2045c5b7b', '2025-10-21 19:40:18.661429');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('30', 'update-object-levels', '6c6f6cc9430d570f26284a24cf7b210599032db7', '2025-10-21 19:40:18.667744');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('31', 'objects-level-index', '33f1fef7ec7fea08bb892222f4f0f5d79bab5eb8', '2025-10-21 19:40:18.674737');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('32', 'backward-compatible-index-on-objects', '2d51eeb437a96868b36fcdfb1ddefdf13bef1647', '2025-10-21 19:40:18.683222');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('33', 'backward-compatible-index-on-prefixes', 'fe473390e1b8c407434c0e470655945b110507bf', '2025-10-21 19:40:18.690038');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('34', 'optimize-search-function-v1', '82b0e469a00e8ebce495e29bfa70a0797f7ebd2c', '2025-10-21 19:40:18.69193');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('35', 'add-insert-trigger-prefixes', '63bb9fd05deb3dc5e9fa66c83e82b152f0caf589', '2025-10-21 19:40:18.69777');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('36', 'optimise-existing-functions', '81cf92eb0c36612865a18016a38496c530443899', '2025-10-21 19:40:18.703913');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('37', 'add-bucket-name-length-trigger', '3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1', '2025-10-21 19:40:18.711633');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('38', 'iceberg-catalog-flag-on-buckets', '19a8bd89d5dfa69af7f222a46c726b7c41e462c5', '2025-10-21 19:40:18.717353');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('39', 'add-search-v2-sort-support', '39cf7d1e6bf515f4b02e41237aba845a7b492853', '2025-10-21 19:40:18.728665');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('40', 'fix-prefix-race-conditions-optimized', 'fd02297e1c67df25a9fc110bf8c8a9af7fb06d1f', '2025-10-21 19:40:18.734785');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('41', 'add-object-level-update-trigger', '44c22478bf01744b2129efc480cd2edc9a7d60e9', '2025-10-21 19:40:18.743373');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('42', 'rollback-prefix-triggers', 'f2ab4f526ab7f979541082992593938c05ee4b47', '2025-10-21 19:40:18.748862');
INSERT INTO public.transactions (id, user_id, type, amount, date, category, note, created_at) VALUES ('43', 'fix-object-level', 'ab837ad8f1c7d00cc0b7310e989a23388ff29fc6', '2025-10-21 19:40:18.755868');
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

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
