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

# Load tests (API)

```bash
k6 run load-test.js
```

## Results

```bash
PS D:\GitRepos\barmate-capstone-module\supabase_testing\load_tests> k6 run load-test.js

         /\      Grafana   /‾‾/
    /\  /  \     |\  __   /  /
   /  \/    \    | |/ /  /   ‾‾\
  /          \   |   (  |  (‾)  |
 / __________ \  |_|\_\  \_____/

     execution: local
        script: load-test.js
        output: -

     scenarios: (100.00%) 1 scenario, 1000 max VUs, 1m0s max duration (incl. graceful stop):
              * default: 1000 looping VUs for 30s (gracefulStop: 30s)



  █ THRESHOLDS

    http_req_duration
    ✓ 'p(95)<800' p(95)=121.16ms

    http_req_failed
    ✓ 'rate<0.01' rate=0.00%


  █ TOTAL RESULTS

    checks_total.......................: 26585   853.789171/s
    checks_succeeded...................: 100.00% 26585 out of 26585
    checks_failed......................: 0.00%   0 out of 26585

    ✓ status was 200

    HTTP
    http_req_duration.......................................................: avg=71.67ms min=39.9ms med=62.68ms max=625.19ms p(90)=98.81ms p(95)=121.16ms
      { expected_response:true }............................................: avg=71.67ms min=39.9ms med=62.68ms max=625.19ms p(90)=98.81ms p(95)=121.16ms
    http_req_failed.........................................................: 0.00%  0 out of 26585
    http_reqs...............................................................: 26585  853.789171/s

    EXECUTION
    iteration_duration......................................................: avg=1.14s   min=1.03s  med=1.06s   max=5.32s    p(90)=1.1s    p(95)=1.18s
    iterations..............................................................: 26585  853.789171/s
    vus.....................................................................: 127    min=127        max=1000
    vus_max.................................................................: 1000   min=1000       max=1000

    NETWORK
    data_received...........................................................: 85 MB  2.7 MB/s
    data_sent...............................................................: 2.4 MB 76 kB/s




running (0m31.1s), 0000/1000 VUs, 26585 complete and 0 interrupted iterations
default ✓ [======================================] 1000 VUs  30s
```
