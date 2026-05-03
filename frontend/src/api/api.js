import client from "./client";

// Public API endpoints
export const api = {
  // Public routes
  public: {
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
  },

  // Auth endpoints
  auth: {
    async login(payload) {
      const { data } = await client.post("/auth/login", payload);
      return data;
    },

    async me() {
      const { data } = await client.get("/auth/me");
      return data;
    },
  },

  // Admin endpoints
  admin: {
    async getDashboard() {
      const { data } = await client.get("/admin/dashboard");
      return data;
    },

    async getMeta() {
      const { data } = await client.get("/admin/meta");
      return data;
    },

    async getUpdates(params = {}) {
      const { data } = await client.get("/admin/updates", { params });
      return data;
    },

    async createUpdate(payload) {
      const { data } = await client.post("/admin/updates", payload);
      return data;
    },

    async updateUpdate(id, payload) {
      const { data } = await client.put(`/admin/updates/${id}`, payload);
      return data;
    },

    async deleteUpdate(id) {
      await client.delete(`/admin/updates/${id}`);
    },

    async uploadImage(file) {
      const formData = new FormData();
      formData.append("file", file);
      const { data } = await client.post("/admin/uploads/image", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      return data;
    },

    async uploadPdf(file) {
      const formData = new FormData();
      formData.append("file", file);
      const { data } = await client.post("/admin/uploads/pdf", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      return data;
    },

    async getLeads(params = {}) {
      const { data } = await client.get("/admin/leads", { params });
      return data;
    },

    async updateLead(id, payload) {
      const { data } = await client.patch(`/admin/leads/${id}`, payload);
      return data;
    },
  },
};

// Legacy exports for backwards compatibility during migration
export const publicApi = api.public;
export const adminApi = api.admin;
