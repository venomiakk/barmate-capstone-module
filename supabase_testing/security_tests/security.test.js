require("dotenv").config();

const axios = require("axios");

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const TEST_USER_EMAIL = process.env.TEST_USER_EMAIL;
const TEST_USER_PASSWORD = process.env.TEST_USER_PASSWORD;

let userAuth = {};

beforeAll(async () => {
  const { createClient } = require("@supabase/supabase-js");
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

  const { data, error } = await supabase.auth.signInWithPassword({
    email: TEST_USER_EMAIL,
    password: TEST_USER_PASSWORD,
  });

  if (error) {
    throw new Error("Failed to login: " + error.message);
  }

  userAuth.token = data.session.access_token;
  userAuth.uuid = data.user.id;
});

const api = axios.create({
  baseURL: `${SUPABASE_URL}/rest/v1`,
  headers: {
    apikey: SUPABASE_ANON_KEY,
  },
});

describe("API Security for /user_stash endpoint", () => {
  test("Should return 401 when user is not logged in", async () => {
    try {
      await api.get("/user_stash?select=*");
    } catch (error) {
      expect(error.response.status).toBe(401);
    }
  });

  test("Should return 200 when user is logged in", async () => {
    const response = await api.get("/user_stash?select=*", {
      headers: {
        Authorization: `Bearer ${userAuth.token}`,
      },
    });

    expect(response.status).toBe(200);
    expect(Array.isArray(response.data)).toBe(true);
    for (const item of response.data) {
      expect(item.user_id).toBe(userAuth.uuid);
    }
  });
});
