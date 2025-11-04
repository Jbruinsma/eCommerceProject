<template>
  <div class="admin-container">
    <main class="admin-content">
      <header class="admin-header">
        <h1>Admin Dashboard</h1>
        <p>Welcome, Admin. Use the tools below to manage the platform.</p>
      </header>

      <section class="actions-section">
        <h2>Quick Actions</h2>
        <div class="action-grid">
          <a href="/admin/funds" class="action-card">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M21 12a2.25 2.25 0 0 0-2.25-2.25H15a3 3 0 1 1-6 0H5.25A2.25 2.25 0 0 0 3 12m18 0v6a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 18v-6m18 0V9M3 12V9m18 0a2.25 2.25 0 0 0-2.25-2.25H5.25A2.25 2.25 0 0 0 3 9m18 0V6a2.25 2.25 0 0 0-2.25-2.25H5.25A2.25 2.25 0 0 0 3 6v3" />
            </svg>
            <h3>Manage Funds</h3>
            <p>Handle deposits, withdrawals, and balances.</p>
          </a>

          <a href="/admin/users" class="action-card">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
            </svg>
            <h3>Manage Users</h3>
            <p>Browse accounts, edit details, and assign roles.</p>
          </a>

          <a href="/admin/orders" class="action-card">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="m20.25 7.5-.625 10.632a2.25 2.25 0 0 1-2.247 2.118H6.622a2.25 2.25 0 0 1-2.247-2.118L3.75 7.5M10 11.25h4M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125Z" />
            </svg>
            <h3>Manage Orders</h3>
            <p>Review and update all user orders.</p>
          </a>

          <a href="/admin/analytics" class="action-card">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 0 1 3 19.875v-6.75ZM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V8.625ZM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V4.125Z" />
            </svg>
            <h3>System Analytics</h3>
            <p>View platform usage and growth metrics.</p>
          </a>

          <a href="/admin/settings" class="action-card">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.325.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.431l-1.003.827c-.293.241-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 0 1 0-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.086.22-.128.332-.183.582-.495.644-.869l.214-1.28Z" /><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
            </svg>
            <h3>System Settings</h3>
            <p>Configure global application settings.</p>
          </a>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { authenticateAdmin } from '@/utils/authenticateUser.js'

onMounted(async () => {
  await authenticateAdmin()
});
</script>

<style scoped>
h1,h2,h3 { color: #ffffff; font-family: Spectral, sans-serif; font-weight: 600; }
h1 { font-size: 2.8rem; margin-bottom: 0.5rem; }
h2 { border-bottom: 1px solid #333; font-size: 1.8rem; margin-bottom: 2rem; padding-bottom: 1rem; }
h3 { font-size: 1.2rem; margin: 0; }
p { color: #cccccc; line-height: 1.6; margin: 0; }
a { text-decoration: none; }
.admin-container { color: #ffffff; }
.admin-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.admin-header { margin-bottom: 4rem; text-align: center; }
.admin-header p { color: #888; font-size: 1.1rem; margin: 0 auto; max-width: 500px; }
.actions-section { margin-bottom: 4rem; }
.action-grid { display: grid; gap: 1.5rem; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); } /* MODIFIED: Base style for responsiveness */
@media (min-width: 1200px) { .action-grid { grid-template-columns: repeat(5, 1fr); } } /* NEW: Media query for 5 columns on large screens */
.action-card { align-items: center; background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; display: flex; flex-direction: column; gap: 0.75rem; padding: 2rem; text-align: center; transition: transform 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease; }
.action-card:hover { border-color: #444; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5); transform: translateY(-8px); }
.action-card svg { height: 48px; margin-bottom: 1rem; stroke: #ffffff; width: 48px; }
.action-card p { color: #888; font-size: 0.9rem; }
</style>
