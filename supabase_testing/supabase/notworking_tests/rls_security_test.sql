BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(1);

-- === FAZA 1: PRZYGOTOWANIE (Arrange) ===

-- --- NOWY KROK: Stworzenie danych-zależności ("Seeding") ---
-- Zanim dodamy coś do `user_stash`, musimy stworzyć składniki,
-- do których będziemy się odwoływać.
INSERT INTO public.ingredient_category (id, name)
VALUES (1, 'test_category');

INSERT INTO public.ingredient (id, name, unit, category_id) -- Użyj nazw kolumn z Twojej tabeli
VALUES
  (101, 'Test Ingredient A', 'ml', 1),
  (202, 'Test Ingredient B', 'g', 1);
-- --------------------------------------------------------

-- Tworzymy fałszywych użytkowników
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_token, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, email_change_token_current, email_change_confirm_status)
VALUES
  ('00000000-0000-0000-0000-000000000001', gen_random_uuid(), 'authenticated', 'authenticated', 'user.a@test.com', crypt('password123', gen_salt('bf')), now(), '', null, null, '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '', 0),
  ('00000000-0000-0000-0000-000000000002', gen_random_uuid(), 'authenticated', 'authenticated', 'user.b@test.com', crypt('password123', gen_salt('bf')), now(), '', null, null, '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '', 0);

CREATE TEMP TABLE test_users AS (
  SELECT id, email FROM auth.users WHERE email IN ('user.a@test.com', 'user.b@test.com')
);

-- Dodajemy wiersze do `user_stash`, używając ID składników, które właśnie stworzyliśmy
INSERT INTO public.user_stash (user_id, ingredient_id, amount)
VALUES 
  ((SELECT id FROM test_users WHERE email = 'user.a@test.com'), 101, 500), -- Używamy ingredient_id = 101
  ((SELECT id FROM test_users WHERE email = 'user.b@test.com'), 202, 750); -- Używamy ingredient_id = 202


-- === FAZA 2: DZIAŁANIE (Act) ===

-- Ustawiamy sesję jako Użytkownik A
SELECT set_config(
  'request.jwt.claims',
  json_build_object(
    'sub', (SELECT id FROM test_users WHERE email = 'user.a@test.com'),
    'role', 'authenticated'
  )::text,
  true
);

-- === FAZA 3: SPRAWDZENIE (Assert) ===

SELECT is (
    (SELECT COUNT(*)::bigint FROM public.user_stash),
    1::bigint,
    'Użytkownik powinien widzieć tylko swoje własne zasoby w barku.'
);


-- Kończymy test i cofamy wszystkie zmiany
SELECT * FROM finish();
ROLLBACK;

