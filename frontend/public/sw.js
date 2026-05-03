self.addEventListener('install', (event) => {
  console.log('Service worker installed');
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('Service worker activated');
  return self.clients.claim();
});

self.addEventListener('push', (event) => {
  let data = {
    title: 'Dholera Growth Tracker',
    body: 'New infrastructure activity detected!',
    url: '/growth-tracker',
  };

  if (event.data) {
    try {
      data = { ...data, ...event.data.json() };
    } catch (e) {
      data.body = event.data.text();
    }
  }

  const options = {
    body: data.body,
    icon: '/favicon.svg',
    badge: '/favicon.svg',
    data: { url: data.url },
  };

  event.waitUntil(
    self.registration.showNotification(data.title, options)
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const urlToOpen = event.notification.data?.url || '/';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      if (windowClients.length > 0) {
        windowClients[0].focus();
        return windowClients[0].navigate(urlToOpen);
      }
      return clients.openWindow(urlToOpen);
    })
  );
});

self.addEventListener('fetch', (event) => {
  // Pass through network requests
  event.respondWith(fetch(event.request).catch(() => {
    // Offline fallback could go here
  }));
});
