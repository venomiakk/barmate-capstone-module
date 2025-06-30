import http from "k6/http";
import { check, sleep } from "k6";

const config = JSON.parse(open("./config.json"));
const SUPABASE_URL = config.SUPABASE_URL;
const SUPABASE_ANON_KEY = config.SUPABASE_ANON_KEY;

// --- Konfiguracja Testu ---
// Definiujemy, jak ma wyglądać obciążenie:
// 10 wirtualnych użytkowników (VUs) przez 30 sekund.
export const options = {
  vus: 1000,
  duration: "30s",
  thresholds: {
    // Test zakończy się błędem, jeśli 95% zapytań będzie trwać dłużej niż 800ms
    http_req_duration: ["p(95)<800"],
    // Test zakończy się błędem, jeśli więcej niż 1% zapytań się nie powiedzie
    http_req_failed: ["rate<0.01"],
  },
};

const headers = {
  apikey: SUPABASE_ANON_KEY,
  Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
};

// --- Główna funkcja testowa ---
// To jest kod, który będzie wykonywany w pętli przez każdego wirtualnego użytkownika.
export default function () {
  // Wysyłamy zapytanie GET, aby pobrać wszystkie przepisy
  const res = http.get(`${SUPABASE_URL}/rest/v1/recipe?select=*`, { headers });

  // Sprawdzamy, czy odpowiedź ma status 200 OK
  check(res, { "status was 200": (r) => r.status == 200 });

  // Czekamy 1 sekundę przed wykonaniem kolejnego zapytania
  sleep(1);
}
