// AI Chat screen — empty state + conversation
const ChatScreen = ({ onTab }) => {
  const [messages, setMessages] = React.useState([]);
  const [draft, setDraft] = React.useState('');
  const [typing, setTyping] = React.useState(false);
  const scrollRef = React.useRef(null);

  React.useEffect(() => {
    if (scrollRef.current) scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
  }, [messages, typing]);

  const sendMessage = (text) => {
    if (!text.trim()) return;
    setMessages(m => [...m, { role: 'user', text }]);
    setDraft('');
    setTyping(true);
    setTimeout(() => {
      setTyping(false);
      // canned replies
      const reply = getReply(text);
      setMessages(m => [...m, reply]);
    }, 900);
  };

  const empty = messages.length === 0;

  return (
    <div className="app" data-screen-label="AI Chat">
      <div className="sparkle-bg"/>
      <StatusBar/>
      {/* Header */}
      <div style={{ padding: '64px 20px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', position: 'relative', zIndex: 2 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <Sparkle size={22}/>
          <div>
            <div style={{ fontSize: 17, fontWeight: 700, letterSpacing: '-0.01em' }}>Renewd AI</div>
            <div style={{ fontSize: 11, color: 'var(--text-3)', fontFamily: 'var(--mono)' }}>online · knows 15 renewals</div>
          </div>
        </div>
        <div className="icon-btn" onClick={() => setMessages([])}>
          <Icon name={empty ? 'more' : 'close'} size={17}/>
        </div>
      </div>

      {/* Body */}
      {empty ? (
        <div className="app-scroll" style={{ padding: '24px 16px 220px', display: 'flex', flexDirection: 'column' }}>
          <div style={{ textAlign: 'center', padding: '20px 0 28px' }}>
            <div style={{
              width: 84, height: 84, margin: '0 auto 18px',
              borderRadius: 24, display: 'grid', placeItems: 'center',
              background: 'var(--ai-soft)',
              border: '1px solid var(--ai-accent)',
              boxShadow: '0 10px 40px var(--ai-glow)',
            }}>
              <Sparkle size={40}/>
            </div>
            <div style={{ fontSize: 24, fontWeight: 700, letterSpacing: '-0.02em' }}>
              Ask about your <span className="grad-text">renewals</span>
            </div>
            <div style={{ fontSize: 13.5, color: 'var(--text-3)', marginTop: 8, lineHeight: 1.5, maxWidth: 280, margin: '8px auto 0' }}>
              I can answer questions, draft cancellations, and flag renewals worth reviewing.
            </div>
          </div>

          {/* Snapshot card */}
          <div className="card" style={{ padding: 16, marginBottom: 18, position: 'relative', overflow: 'hidden', flexShrink: 0 }}>
            <div style={{ position: 'absolute', inset: 0, background: 'var(--ai-soft)', opacity: 0.8 }}/>
            <div style={{ position: 'relative' }}>
              <div style={{ fontSize: 10.5, color: 'var(--text-3)', textTransform: 'uppercase', letterSpacing: '0.08em', fontWeight: 600 }}>This week</div>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 6, marginTop: 6 }}>
                <span className="mono" style={{ fontSize: 28, fontWeight: 600, letterSpacing: '-0.02em' }}>₹11,507</span>
                <span style={{ fontSize: 12, color: 'var(--text-3)' }}>across 3 renewals</span>
              </div>
              <div style={{ display: 'flex', gap: 6, marginTop: 12 }}>
                {['iCloud · today', 'Claude · 6d', 'Netflix · 11d'].map(x => (
                  <div key={x} style={{
                    fontSize: 11, fontWeight: 600, padding: '4px 8px', borderRadius: 7,
                    background: 'var(--surface-2)', border: '1px solid var(--border)',
                    color: 'var(--text-2)'
                  }}>{x}</div>
                ))}
              </div>
            </div>
          </div>

          <div className="sec-label">Suggested <span className="count">tap to ask</span></div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {SUGGESTIONS.map(s => (
              <div key={s.q} className="sugg" onClick={() => sendMessage(s.q)}>
                <div>
                  <div className="q">{s.q}</div>
                  <div className="h">{s.hint}</div>
                </div>
                <Icon name="chevron" size={14} color="var(--text-3)"/>
              </div>
            ))}
          </div>
        </div>
      ) : (
        <div ref={scrollRef} style={{ flex: 1, overflow: 'auto', padding: '16px 16px 220px', display: 'flex', flexDirection: 'column', gap: 10 }}>
          {messages.map((m, i) => <ChatMessage key={i} msg={m} onAction={sendMessage}/>)}
          {typing && (
            <div className="bubble ai" style={{ display: 'inline-flex', gap: 4, alignItems: 'center', width: 'fit-content' }}>
              {[0,1,2].map(d => (
                <span key={d} style={{
                  width: 6, height: 6, borderRadius: '50%', background: 'var(--text-3)',
                  animation: `bounce 1.2s infinite ${d * 0.15}s`,
                }}/>
              ))}
              <style>{`@keyframes bounce { 0%,80%,100% { opacity: 0.3; transform: translateY(0); } 40% { opacity: 1; transform: translateY(-3px); } }`}</style>
            </div>
          )}
        </div>
      )}

      {/* Composer */}
      <div className="composer">
        <Sparkle size={18}/>
        <input
          placeholder="Ask about a renewal, cost, or due date…"
          value={draft}
          onChange={e => setDraft(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && sendMessage(draft)}
        />
        <button className="send-btn" onClick={() => sendMessage(draft)} disabled={!draft.trim()}>
          <Icon name="send" size={16} color="#fff" stroke={2.2}/>
        </button>
      </div>

      <TabBar active="chat" onTab={onTab}/>
    </div>
  );
};

const ChatMessage = ({ msg, onAction }) => {
  if (msg.role === 'user') {
    return <div className="bubble user">{msg.text}</div>;
  }
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 8, alignItems: 'flex-start', maxWidth: '100%' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginLeft: 4 }}>
        <Sparkle size={11}/>
        <span style={{ fontSize: 10.5, color: 'var(--text-3)', fontWeight: 600, letterSpacing: '0.04em' }}>RENEWD AI</span>
      </div>
      <div className="bubble ai">{msg.text}</div>
      {msg.card === 'upcoming' && <UpcomingMiniCard/>}
      {msg.list && (
        <div className="card" style={{ padding: 6, width: '88%' }}>
          {msg.list.map(r => (
            <div key={r.id} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: 8 }}>
              <LogoTile renewal={r} size="sm"/>
              <div style={{ flex: 1, fontSize: 13, fontWeight: 500 }}>{r.name}</div>
              <div className="mono" style={{ fontSize: 13, fontWeight: 600 }}>₹{r.amount.toLocaleString('en-IN')}</div>
            </div>
          ))}
        </div>
      )}
      {msg.actions && (
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', marginLeft: 2 }}>
          {msg.actions.map(a => (
            <button key={a} className="btn ghost sm" onClick={() => onAction(a)}>{a}</button>
          ))}
        </div>
      )}
    </div>
  );
};

const UpcomingMiniCard = () => {
  const next3 = RENEWALS.filter(r => r.due <= 11).slice(0, 3);
  return (
    <div className="card" style={{ padding: 6, width: '88%' }}>
      {next3.map((r, i) => (
        <div key={r.id} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: 10, borderBottom: i < next3.length - 1 ? '1px solid var(--border)' : 0 }}>
          <LogoTile renewal={r} size="sm"/>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13.5, fontWeight: 600, letterSpacing: '-0.01em' }}>{r.name}</div>
            <div style={{ fontSize: 11, color: 'var(--text-3)', marginTop: 2 }}>{r.due === 0 ? 'Today' : `in ${r.due} days`}</div>
          </div>
          <div className="mono" style={{ fontSize: 14, fontWeight: 600 }}>₹{r.amount.toLocaleString('en-IN')}</div>
        </div>
      ))}
    </div>
  );
};

// Canned AI responses
function getReply(q) {
  const s = q.toLowerCase();
  if (s.includes('week') || s.includes('due')) {
    return { role: 'ai', text: "3 renewals total ₹11,507 this week. Want me to prep payments or push any?", card: 'upcoming', actions: ['Prep payments', 'Push Netflix', 'Send to calendar'] };
  }
  if (s.includes('spending') || s.includes('month') || s.includes('overspend')) {
    return { role: 'ai', text: "You're at ₹18,063/mo on subscriptions — 22% up vs 90-day average. The jump is from Claude Max. Netflix + Spotify overlap with Prime Video and YT Music.", actions: ['Show overlap', 'Cancel suggestions'] };
  }
  if (s.includes('insurance')) {
    return { role: 'ai', text: "1 active insurance: Scorpio Car via TATA AIG, ₹12,495/yr. Renews 21 Mar 2027 — 337 days out.", list: RENEWALS.filter(r => r.category.includes('Insurance')) };
  }
  if (s.includes('expensive') || s.includes('biggest') || s.includes('top')) {
    const top = [...RENEWALS].sort((a, b) => b.amount - a.amount).slice(0, 3);
    return { role: 'ai', text: "Top 3 by annual cost:", list: top };
  }
  if (s.includes('duplicate')) {
    return { role: 'ai', text: "2 potential overlaps: Netflix + Prime Video (both streaming), Spotify + YT Music via Prime. You could save ~₹3,200/yr.", actions: ['Review overlaps'] };
  }
  if (s.includes('cancel') || s.includes('cult')) {
    return { role: 'ai', text: "Drafted a cancellation for Cult.fit Elite. Stops auto-renew on 7 May. Review before I send?", actions: ['Review draft', 'Send now', 'Cancel'] };
  }
  if (s.includes('check tier') || s.includes('tier')) {
    return { role: 'ai', text: "Your usage averages 2.1M tokens/wk. Max is right — Pro tier would throttle you by day 4. Staying put saves you switch churn." };
  }
  if (s.includes('prep')) {
    return { role: 'ai', text: "Queued iCloud (₹75), Claude Max (₹11,033), Netflix (₹649) for one-tap payment. I'll notify the night before each." };
  }
  return { role: 'ai', text: "Got it. Looking at your 15 renewals — anything specific you'd like me to check?" };
}

window.ChatScreen = ChatScreen;
