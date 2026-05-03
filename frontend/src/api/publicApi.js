import client from "./client";

export const publicApi = {
  async getUpdates(params = {}) {
    const { data } = await client.get("/public/updates", { params });
    return data;
  },

  async getUpdateDetail(slug) {
    const { data } = await client.get(`/public/updates/${slug}`);
    return data;
  },

  async submitLead(payload) {
    const { data } = await client.post("/public/leads", payload);
    return data;
  },
};

