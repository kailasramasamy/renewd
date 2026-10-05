// Renewal detail — e.g. Scorpio Car Insurance
const DetailScreen = ({ renewal, onBack }) => {
  const r = renewal || RENEWALS.find(x => x.id === 'dost');
  const [autoRenew, setAutoRenew] = React.useState(r.auto);
  const [tab, setTab] = React.useState('overview'); // overview | documents | activity

  // Days until renewal
  const daysLeft = 337;
  const totalDays = 365;
  const progress = (totalDays - daysLeft) / totalDays;

  return (
    <div className="app" data-screen-label="Renewal Detail" style={{ background: 'var(--bg)' }}>
      <StatusBar/>
      {/* Colored atmosphere from brand */}
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, height: 360,
        background: `radial-gradient(500px 300px at 50% 0%, ${r.color}28, transparent 70%)`,
        pointerEvents: 'none',
      }}/>

      {/* Header */}
      <div style={{
        position: 'absolute', top: 52, left: 16, right: 16,
        display: 'flex', justifyContent: 'space-between', zIndex: 10,
      }}>
        <div className="icon-btn" onClick={onBack}><Icon name="back" size={18}/></div>
        <div style={{ display: 'flex', gap: 8 }}>
          <div className="icon-btn"><Icon name="bell" size={17}/></div>
          <div className="icon-btn"><Icon name="more" size={18}/></div>
        </div>
      </div>

      <div className="app-scroll" style={{ padding: '0 16px 120px' }}>
        {/* Hero */}
        <div style={{ textAlign: 'center', padding: '104px 8px 24px', position: 'relative' }}>
          <div style={{
            width: 76, height: 76, margin: '0 auto 18px',
            borderRadius: 20,
            background: `linear-gradient(135deg, ${r.color}30, ${r.color}18)`,
            border: `1px solid ${r.color}50`,
            display: 'grid', placeItems: 'center',
            color: r.color, fontSize: 30, fontWeight: 700,
            boxShadow: `0 10px 30px ${r.color}30`,
          }}>T</div>

          <div style={{ fontSize: 24, fontWeight: 700, letterSpacing: '-0.02em', lineHeight: 1.15 }}>
            {r.name}
          </div>
          <div style={{ fontSize: 13, color: 'var(--text-3)', marginTop: 6 }}>
            {r.vendor} · {r.category}
          </div>

          {/* Price */}
          <div style={{ marginTop: 22, display: 'flex', justifyContent: 'center', alignItems: 'baseline', gap: 6 }}>
            <span className="mono" style={{ fontSize: 44, fontWeight: 600, letterSpacing: '-0.03em' }}>
              ₹{r.amount.toLocaleString('en-IN')}
            </span>
            <span style={{ fontSize: 14, color: 'var(--text-3)' }}>/year</span>
          </div>
          <div style={{ fontSize: 12, color: 'var(--text-4)', marginTop: 4, fontFamily: 'var(--mono)' }}>
            ≈ ₹{Math.round(r.amount / 12).toLocaleString('en-IN')}/mo · ₹{Math.round(r.amount / 365).toLocaleString('en-IN')}/day
          </div>
        </div>

        {/* Countdown — horizontal progress, more honest than a ring */}
        <div className="card" style={{ padding: 18, marginBottom: 14 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 10 }}>
            <div>
              <div style={{ fontSize: 10.5, color: 'var(--text-3)', textTransform: 'uppercase', letterSpacing: '0.08em', fontWeight: 600 }}>
                Renews in
              </div>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 6, marginTop: 4 }}>
                <span className="mono" style={{ fontSize: 30, fontWeight: 600, letterSpacing: '-0.02em' }}>{daysLeft}</span>
                <span style={{ fontSize: 13, color: 'var(--text-3)' }}>days</span>
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ fontSize: 10.5, color: 'var(--text-3)', textTransform: 'uppercase', letterSpacing: '0.08em', fontWeight: 600 }}>
                Renewal date
              </div>
              <div className="mono" style={{ fontSize: 14, fontWeight: 500, marginTop: 4 }}>21 Mar 2027</div>
            </div>
          </div>
          <div className="progress-bar">
            <div className="fill" style={{ right: `${(1 - progress) * 100}%` }}/>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, fontSize: 10.5, color: 'var(--text-4)', fontFamily: 'var(--mono)' }}>
            <span>Mar 22 '26</span>
            <span>{Math.round(progress * 100)}% elapsed</span>
            <span>Mar 21 '27</span>
          </div>
        </div>

        {/* AI insight */}
        <div className="card" style={{ padding: 14, marginBottom: 14, position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', inset: 0, background: 'var(--ai-soft)', opacity: 0.9 }}/>
          <div style={{ position: 'relative', display: 'flex', gap: 12, alignItems: 'flex-start' }}>
            <Sparkle size={18}/>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 10.5, color: 'var(--ai-accent)', textTransform: 'uppercase', letterSpacing: '0.08em', fontWeight: 700 }}>
                Renewd AI
              </div>
              <div style={{ fontSize: 13.5, marginTop: 4, lineHeight: 1.45, letterSpacing: '-0.005em' }}>
                Premium rose 8% YoY. Comparable NCB-eligible policies from 3 insurers average <span className="mono">₹11,260</span> — worth a quote run in Feb.
              </div>
              <div style={{ display: 'flex', gap: 6, marginTop: 10 }}>
                <button className="btn ghost sm"><Icon name="trend" size={13}/> Compare quotes</button>
                <button className="btn ghost sm">Remind in Feb</button>
              </div>
            </div>
          </div>
        </div>

        {/* Key facts */}
        <div className="card" style={{ marginBottom: 14 }}>
          <div className="kv-row">
            <span className="k">Billing cycle</span>
            <span className="v">Yearly · Mar 21</span>
          </div>
          <div className="kv-row">
            <span className="k">Category</span>
            <span className="v" style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
              <Icon name="shield" size={14} color="var(--text-2)"/> Insurance
            </span>
          </div>
          <div className="kv-row">
            <span className="k">Policy #</span>
            <span className="v mono" style={{ fontSize: 13 }}>TATA-0092-14A</span>
          </div>
          <div className="kv-row">
            <span className="k">Coverage</span>
            <span className="v">Comprehensive · IDV ₹8.4L</span>
          </div>
          <div className="kv-row">
            <span style={{ display: 'flex', flexDirection: 'column' }}>
              <span className="k">Auto-renew</span>
              <span style={{ fontSize: 11, color: 'var(--text-3)', marginTop: 3, textTransform: 'none', letterSpacing: 0 }}>
                {autoRenew ? 'Charges ₹12,495 on Mar 21' : "We'll remind you 7 days out"}
              </span>
            </span>
            <div className={`toggle ${autoRenew ? 'on' : ''}`} onClick={() => setAutoRenew(!autoRenew)}/>
          </div>
        </div>

        {/* Linked documents */}
        <div className="sec-label">
          <Icon name="link" size={12}/> Linked documents <span className="count">· 2</span>
        </div>
        <div className="card">
          {DOCUMENTS.filter(d => d.linked === r.id).map((d, i, arr) => (
            <DocRow key={d.id} doc={d} isLast={i === arr.length - 1}/>
          ))}
        </div>

        {/* Summary */}
        <div className="sec-label">
          <Sparkle size={11}/> Policy summary
        </div>
        <div className="card" style={{ padding: 16 }}>
          <div style={{ fontSize: 13.5, lineHeight: 1.55, color: 'var(--text-2)', letterSpacing: '-0.005em' }}>
            Comprehensive motor policy for a Mahindra Scorpio MUV. Covers own-damage, third-party liability, and compulsory personal accident cover. 50% no-claim bonus carried forward from 2024. Add-ons: zero-dep, engine protect.
          </div>
          <button className="btn ghost sm" style={{ marginTop: 12 }}>
            <Icon name="sparkle" size={12}/> Explain coverage
          </button>
        </div>

        <div style={{ height: 100 }}/>
      </div>

      {/* Action bar */}
      <div style={{
        position: 'absolute', left: 12, right: 12, bottom: 90, zIndex: 25,
        display: 'flex', gap: 8,
      }}>
        <button className="btn ghost" style={{ flex: 1 }}>
          <Icon name="calendar" size={15}/> Schedule
        </button>
        <button className="btn" style={{ flex: 1.4 }}>
          Pay ₹{r.amount.toLocaleString('en-IN')}
        </button>
      </div>

      <TabBar active="categories" onTab={() => {}}/>
    </div>
  );
};

window.DetailScreen = DetailScreen;
