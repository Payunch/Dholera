import { API_BASE_URL } from './apiBase';

/**
 * Send WhatsApp message to a single lead
 * @param {Object} lead - The lead object
 * @returns {Promise<boolean>} - Success state
 */
export const sendWhatsAppMessage = async (lead) => {
  try {
    // 1. Fetch the pre-filled URL from backend
    const response = await fetch(`${API_BASE_URL}/leads/${lead.id}/whatsapp-url`, {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
      }
    });
    
    if (!response.ok) throw new Error('Failed to fetch WhatsApp URL');
    
    const { url } = await response.json();
    
    // 2. Open in new tab
    window.open(url, '_blank');
    
    // 3. Log the action (fire and forget)
    fetch(`${API_BASE_URL}/leads/${lead.id}/whatsapp-log`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
      },
      body: JSON.stringify({ message_sent: true })
    }).catch(err => console.error('Failed to log WhatsApp activity:', err));
    
    return true;
  } catch (err) {
    console.error('WhatsApp Error:', err);
    return false;
  }
};

/**
 * Send WhatsApp messages to multiple leads (semi-manual)
 * @param {Array} leads - Array of lead objects
 * @param {Function} onProgress - Callback for progress updates
 */
export const sendBulkWhatsApp = async (leads, onProgress = () => {}) => {
  for (let i = 0; i < leads.length; i++) {
    const lead = leads[i];
    onProgress(i + 1, leads.length, lead.name);
    
    await sendWhatsAppMessage(lead);
    
    // Wait 2 seconds between opening tabs to avoid browser blocking and admin overwhelm
    if (i < leads.length - 1) {
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
};
