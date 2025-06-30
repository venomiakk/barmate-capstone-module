BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(2);

-- Sprawdzamy, czy polityka RLS dla tabeli user_stash istnieje
SELECT policies_are(
  'public',
  'user_stash',
  ARRAY[
    'Enable read access for authenticated users',
    'Enable delete for authenticated users',
    'Enable insert for authenticated users',
    'Enable update for authenticated users'
  ],
  'RLS Policy for user_stash should exists'
);

-- Sprawdzamy definicje jednej z wybranych polityk RLS
SELECT is(
  (SELECT qual FROM pg_policies WHERE tablename = 'user_stash' AND policyname = 'Enable read access for authenticated users'),
  '(auth.uid() = user_id)',
  'RLS Policy should check auth.uid()'
);


SELECT * FROM finish();

ROLLBACK;