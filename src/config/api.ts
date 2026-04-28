/**
 * Single source of truth for the Rails API origin.
 * Set VITE_API_BASE_URL at build time (e.g. http://YOUR_VCL_IP:3002).
 */
export const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || "http://localhost:3002";
