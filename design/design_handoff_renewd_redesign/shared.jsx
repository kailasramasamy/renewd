// Shared small components: icons, logo tile, tab bar, sparkle

const Icon = ({ name, size = 20, color = 'currentColor', stroke = 1.75 }) => {
  const p = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none', stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'home': return <svg {...p}><path d="M3 12L12 4l9 8"/><path d="M5 10v10h14V10"/></svg>;
    case 'layers': return <svg {...p}><path d="M12 3l9 5-9 5-9-5 9-5z"/><path d="M3 13l9 5 9-5"/><path d="M3 18l9 5 9-5"/></svg>;
    case 'file': return <svg {...p}><path d="M14 3H7a2 2 0 00-2 2v14a2 2 0 002 2h10a2 2 0 002-2V8l-5-5z"/><path d="M14 3v5h5"/></svg>;
    case 'sparkle': return <svg {...p}><path d="M12 3l1.8 4.8L18 10l-4.2 2.2L12 17l-1.8-4.8L6 10l4.2-2.2L12 3z"/><path d="M19 15l.8 2L22 18l-2.2 1L19 21l-.8-2L16 18l2.2-1L19 15z"/></svg>;
    case 'search': return <svg {...p}><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></svg>;
    case 'back': return <svg {...p}><path d="M15 5l-7 7 7 7"/></svg>;
    case 'more': return <svg {...p}><circle cx="5" cy="12" r="1.3" fill={color} stroke="none"/><circle cx="12" cy="12" r="1.3" fill={color} stroke="none"/><circle cx="19" cy="12" r="1.3" fill={color} stroke="none"/></svg>;
    case 'close': return <svg {...p}><path d="M6 6l12 12M18 6L6 18"/></svg>;
    case 'send': return <svg {...p}><path d="M22 2L11 13"/><path d="M22 2l-7 20-4-9-9-4 20-7z"/></svg>;
    case 'plus': return <svg {...p}><path d="M12 5v14M5 12h14"/></svg>;
    case 'upload': return <svg {...p}><path d="M12 4v12"/><path d="M7 9l5-5 5 5"/><path d="M5 20h14"/></svg>;
    case 'filter': return <svg {...p}><path d="M3 5h18M6 12h12M10 19h4"/></svg>;
    case 'shield': return <svg {...p}><path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6l8-3z"/></svg>;
    case 'refresh': return <svg {...p}><path d="M3 12a9 9 0 0115-6.7L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 01-15 6.7L3 16"/><path d="M3 21v-5h5"/></svg>;
    case 'building': return <svg {...p}><rect x="4" y="3" width="16" height="18" rx="1"/><path d="M8 7h2M8 11h2M8 15h2M14 7h2M14 11h2M14 15h2"/></svg>;
    case 'crown': return <svg {...p}><path d="M3 8l4 3 5-6 5 6 4-3v10H3V8z"/></svg>;
    case 'globe': return <svg {...p}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.5 3 4 6 4 9s-1.5 6-4 9c-2.5-3-4-6-4-9s1.5-6 4-9z"/></svg>;
    case 'chevron': return <svg {...p}><path d="M9 5l7 7-7 7"/></svg>;
    case 'check': return <svg {...p}><path d="M5 12l5 5 10-11"/></svg>;
    case 'lock': return <svg {...p}><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 018 0v4"/></svg>;
    case 'dots': return <svg {...p}><circle cx="12" cy="5" r="1.2" fill={color} stroke="none"/><circle cx="12" cy="12" r="1.2" fill={color} stroke="none"/><circle cx="12" cy="19" r="1.2" fill={color} stroke="none"/></svg>;
    case 'bell': return <svg {...p}><path d="M18 15V10a6 6 0 10-12 0v5l-2 3h16l-2-3z"/><path d="M10 20a2 2 0 004 0"/></svg>;
    case 'calendar': return <svg {...p}><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 9h18M8 3v4M16 3v4"/></svg>;
    case 'link': return <svg {...p}><path d="M10 14a3.5 3.5 0 005 0l3-3a3.5 3.5 0 00-5-5l-1 1"/><path d="M14 10a3.5 3.5 0 00-5 0l-3 3a3.5 3.5 0 005 5l1-1"/></svg>;
    case 'copy': return <svg {...p}><rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a2 2 0 012-2h10"/></svg>;
    case 'trend': return <svg {...p}><path d="M3 17l6-6 4 4 8-8"/><path d="M14 7h7v7"/></svg>;
    case 'snooze': return <svg {...p}><circle cx="12" cy="13" r="8"/><path d="M12 9v4l3 2M8 2l3 3M16 2l-3 3"/></svg>;
    default: return null;
  }
};

const Sparkle = ({ size = 14 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" className="spark" style={{ color: 'var(--ai-accent)' }}>
    <path d="M12 2l2.2 6.2L20 10.2l-5.8 2L12 18.4l-2.2-6.2L4 10.2l5.8-2L12 2z"/>
    <path d="M19 15l.9 2.3L22 18l-2.1.7L19 21l-.9-2.3L16 18l2.1-.7L19 15z"/>
  </svg>
);

const LogoTile = ({ renewal, size = 'md' }) => {
  const r = renewal;
  // Brand glyph per vendor (original, non-copyright)
  const glyph = () => {
    switch (r.logo) {
      case 'apple': return <svg viewBox="0 0 24 24" width="60%" height="60%" fill="#fff"><circle cx="12" cy="12" r="6"/></svg>;
      case 'A': return 'C';
      case 'G': return '◎';
      case 'a': return 'a';
      case 'T': return 'T';
      case 'V': return 'v';
      case 'F': return 'F';
      case 'N': return 'N';
      case 'S': return '♪';
      case 'C': return 'C';
      default: return r.name[0];
    }
  };
  const bg = r.color + '22'; // transparent-ish
  return (
    <div className={`logo-tile ${size}`} style={{
      background: `linear-gradient(135deg, ${r.color}26, ${r.color}12)`,
      border: `1px solid ${r.color}40`,
      color: r.color,
    }}>
      {glyph()}
    </div>
  );
};

const DuePill = ({ days }) => {
  let cls = 'ok', label = '';
  if (days === 0) { cls = 'today'; label = 'Today'; }
  else if (days <= 7) { cls = 'soon'; label = `in ${days}d`; }
  else if (days <= 30) { cls = 'warn'; label = `in ${days}d`; }
  else { cls = 'ok'; label = `in ${days}d`; }
  return <span className={`due-pill ${cls}`}>{label}</span>;
};

const TabBar = ({ active, onTab }) => {
  const tabs = [
    { id: 'home', label: 'Home', icon: 'home' },
    { id: 'categories', label: 'Categories', icon: 'layers' },
    { id: 'vault', label: 'Vault', icon: 'file' },
    { id: 'chat', label: 'AI Chat', icon: 'sparkle' },
  ];
  return (
    <div className="tabbar">
      {tabs.map(t => (
        <div key={t.id} className={`tab ${active === t.id ? 'active' : ''}`} onClick={() => onTab(t.id)}>
          <div className="tab-icon-wrap"><Icon name={t.icon} size={18} stroke={active === t.id ? 2 : 1.75}/></div>
          <span>{t.label}</span>
        </div>
      ))}
    </div>
  );
};

const StatusBar = () => (
  <div style={{
    position: 'absolute', top: 0, left: 0, right: 0, height: 54,
    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
    padding: '18px 28px 0', zIndex: 40, pointerEvents: 'none', color: 'var(--text)',
    fontFamily: '-apple-system, system-ui', fontSize: 15, fontWeight: 600,
  }}>
    <span>11:54</span>
    <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
      <svg width="16" height="10" viewBox="0 0 16 10" fill="currentColor"><rect x="0" y="6" width="2.5" height="4" rx="0.6"/><rect x="4" y="4" width="2.5" height="6" rx="0.6"/><rect x="8" y="2" width="2.5" height="8" rx="0.6"/><rect x="12" y="0" width="2.5" height="10" rx="0.6"/></svg>
      <svg width="14" height="10" viewBox="0 0 14 10" fill="currentColor"><path d="M7 3a7 7 0 015 2l1-1a8.5 8.5 0 00-12 0l1 1a7 7 0 015-2z"/><circle cx="7" cy="8.5" r="1.3"/></svg>
      <div style={{ display: 'flex', alignItems: 'center', gap: 2 }}>
        <div style={{ width: 22, height: 10, border: '1.2px solid currentColor', borderRadius: 3, padding: 1, display: 'flex', opacity: 0.55 }}>
          <div style={{ flex: 1, background: 'currentColor', borderRadius: 1.2 }}/>
        </div>
        <span style={{ fontSize: 10, opacity: 0.9, marginLeft: 2 }}>80</span>
      </div>
    </div>
  </div>
);

Object.assign(window, { Icon, Sparkle, LogoTile, DuePill, TabBar, StatusBar });
