// Home screen — the dashboard the user lands on
const HomeScreen = ({ onTab, onOpenRenewal }) => {
  const total = RENEWALS.reduce((s, r) => s + (r.cycle === 'yr' ? r.amount / 12 : r.cycle === '2yr' ? r.amount / 24 : r.amount), 0);
  const thisWeek = RENEWALS.filter(r => r.due <= 7);
  const weekTotal = thisWeek.reduce((s, r) => s + r.amount, 0);
  const upcoming = [...RENEWALS].sort((a, b) => a.due - b.due).slice(0, 4);
  const hour = new Date().getHours();
  const greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';

  return (
    <div className="app" data-screen-label="Home">
      <div className="sparkle-bg" style={{ opacity: 0.7 }}/>
      <StatusBar/>
      <div className="app-scroll">
        {/* Greeting header */}
        <div style={{ padding: '64px 4px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={{ fontSize: 13, color: 'var(--text-3)', letterSpacing: '-0.005em' }}>{greeting},</div>
            <div className="screen-title" style={{ marginTop: 2 }}>Rohan</div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            <div className="icon-btn" style={{ position: 'relative' }}>
              <Icon name="bell" size={17}/>
              <div style={{ position: 'absolute', top: 7, right: 7, width: 7, height: 7, borderRadius: '50%', background: 'var(--danger)', border: '1.5px solid var(--surface)' }}/>
            </div>
            <div className="logo-tile sm" style={{
              background: 'var(--primary)', color: '#fff', width: 36, height: 36, borderRadius: 10, fontSize: 13,
            }}>R</div>
          </div>
        </div>

        {/* Hero — AI brief card */}
        <div className="card" style={{ padding: 16, marginBottom: 12, position: 'relative', overflow: 'hidden', flexShrink: 0 }}>
          <div style={{ position: 'absolute', inset: 0, background: 'var(--gradient-soft)', opacity: 0.5 }}/>
          <div style={{ position: 'relative' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
              <Sparkle size={14}/>
              <div style={{ fontSize: 10.5, color: 'var(--ai-accent)', textTransform: 'uppercase', letterSpacing: '0.08em', fontWeight: 700 }}>
                Your brief
              </div>
            </div>
            <div style={{ fontSize: 16, fontWeight: 600, letterSpacing: '-0.01em', lineHeight: 1.4 }}>
              <span className="mono">₹{weekTotal.toLocaleString('en-IN')}</span> due in the next 7 days across <span className="mono">{thisWeek.length}</span> renewals. Claude Max is the big one — your usage says stay.
            </div>
            <div style={{ display: 'flex', gap: 6, marginTop: 12 }}>
              <button className="btn ai sm" onClick={() => onTab('chat')} style={{ fontSize: 12 }}>
                <Sparkle size={11}/> Ask a follow-up
              </button>
              <button className="btn ghost sm" style={{ fontSize: 12 }}>View all 3</button>
            </div>
          </div>
        </div>

        {/* Two-up stat row */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, marginBottom: 18 }}>
          <div className="card" style={{ padding: 14 }}>
            <div style={{ fontSize: 10.5, color: 'var(--text-3)', textTransform: 'uppercase', letterSpacing: '0.08em', fontWeight: 600 }}>
              Monthly burn
            </div>
            <div className="mono" style={{ fontSize: 22, fontWeight: 600, letterSpacing: '-0.02em', marginTop: 6 }}>
              ₹{Math.round(total).toLocaleString('en-IN')}
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 4, fontSize: 11, color: 'var(--warn)', fontWeight: 600 }}>
              <Icon name="trend" size={11} color="var(--warn)"/> +22% vs avg
            </div>
          </div>
          <div className="card" style={{ padding: 14 }}>
            <div style={{ fontSize: 10.5, color: 'var(--text-3)', textTransform: 'uppercase', letterSpacing: '0.08em', fontWeight: 600 }}>
              Active
            </div>
            <div className="mono" style={{ fontSize: 22, fontWeight: 600, letterSpacing: '-0.02em', marginTop: 6 }}>
              {RENEWALS.length}
            </div>
            <div style={{ fontSize: 11, color: 'var(--text-3)', marginTop: 4 }}>
              5 categories
            </div>
          </div>
        </div>

        {/* Upcoming */}
        <div className="sec-label">
          Up next <span className="count">· {upcoming.length}</span>
          <span style={{ flex: 1 }}/>
          <span onClick={() => onTab('categories')} style={{ fontSize: 11, color: 'var(--text-2)', cursor: 'pointer', textTransform: 'none', letterSpacing: 0 }}>
            See all →
          </span>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {upcoming.map(r => <RenewalRow key={r.id} renewal={r} onOpen={onOpenRenewal}/>)}
        </div>

        {/* Spending lane (mini bar chart) */}
        <div className="sec-label" style={{ marginTop: 22 }}>By category <span className="count">· this month</span></div>
        <div className="card" style={{ padding: 16 }}>
          {[
            { cat: 'AI / Software', amt: 13236, color: 'var(--ai-accent)' },
            { cat: 'Insurance', amt: 1041, color: 'var(--primary)' },
            { cat: 'Membership', amt: 2899, color: 'var(--success)' },
            { cat: 'Entertainment', amt: 828, color: 'var(--warn)' },
          ].map((row, i, arr) => {
            const max = Math.max(...arr.map(x => x.amt));
            return (
              <div key={row.cat} style={{ marginBottom: i < arr.length - 1 ? 12 : 0 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, marginBottom: 5 }}>
                  <span style={{ color: 'var(--text-2)' }}>{row.cat}</span>
                  <span className="mono" style={{ fontWeight: 500 }}>₹{row.amt.toLocaleString('en-IN')}</span>
                </div>
                <div style={{ height: 5, background: 'var(--surface-2)', borderRadius: 999, overflow: 'hidden' }}>
                  <div style={{ width: `${(row.amt / max) * 100}%`, height: '100%', background: row.color, borderRadius: 999 }}/>
                </div>
              </div>
            );
          })}
        </div>

        {/* AI nudge */}
        <div className="sec-label" style={{ marginTop: 22 }}>
          <Sparkle size={11}/> Worth a look
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <div className="sugg" onClick={() => onTab('chat')}>
            <div>
              <div className="q">Cult.fit Elite renews in 19 days</div>
              <div className="h">Used 4× in 90d · draft cancellation?</div>
            </div>
            <Icon name="chevron" size={14} color="var(--text-3)"/>
          </div>
          <div className="sugg" onClick={() => onTab('chat')}>
            <div>
              <div className="q">Netflix + Prime Video overlap</div>
              <div className="h">Save ~₹3,200/yr by consolidating</div>
            </div>
            <Icon name="chevron" size={14} color="var(--text-3)"/>
          </div>
        </div>

        <div style={{ height: 20 }}/>
      </div>
      <TabBar active="home" onTab={onTab}/>
    </div>
  );
};

window.HomeScreen = HomeScreen;
