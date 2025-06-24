# Supabase tests

## Install

**Install supabase with _scoop_ for Windows or brew for _MacOs_**
**Docker is required**

Windows

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
scoop install supabase
```

## Login

```bash
supabase login

supabase link --project-ref <PROJECTID>
```

## Start

```bash
supabase start
```

## Migrations

```bash
supabase db pull
supabase db reset
```

## Others

```bash
docler rm ...
```

## Results

```bash
D:\GitRepos\barmate-capstone-module\supabase_testing>supabase test db
Connecting to local database...
psql:find_rls.sql:5: NOTICE:  extension "pgtap" already exists, skipping
./find_rls.sql .. ok
All tests successful.
Files=1, Tests=2,  0 wallclock secs ( 0.02 usr  0.01 sys +  0.01 cusr  0.01 csys =  0.05 CPU)
Result: PASS
```

# Security tests (supabase)

```bash
npm test
```

## Results

```bash
PS D:\GitRepos\barmate-capstone-module\supabase_testing\security_tests> npm test

> security_tests@1.0.0 test
> jest

 PASS  ./security.test.js
  API Security for /user_stash endpoint
    √ Should return 401 when user is not logged in (216 ms)
    √ Should return 200 when user is logged in (114 ms)

Test Suites: 1 passed, 1 total
Tests:       2 passed, 2 total
Snapshots:   0 total
Time:        1.507 s, estimated 2 s
Ran all test suites.
```
