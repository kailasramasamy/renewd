// Data: renewals, documents, chat, categories
const RENEWALS = [
  { id: 'icloud', name: 'iCloud+', vendor: 'Apple', category: 'Cloud', amount: 75, cycle: 'mo', due: 0, color: '#A2AAAD', logo: 'apple', auto: true },
  { id: 'anthropic', name: 'Claude Max', vendor: 'Anthropic', category: 'AI / Software', amount: 11033, cycle: 'mo', due: 6, color: '#D97757', logo: 'A', auto: true },
  { id: 'chatgpt', name: 'ChatGPT Plus', vendor: 'OpenAI', category: 'AI / Software', amount: 2203, cycle: 'mo', due: 23, color: '#10A37F', logo: 'G', auto: true },
  { id: 'prime', name: 'Amazon Prime', vendor: 'Amazon', category: 'Membership', amount: 399, cycle: 'mo', due: 28, color: '#FF9900', logo: 'a', auto: true },
  { id: 'dost', name: 'Scorpio Car Insurance', vendor: 'TATA AIG', category: 'Insurance', amount: 12495, cycle: 'yr', due: 47, color: '#0B5FFF', logo: 'T', auto: false, detail: true },
  { id: 'vrindavan', name: 'vrindavan.farm', vendor: 'Hostinger', category: 'Domain', amount: 5659, cycle: 'yr', due: 92, color: '#38BDF8', logo: 'V', auto: true },
  { id: 'fssai', name: 'FSSAI License', vendor: 'Govt. of India', category: 'Government', amount: 7500, cycle: '2yr', due: 156, color: '#22C55E', logo: 'F', auto: false },
  { id: 'nflx', name: 'Netflix', vendor: 'Netflix', category: 'Entertainment', amount: 649, cycle: 'mo', due: 11, color: '#E50914', logo: 'N', auto: true },
  { id: 'spotify', name: 'Spotify Family', vendor: 'Spotify', category: 'Entertainment', amount: 179, cycle: 'mo', due: 14, color: '#1DB954', logo: 'S', auto: true },
  { id: 'gym', name: 'Cult.fit Elite', vendor: 'Cult.fit', category: 'Membership', amount: 2499, cycle: 'mo', due: 19, color: '#FFD400', logo: 'C', auto: false },
];

const CATEGORIES = [
  { id: 'all', label: 'All', count: 15, total: 88520 },
  { id: 'insurance', label: 'Insurance', count: 2, total: 31638, icon: 'shield' },
  { id: 'subscription', label: 'Subscription', count: 6, total: 14762, icon: 'refresh' },
  { id: 'government', label: 'Government', count: 1, total: 7500, icon: 'building' },
  { id: 'membership', label: 'Membership', count: 3, total: 5397, icon: 'crown' },
  { id: 'digital', label: 'Digital', count: 3, total: 29223, icon: 'globe' },
];

const DOCUMENTS = [
  { id: 'd1', name: 'TATA-AIG-Policy-2026.pdf', size: '1.9 MB', linked: 'dost', analyzed: true, extracted: { 'Policy #': 'TATA-0092-14A', 'Premium': '₹12,495', 'Valid till': '21 Mar 2027' }, added: 'Mar 22' },
  { id: 'd2', name: 'FSSAI-License-2025-2027.pdf', size: '456 KB', linked: 'fssai', analyzed: true, extracted: { 'License #': '10023054000173', 'Valid till': '14 Sep 2027' }, added: 'Sep 14' },
  { id: 'd3', name: 'Invoice-Hostinger-Apr.pdf', size: '33.7 KB', linked: 'vrindavan', analyzed: true, extracted: { 'Amount': '₹5,659', 'Paid': '08 Apr 2026' }, added: 'Apr 08' },
  { id: 'd4', name: 'Anthropic-Receipt-04-2026.pdf', size: '22.1 KB', linked: 'anthropic', analyzed: true, extracted: { 'Amount': '₹11,033' }, added: 'Apr 11' },
  { id: 'd5', name: 'Cult-fit-agreement.pdf', size: '890 KB', linked: 'gym', analyzed: true, extracted: { 'Plan': 'Elite Annual', 'End': '12 Oct 2026' }, added: 'Oct 12' },
  { id: 'd6', name: 'Amazon-Prime-Invoice.pdf', size: '14.2 KB', linked: 'prime', analyzed: false, added: 'Apr 16' },
];

const SUGGESTIONS = [
  { q: "What's due this week?", hint: '3 renewals' },
  { q: 'Where am I overspending?', hint: 'Spending insight' },
  { q: 'Find duplicate subscriptions', hint: 'Cleanup' },
  { q: 'Draft cancellation for Cult.fit', hint: 'Takes action' },
];

const CHAT_SEED = [
  { role: 'user', text: "What's due this week?" },
  { role: 'ai', text: "3 renewals totalling ₹11,507 in the next 7 days.", card: 'upcoming' },
  { role: 'ai', text: "Claude Max is your biggest — ₹11,033, auto-renews Apr 24. Want me to check if you're on the right tier?", actions: ['Check tier', 'Snooze', 'Pay now'] },
];

Object.assign(window, { RENEWALS, CATEGORIES, DOCUMENTS, SUGGESTIONS, CHAT_SEED });
