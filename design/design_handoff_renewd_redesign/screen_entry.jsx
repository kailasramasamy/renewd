// ============================================================
// Entry flow screens — Splash, Onboarding, Login, OTP, Complete Profile
// ============================================================

// ---------- Brand mark (used in splash, onboarding, login) ----------
const BrandMark = ({ size = 56 }) => (
  <div style={{
    width: size, height: size,
    borderRadius: size * 0.26,
    background: 'var(--primary)',
    display: 'grid', placeItems: 'center',
    boxShadow: '0 10px 30px var(--primary-glow)',
    position: 'relative',
    overflow: 'hidden',
  }}>
    <svg width={size * 0.55} height={size * 0.55} viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 12a9 9 0 0115-6.7L21 8"/>
      <path d="M21 3v5h-5"/>
      <path d="M21 12a9 9 0 01-15 6.7L3 16"/>
      <path d="M3 21v-5h5"/>
    </svg>
    {/* Subtle inner highlight */}
    <div style={{
      position: 'absolute', inset: 0, borderRadius: 'inherit',
      background: 'linear-gradient(180deg, rgba(255,255,255,0.14), transparent 40%)',
      pointerEvents: 'none',
    }}/>
  </div>
);

// ============================================================
// 1. SPLASH
// ============================================================
const SplashScreen = () => {
  const [progress, setProgress] = React.useState(0);
  React.useEffect(() => {
    let t;
    const tick = () => { setProgress(p => Math.min(1, p + 0.02)); t = setTimeout(tick, 50); };
    tick();
    return () => clearTimeout(t);
  }, []);

  return (
    <div className="app" data-screen-label="Splash" style={{ justifyContent: 'center', alignItems: 'center', position: 'relative' }}>
      <StatusBar/>
      {/* Ambient wash */}
      <div style={{
        position: 'absolute', inset: 0,
        background: `radial-gradient(600px 400px at 50% 40%, var(--primary-soft), transparent 70%)`,
        pointerEvents: 'none',
      }}/>

      <div style={{ textAlign: 'center', position: 'relative' }}>
        <div style={{ animation: 'splashFloat 2.2s ease-in-out infinite' }}>
          <BrandMark size={84}/>
        </div>
        <style>{`
          @keyframes splashFloat {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-6px); }
          }
          @keyframes splashPulse {
            0%, 100% { opacity: 0.6; transform: scale(1); }
            50% { opacity: 1; transform: scale(1.3); }
          }
        `}</style>
        <div style={{ marginTop: 28, fontSize: 34, fontWeight: 700, letterSpacing: -0.8 }}>
          Renewd
        </div>
        <div style={{ marginTop: 8, fontSize: 14, color: 'var(--text-3)', fontWeight: 500, letterSpacing: 0.1 }}>
          Never miss a renewal.
        </div>
      </div>

      {/* Bottom loading */}
      <div style={{
        position: 'absolute', bottom: 56, left: '50%', transform: 'translateX(-50%)',
        display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12,
      }}>
        <div style={{ width: 120, height: 3, background: 'var(--surface-2)', borderRadius: 2, overflow: 'hidden' }}>
          <div style={{ width: `${progress * 100}%`, height: '100%', background: 'var(--primary)', borderRadius: 2, transition: 'width 0.2s' }}/>
        </div>
        <div style={{ fontSize: 11, color: 'var(--text-4)', fontWeight: 600, letterSpacing: 1.2, textTransform: 'uppercase' }}>
          Syncing your vault
        </div>
      </div>
    </div>
  );
};

// ============================================================
// 2. ONBOARDING — 3-slide carousel
// ============================================================
const ONBOARD_SLIDES = [
  {
    title: 'Every renewal, in one place.',
    body: "Insurance, subscriptions, licenses, domains. We track what's due, when, and how much.",
    art: 'stack',
  },
  {
    title: 'We read the fine print.',
    body: "Drop a PDF. AI extracts policy numbers, dates, coverage — and explains what matters.",
    art: 'ai',
  },
  {
    title: 'Reminders that actually land.',
    body: "Smart nudges 7, 3, and 1 days before. Plus one glance at what's coming this month.",
    art: 'bell',
  },
];

const OnboardingScreen = ({ onFinish }) => {
  const [i, setI] = React.useState(0);
  const slide = ONBOARD_SLIDES[i];
  const last = i === ONBOARD_SLIDES.length - 1;

  const next = () => { if (last) onFinish(); else setI(i + 1); };

  return (
    <div className="app" data-screen-label="Onboarding">
      <StatusBar/>

      {/* Skip */}
      <div style={{ position: 'absolute', top: 58, right: 20, zIndex: 5 }}>
        <button onClick={onFinish} style={{
          background: 'none', border: 0, color: 'var(--text-3)',
          fontSize: 14, fontWeight: 600, cursor: 'pointer', fontFamily: 'var(--sans)',
          padding: '6px 10px', letterSpacing: 0.1,
        }}>Skip</button>
      </div>

      {/* Art */}
      <div style={{
        flex: '1 1 auto',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        padding: '80px 32px 24px',
        position: 'relative',
      }}>
        <OnboardArt variant={slide.art}/>
      </div>

      {/* Text + dots + CTA */}
      <div style={{ padding: '0 28px 140px', textAlign: 'left' }}>
        <div style={{ display: 'flex', gap: 6, marginBottom: 20 }}>
          {ONBOARD_SLIDES.map((_, idx) => (
            <div key={idx} style={{
              height: 4, borderRadius: 2,
              flex: idx === i ? 3 : 1,
              background: idx === i ? 'var(--primary)' : 'var(--surface-2)',
              transition: 'flex 0.3s, background 0.2s',
            }}/>
          ))}
        </div>

        <div style={{ fontSize: 30, fontWeight: 700, letterSpacing: -0.5, lineHeight: 1.1, textWrap: 'balance' }}>
          {slide.title}
        </div>
        <div style={{ fontSize: 15.5, color: 'var(--text-3)', marginTop: 12, lineHeight: 1.5, fontWeight: 500 }}>
          {slide.body}
        </div>
      </div>

      {/* Bottom CTA */}
      <div style={{
        position: 'absolute', left: 24, right: 24, bottom: 48,
        display: 'flex', gap: 10,
      }}>
        <button className="btn lg" style={{ flex: 1 }} onClick={next}>
          {last ? 'Get started' : 'Continue'}
          {!last && <Icon name="chevron" size={16} color="#fff" stroke={2.4}/>}
        </button>
      </div>
    </div>
  );
};

// Onboarding illustrations — geometric, using Renewd palette
const OnboardArt = ({ variant }) => {
  if (variant === 'stack') {
    // A stack of renewal cards — Apple, Claude, Netflix, TATA
    const cards = [
      { name: 'Claude Max', sub: 'Anthropic · AI / Software', amt: '₹11,033', glyph: 'A', color: '#D97757', due: 6 },
      { name: 'Netflix', sub: 'Entertainment', amt: '₹649', glyph: 'N', color: '#E50914', due: 11 },
      { name: 'iCloud+', sub: 'Apple · Cloud', amt: '₹75', glyph: '◎', color: '#A2AAAD', due: 0 },
    ];
    return (
      <div style={{ position: 'relative', width: '100%', height: 280 }}>
        {cards.map((c, idx) => (
          <div key={c.name} className="card" style={{
            position: 'absolute',
            left: idx === 0 ? 0 : idx * 14,
            right: idx === 0 ? 0 : idx * 14,
            top: idx * 46,
            padding: 14,
            display: 'flex', alignItems: 'center', gap: 12,
            boxShadow: '0 10px 30px rgba(0,0,0,0.18)',
            transform: `scale(${1 - idx * 0.02})`,
            transformOrigin: 'top center',
            zIndex: 10 - idx,
          }}>
            <div className="logo-tile" style={{
              background: `${c.color}22`, border: `1px solid ${c.color}40`, color: c.color,
            }}>{c.glyph}</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14.5, fontWeight: 600, letterSpacing: -0.1 }}>{c.name}</div>
              <div style={{ fontSize: 11.5, color: 'var(--text-3)', marginTop: 2, fontWeight: 500 }}>{c.sub}</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ fontSize: 14, fontWeight: 700, fontVariantNumeric: 'tabular-nums' }}>{c.amt}</div>
              <div className={`due-pill ${c.due === 0 ? 'today' : c.due <= 7 ? 'soon' : 'warn'}`} style={{ marginTop: 2 }}>
                {c.due === 0 ? 'Today' : `in ${c.due}d`}
              </div>
            </div>
          </div>
        ))}
      </div>
    );
  }

  if (variant === 'ai') {
    // AI reading a document
    return (
      <div style={{ position: 'relative', width: '100%', height: 280 }}>
        {/* Document */}
        <div className="card" style={{
          position: 'absolute', left: 20, top: 10, width: 180, height: 230,
          padding: 16, boxShadow: '0 14px 36px rgba(0,0,0,0.2)',
          transform: 'rotate(-4deg)',
        }}>
          <div style={{ fontSize: 9, fontWeight: 700, color: 'var(--text-3)', letterSpacing: 1.2, textTransform: 'uppercase' }}>
            TATA AIG
          </div>
          <div style={{ fontSize: 11, fontWeight: 700, marginTop: 6, letterSpacing: -0.1 }}>
            Motor Insurance
          </div>
          {[
            ['Policy #', 'TATA-0092-14A'],
            ['Premium', '₹12,495'],
            ['Valid till', '21 Mar 2027'],
            ['IDV', '₹8.4L'],
          ].map(([k, v], idx) => (
            <div key={k} style={{ marginTop: idx === 0 ? 14 : 10 }}>
              <div style={{ fontSize: 8, fontWeight: 600, color: 'var(--text-4)', textTransform: 'uppercase', letterSpacing: 0.8 }}>{k}</div>
              <div style={{ fontSize: 11, fontWeight: 600, marginTop: 2, fontVariantNumeric: 'tabular-nums' }}>{v}</div>
            </div>
          ))}
          {/* Scan lines */}
          <div style={{
            position: 'absolute', left: 16, right: 16, top: 58, height: 2,
            background: 'var(--ai-accent)', borderRadius: 2, opacity: 0.4,
            animation: 'scanLine 2s ease-in-out infinite',
          }}/>
          <style>{`
            @keyframes scanLine {
              0% { top: 50px; opacity: 0; }
              25% { opacity: 0.6; }
              100% { top: 200px; opacity: 0; }
            }
          `}</style>
        </div>

        {/* AI chip emerging */}
        <div className="card" style={{
          position: 'absolute', right: 10, top: 58, width: 160,
          padding: 12, boxShadow: '0 14px 36px var(--ai-glow)',
          border: '1px solid var(--ai-accent)',
          background: 'var(--surface)',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8 }}>
            <Sparkle size={14}/>
            <div style={{ fontSize: 9, fontWeight: 700, color: 'var(--ai-accent)', textTransform: 'uppercase', letterSpacing: 1 }}>
              Renewd AI
            </div>
          </div>
          <div style={{ fontSize: 12, fontWeight: 600, lineHeight: 1.35, letterSpacing: -0.1 }}>
            Extracted 4 fields. Premium rose <span style={{ color: 'var(--warn)' }}>8%</span> YoY — compare in Feb?
          </div>
        </div>

        {/* Floating data points */}
        {[
          { x: '70%', y: '78%', label: '₹12,495', w: 72 },
          { x: '8%', y: '85%', label: '21 Mar 2027', w: 92 },
        ].map((p, idx) => (
          <div key={idx} style={{
            position: 'absolute', left: p.x, top: p.y, width: p.w,
            padding: '5px 9px', borderRadius: 6,
            background: 'var(--ai-soft)', border: '1px solid var(--ai-accent)',
            fontSize: 10, fontWeight: 700, color: 'var(--ai-accent)',
            textAlign: 'center', fontVariantNumeric: 'tabular-nums',
          }}>{p.label}</div>
        ))}
      </div>
    );
  }

  // 'bell'
  return (
    <div style={{ position: 'relative', width: '100%', height: 280, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <div style={{
        width: 150, height: 150, borderRadius: '50%',
        background: 'var(--primary-soft)',
        display: 'grid', placeItems: 'center',
        position: 'relative',
      }}>
        {/* Pulse rings */}
        {[1, 2].map(r => (
          <div key={r} style={{
            position: 'absolute', inset: -r * 24, borderRadius: '50%',
            border: '1.5px solid var(--primary)',
            opacity: 0.4 / r,
            animation: `pulse${r} 2.4s ease-out infinite ${r * 0.5}s`,
          }}/>
        ))}
        <style>{`
          @keyframes pulse1 { 0% { transform: scale(0.95); opacity: 0.5; } 100% { transform: scale(1.15); opacity: 0; } }
          @keyframes pulse2 { 0% { transform: scale(0.95); opacity: 0.3; } 100% { transform: scale(1.25); opacity: 0; } }
        `}</style>
        <Icon name="bell" size={60} color="var(--primary)" stroke={2}/>
      </div>

      {/* Notification card */}
      <div className="card" style={{
        position: 'absolute', right: 12, bottom: 16, width: 220,
        padding: 12,
        boxShadow: '0 14px 36px rgba(0,0,0,0.2)',
        display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--primary)', display: 'grid', placeItems: 'center' }}>
          <Icon name="bell" size={16} color="#fff"/>
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: -0.1 }}>Claude Max renews in 3 days</div>
          <div style={{ fontSize: 10, color: 'var(--text-3)', marginTop: 1, fontWeight: 500 }}>₹11,033 · Apr 24</div>
        </div>
      </div>

      {/* Small time chip */}
      <div style={{
        position: 'absolute', left: 20, top: 40,
        fontSize: 10, fontWeight: 700, letterSpacing: 1,
        color: 'var(--text-4)', textTransform: 'uppercase',
      }}>
        08:00 · Mon
      </div>
    </div>
  );
};

// ============================================================
// 3. LOGIN — phone + Google + Apple
// ============================================================
const LoginScreen = ({ onContinue, variant = 'phone' }) => {
  const [phone, setPhone] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [country, setCountry] = React.useState('+91');

  const isPhone = variant === 'phone';
  const valid = isPhone ? phone.length >= 10 : email.includes('@');

  return (
    <div className="app" data-screen-label="Login">
      <StatusBar/>

      <div style={{ padding: '80px 28px 24px', flex: 1, display: 'flex', flexDirection: 'column' }}>
        {/* Brand */}
        <BrandMark size={52}/>

        {/* Heading */}
        <div style={{ marginTop: 32, fontSize: 28, fontWeight: 700, letterSpacing: -0.5, lineHeight: 1.1, textWrap: 'balance' }}>
          Welcome back.
        </div>
        <div style={{ fontSize: 15, color: 'var(--text-3)', marginTop: 10, fontWeight: 500, lineHeight: 1.45 }}>
          Log in to keep your renewals on track.
        </div>

        {/* Form */}
        <div style={{ marginTop: 32 }}>
          <label className="form-label">{isPhone ? 'Phone number' : 'Email'}</label>
          {isPhone ? (
            <div className="field">
              <CountryPicker value={country} onChange={setCountry}/>
              <div style={{ width: 1, height: 24, background: 'var(--border)' }}/>
              <input
                type="tel"
                inputMode="numeric"
                placeholder="98765 43210"
                value={phone}
                onChange={e => setPhone(e.target.value.replace(/[^\d ]/g, '').slice(0, 11))}
              />
            </div>
          ) : (
            <div className="field">
              <Icon name="globe" size={18} color="var(--text-3)"/>
              <input
                type="email"
                placeholder="you@example.com"
                value={email}
                onChange={e => setEmail(e.target.value)}
              />
            </div>
          )}

          <button
            className="btn lg"
            style={{ width: '100%', marginTop: 14 }}
            disabled={!valid}
            onClick={() => onContinue && onContinue({ phone: country + phone, email })}
          >
            Continue
          </button>
        </div>

        {/* Divider */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '28px 0 20px' }}>
          <div style={{ flex: 1, height: 1, background: 'var(--border)' }}/>
          <div style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-3)', letterSpacing: 1.2, textTransform: 'uppercase' }}>
            or continue with
          </div>
          <div style={{ flex: 1, height: 1, background: 'var(--border)' }}/>
        </div>

        {/* Social */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <button className="btn ghost lg" style={{ width: '100%', gap: 10 }}>
            <GoogleGlyph size={18}/> Continue with Google
          </button>
          <button className="btn ghost lg" style={{ width: '100%', gap: 10, color: 'var(--text)' }}>
            <AppleGlyph size={18}/> Continue with Apple
          </button>
        </div>

        <div style={{ flex: 1 }}/>

        {/* Footer */}
        <div style={{ fontSize: 12, color: 'var(--text-3)', lineHeight: 1.5, textAlign: 'center', fontWeight: 500, marginTop: 28 }}>
          By continuing you agree to Renewd's{' '}
          <span style={{ color: 'var(--text-2)', textDecoration: 'underline', textUnderlineOffset: 3 }}>Terms</span>
          {' '}and{' '}
          <span style={{ color: 'var(--text-2)', textDecoration: 'underline', textUnderlineOffset: 3 }}>Privacy</span>.
        </div>
      </div>
    </div>
  );
};

const CountryPicker = ({ value, onChange }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontWeight: 600, cursor: 'pointer', fontVariantNumeric: 'tabular-nums' }}>
    <span style={{ fontSize: 18 }}>🇮🇳</span>
    <span style={{ fontSize: 15 }}>{value}</span>
    <Icon name="chevron" size={12} color="var(--text-3)" stroke={2.4}/>
  </div>
);

// Real Google "G" glyph (original recreation, Material colors)
const GoogleGlyph = ({ size = 18 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24">
    <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
    <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
    <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
    <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
  </svg>
);

const AppleGlyph = ({ size = 18 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor">
    <path d="M17.05 12.04c-.03-2.86 2.33-4.24 2.44-4.31-1.33-1.94-3.4-2.21-4.13-2.23-1.76-.18-3.43 1.04-4.32 1.04-.9 0-2.27-1.01-3.73-.98C5.4 5.59 3.7 6.68 2.77 8.35c-1.97 3.42-.5 8.46 1.41 11.24.94 1.35 2.04 2.87 3.5 2.82 1.41-.06 1.94-.91 3.64-.91s2.18.91 3.67.88c1.52-.03 2.47-1.38 3.39-2.74 1.08-1.57 1.52-3.1 1.54-3.18-.03-.01-2.94-1.13-2.97-4.48-.03-2.8 2.29-4.14 2.39-4.21-1.31-1.93-3.35-2.14-4.07-2.19zm-2.53-4.39c.77-.94 1.3-2.24 1.15-3.54-1.12.05-2.48.74-3.28 1.68-.72.83-1.35 2.16-1.18 3.43 1.25.1 2.53-.63 3.31-1.57z"/>
  </svg>
);

// ============================================================
// 4. OTP VERIFY
// ============================================================
const OtpScreen = ({ phone = '+91 98765 43210', onVerify, onBack }) => {
  const [digits, setDigits] = React.useState(['', '', '', '', '', '']);
  const [seconds, setSeconds] = React.useState(42);
  const [err, setErr] = React.useState(false);
  const refs = React.useRef([]);

  React.useEffect(() => {
    const t = seconds > 0 && setTimeout(() => setSeconds(s => s - 1), 1000);
    return () => clearTimeout(t);
  }, [seconds]);

  const set = (i, v) => {
    const clean = v.replace(/[^\d]/g, '').slice(-1);
    setErr(false);
    setDigits(d => {
      const next = [...d];
      next[i] = clean;
      return next;
    });
    if (clean && i < 5) refs.current[i + 1]?.focus();
  };

  const onKey = (i, e) => {
    if (e.key === 'Backspace' && !digits[i] && i > 0) refs.current[i - 1]?.focus();
  };

  const onPaste = (e) => {
    const text = e.clipboardData.getData('text').replace(/[^\d]/g, '').slice(0, 6);
    if (text.length) {
      setDigits(text.split('').concat(Array(6 - text.length).fill('')));
      refs.current[Math.min(text.length, 5)]?.focus();
      e.preventDefault();
    }
  };

  const full = digits.join('');
  const complete = full.length === 6;

  const verify = () => {
    if (full === '121212' || full === '000000') {
      setErr(true);
      return;
    }
    onVerify && onVerify(full);
  };

  React.useEffect(() => {
    if (complete) {
      const t = setTimeout(verify, 250);
      return () => clearTimeout(t);
    }
  }, [complete, full]);

  return (
    <div className="app" data-screen-label="OTP Verify">
      <StatusBar/>
      <div style={{ position: 'absolute', top: 58, left: 20, zIndex: 5 }}>
        <div className="icon-btn" onClick={onBack}><Icon name="back" size={18}/></div>
      </div>

      <div style={{ padding: '120px 28px 24px', flex: 1, display: 'flex', flexDirection: 'column' }}>
        <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.5, lineHeight: 1.15, textWrap: 'balance' }}>
          Enter the 6-digit code
        </div>
        <div style={{ fontSize: 15, color: 'var(--text-3)', marginTop: 10, fontWeight: 500, lineHeight: 1.45 }}>
          Sent to <span style={{ color: 'var(--text)', fontWeight: 600, fontVariantNumeric: 'tabular-nums' }}>{phone}</span>.{' '}
          <span style={{ color: 'var(--primary)', fontWeight: 600, cursor: 'pointer' }} onClick={onBack}>Change number</span>
        </div>

        {/* OTP boxes */}
        <div style={{ display: 'flex', gap: 10, marginTop: 36, justifyContent: 'space-between' }}>
          {digits.map((d, i) => (
            <input
              key={i}
              ref={el => refs.current[i] = el}
              value={d}
              onChange={e => set(i, e.target.value)}
              onKeyDown={e => onKey(i, e)}
              onPaste={onPaste}
              inputMode="numeric"
              maxLength={1}
              style={{
                width: 48, height: 56,
                borderRadius: 'var(--r-md)',
                border: `1.5px solid ${err ? 'var(--danger)' : d ? 'var(--primary)' : 'var(--border)'}`,
                background: err ? 'var(--danger-soft)' : d ? 'var(--surface)' : 'var(--surface-2)',
                color: err ? 'var(--danger)' : 'var(--text)',
                fontSize: 24, fontWeight: 700,
                textAlign: 'center',
                fontFamily: 'var(--sans)',
                fontVariantNumeric: 'tabular-nums',
                outline: 'none',
                transition: 'border-color 0.15s, background 0.15s',
                letterSpacing: 0,
              }}
            />
          ))}
        </div>

        {err && (
          <div style={{
            marginTop: 14, padding: '10px 14px',
            background: 'var(--danger-soft)', borderRadius: 'var(--r-sm)',
            fontSize: 13, fontWeight: 500, color: 'var(--danger)',
            display: 'flex', alignItems: 'center', gap: 8,
          }}>
            <Icon name="close" size={14} stroke={2.4}/> That code didn't match. Try again.
          </div>
        )}

        {/* Timer / resend */}
        <div style={{ marginTop: 24, textAlign: 'center' }}>
          {seconds > 0 ? (
            <div style={{ fontSize: 13, color: 'var(--text-3)', fontWeight: 500 }}>
              Resend code in <span style={{ color: 'var(--text-2)', fontWeight: 600, fontVariantNumeric: 'tabular-nums' }}>{seconds}s</span>
            </div>
          ) : (
            <button onClick={() => setSeconds(42)} style={{
              background: 'none', border: 0, color: 'var(--primary)',
              fontSize: 13, fontWeight: 600, cursor: 'pointer', fontFamily: 'var(--sans)',
              display: 'inline-flex', alignItems: 'center', gap: 6,
            }}>
              <Icon name="refresh" size={13}/> Resend code
            </button>
          )}
        </div>

        <div style={{ flex: 1 }}/>

        {/* Verify button — only if timeout / manual */}
        <button
          className="btn lg"
          style={{ width: '100%', marginTop: 20 }}
          disabled={!complete}
          onClick={verify}
        >
          Verify
        </button>

        <div style={{ fontSize: 12, color: 'var(--text-4)', textAlign: 'center', marginTop: 18, fontWeight: 500 }}>
          Didn't get a code? Check spam, or <span style={{ color: 'var(--text-2)', fontWeight: 600, cursor: 'pointer' }}>get help</span>
        </div>
      </div>
    </div>
  );
};

// ============================================================
// 5. COMPLETE PROFILE
// ============================================================
const COUNTRIES = [
  { code: 'IN', flag: '🇮🇳', name: 'India', curr: '₹ INR' },
  { code: 'US', flag: '🇺🇸', name: 'United States', curr: '$ USD' },
  { code: 'GB', flag: '🇬🇧', name: 'United Kingdom', curr: '£ GBP' },
  { code: 'AE', flag: '🇦🇪', name: 'UAE', curr: 'د.إ AED' },
  { code: 'SG', flag: '🇸🇬', name: 'Singapore', curr: '$ SGD' },
];

const CompleteProfileScreen = ({ onFinish }) => {
  const [name, setName] = React.useState('');
  const [country, setCountry] = React.useState(COUNTRIES[0]);
  const [notif, setNotif] = React.useState(true);
  const [pickerOpen, setPickerOpen] = React.useState(false);

  const valid = name.trim().length >= 2;

  return (
    <div className="app" data-screen-label="Complete Profile">
      <StatusBar/>
      <div className="app-scroll" style={{ padding: '80px 28px 140px' }}>
        {/* Step indicator */}
        <div style={{ display: 'flex', gap: 4, marginBottom: 28 }}>
          {[0, 1, 2].map(n => (
            <div key={n} style={{
              flex: 1, height: 4, borderRadius: 2,
              background: n < 2 ? 'var(--primary)' : 'var(--surface-2)',
            }}/>
          ))}
        </div>

        <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.5, lineHeight: 1.1, textWrap: 'balance' }}>
          Let's set up your vault.
        </div>
        <div style={{ fontSize: 15, color: 'var(--text-3)', marginTop: 10, fontWeight: 500, lineHeight: 1.45 }}>
          Just the basics. You can change these anytime in settings.
        </div>

        {/* Avatar */}
        <div style={{ display: 'flex', justifyContent: 'center', marginTop: 32 }}>
          <div style={{ position: 'relative' }}>
            <div style={{
              width: 96, height: 96, borderRadius: '50%',
              background: 'var(--surface-2)', border: '1px dashed var(--border)',
              display: 'grid', placeItems: 'center',
              color: 'var(--text-3)',
            }}>
              {name ? (
                <div style={{ fontSize: 36, fontWeight: 700, color: 'var(--primary)', letterSpacing: -1 }}>
                  {name.trim()[0].toUpperCase()}
                </div>
              ) : (
                <Icon name="plus" size={28} stroke={2} color="var(--text-3)"/>
              )}
            </div>
            <div style={{
              position: 'absolute', bottom: -2, right: -2,
              width: 32, height: 32, borderRadius: '50%',
              background: 'var(--primary)', color: '#fff',
              display: 'grid', placeItems: 'center',
              border: '3px solid var(--bg)', cursor: 'pointer',
              boxShadow: '0 4px 12px var(--primary-glow)',
            }}>
              <Icon name="upload" size={13} stroke={2.6}/>
            </div>
          </div>
        </div>

        {/* Name */}
        <div style={{ marginTop: 32 }}>
          <label className="form-label">Your name</label>
          <div className="field">
            <input
              placeholder="e.g. Rohan Sharma"
              value={name}
              onChange={e => setName(e.target.value)}
              autoFocus
            />
          </div>
        </div>

        {/* Country */}
        <div style={{ marginTop: 18 }}>
          <label className="form-label">Country & currency</label>
          <button
            onClick={() => setPickerOpen(v => !v)}
            style={{
              width: '100%', height: 50,
              background: 'var(--surface-2)', border: '1.5px solid transparent',
              borderRadius: 'var(--r-md)', padding: '0 16px',
              display: 'flex', alignItems: 'center', gap: 10,
              color: 'var(--text)', fontSize: 15, fontWeight: 500,
              cursor: 'pointer', fontFamily: 'var(--sans)',
              letterSpacing: -0.05,
            }}
          >
            <span style={{ fontSize: 20 }}>{country.flag}</span>
            <span style={{ flex: 1, textAlign: 'left' }}>{country.name}</span>
            <span style={{ color: 'var(--text-3)', fontWeight: 600, fontVariantNumeric: 'tabular-nums' }}>{country.curr}</span>
            <Icon name="chevron" size={13} color="var(--text-3)" stroke={2.4}/>
          </button>
          {pickerOpen && (
            <div className="card" style={{ marginTop: 8, overflow: 'hidden' }}>
              {COUNTRIES.map((c, i) => (
                <div
                  key={c.code}
                  onClick={() => { setCountry(c); setPickerOpen(false); }}
                  style={{
                    padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 12,
                    borderBottom: i < COUNTRIES.length - 1 ? '1px solid var(--border)' : 0,
                    cursor: 'pointer', fontSize: 14, fontWeight: 500,
                    background: c.code === country.code ? 'var(--primary-soft)' : 'transparent',
                  }}
                >
                  <span style={{ fontSize: 20 }}>{c.flag}</span>
                  <span style={{ flex: 1 }}>{c.name}</span>
                  <span style={{ fontSize: 12, color: 'var(--text-3)', fontWeight: 600, fontVariantNumeric: 'tabular-nums' }}>{c.curr}</span>
                  {c.code === country.code && <Icon name="check" size={15} color="var(--primary)" stroke={2.4}/>}
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Notifications toggle */}
        <div
          className="card"
          style={{ marginTop: 20, padding: 16, display: 'flex', alignItems: 'center', gap: 14, cursor: 'pointer' }}
          onClick={() => setNotif(v => !v)}
        >
          <div style={{
            width: 40, height: 40, borderRadius: 'var(--r-md)',
            background: 'var(--primary-soft)', color: 'var(--primary)',
            display: 'grid', placeItems: 'center',
          }}>
            <Icon name="bell" size={18}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14.5, fontWeight: 600, letterSpacing: -0.1 }}>Renewal reminders</div>
            <div style={{ fontSize: 12, color: 'var(--text-3)', marginTop: 2, fontWeight: 500, lineHeight: 1.4 }}>
              Smart nudges 7, 3, and 1 day before renewals.
            </div>
          </div>
          <div className={`toggle ${notif ? 'on' : ''}`}/>
        </div>

        {/* Privacy reassurance */}
        <div style={{
          marginTop: 20, padding: '12px 14px',
          background: 'var(--success-soft)', borderRadius: 'var(--r-sm)',
          display: 'flex', alignItems: 'flex-start', gap: 10,
        }}>
          <Icon name="shield" size={16} color="var(--success)"/>
          <div style={{ fontSize: 12.5, color: 'var(--text-2)', fontWeight: 500, lineHeight: 1.45 }}>
            <span style={{ color: 'var(--success)', fontWeight: 700 }}>End-to-end encrypted.</span>{' '}
            We never see your documents — only you hold the key.
          </div>
        </div>
      </div>

      {/* Sticky CTA */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        padding: '16px 24px 32px',
        background: `linear-gradient(180deg, transparent, var(--bg) 40%)`,
      }}>
        <button
          className="btn lg"
          style={{ width: '100%' }}
          disabled={!valid}
          onClick={() => onFinish && onFinish({ name, country, notif })}
        >
          Enter Renewd
          <Icon name="chevron" size={16} color="#fff" stroke={2.4}/>
        </button>
      </div>
    </div>
  );
};

Object.assign(window, {
  BrandMark, SplashScreen, OnboardingScreen, LoginScreen, OtpScreen, CompleteProfileScreen,
});
