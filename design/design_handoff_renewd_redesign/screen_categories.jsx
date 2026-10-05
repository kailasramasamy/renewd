// Categories screen
const CategoriesScreen = ({ onTab, onOpenRenewal }) => {
  const [cat, setCat] = React.useState('all');
  const [search, setSearch] = React.useState('');
  const [sort, setSort] = React.useState('due'); // due | cost | name

  const filtered = RENEWALS
    .filter(r => {
      if (cat !== 'all' && !r.category.toLowerCase().includes(cat)) return false;
      if (search && !r.name.toLowerCase().includes(search.toLowerCase())) return false;
      return true;
    })
    .sort((a, b) => {
      if (sort === 'due') return a.due - b.due;
      if (sort === 'cost') return b.amount - a.amount;
      return a.name.localeCompare(b.name);
    });

  const total = filtered.reduce((s, r) => s + r.amount, 0);

  // Group by urgency
  const groups = [
    { label: 'This week', filter: r => r.due <= 7 },
    { label: 'This month', filter: r => r.due > 7 && r.due <= 30 },
    { label: 'Later', filter: r => r.due > 30 },
  ].map(g => ({ ...g, items: filtered.filter(g.filter) })).filter(g => g.items.length);

  return (
    <div className="app" data-screen-label="Categories">
      <StatusBar/>
      <div className="app-scroll">
        <div className="screen-header">
          <div>
            <div className="screen-title">Renewals</div>
            <div className="screen-subtitle">
              <span className="mono">{filtered.length}</span> active · <span className="mono" style={{ color: 'var(--text-2)' }}>₹{total.toLocaleString('en-IN')}</span> /yr
            </div>
          </div>
          <div className="icon-btn"><Icon name="filter" size={17}/></div>
        </div>

        {/* Search */}
        <div className="search" style={{ marginBottom: 14 }}>
          <Icon name="search" size={17} color="var(--text-3)"/>
          <input placeholder="Search renewals…" value={search} onChange={e => setSearch(e.target.value)}/>
        </div>

        {/* Category chips */}
        <div className="chip-row">
          {CATEGORIES.map(c => (
            <div key={c.id}
              className={`chip ${cat === c.id ? 'active' : ''}`}
              onClick={() => setCat(c.id)}
            >
              {c.icon && <Icon name={c.icon} size={13}/>}
              {c.label}
              <span className="count">{c.count}</span>
            </div>
          ))}
        </div>

        {/* Sort row */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '6px 4px 10px' }}>
          <div style={{ fontSize: 11, color: 'var(--text-3)', textTransform: 'uppercase', letterSpacing: '0.08em', fontWeight: 600 }}>
            Sort
          </div>
          <div style={{ display: 'flex', gap: 4, padding: 3, background: 'var(--surface)', borderRadius: 9, border: '1px solid var(--border)' }}>
            {[['due', 'Due'], ['cost', 'Cost'], ['name', 'A–Z']].map(([k, l]) => (
              <button key={k} onClick={() => setSort(k)} style={{
                padding: '5px 10px', fontSize: 11.5, fontWeight: 500, border: 0, cursor: 'pointer',
                background: sort === k ? 'var(--surface-2)' : 'transparent',
                color: sort === k ? 'var(--text)' : 'var(--text-3)',
                borderRadius: 6, fontFamily: 'var(--sans)',
                boxShadow: sort === k ? '0 0 0 1px var(--border-strong)' : 'none',
              }}>{l}</button>
            ))}
          </div>
        </div>

        {/* Grouped list */}
        {sort === 'due' ? (
          groups.map(g => (
            <div key={g.label}>
              <div className="sec-label">{g.label} <span className="count">· {g.items.length}</span></div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                {g.items.map(r => <RenewalRow key={r.id} renewal={r} onOpen={onOpenRenewal}/>)}
              </div>
            </div>
          ))
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginTop: 8 }}>
            {filtered.map(r => <RenewalRow key={r.id} renewal={r} onOpen={onOpenRenewal}/>)}
          </div>
        )}
        <div style={{ height: 20 }}/>
      </div>
      <TabBar active="categories" onTab={onTab}/>
    </div>
  );
};

const RenewalRow = ({ renewal: r, onOpen }) => {
  // amount in context
  const perMonth = r.cycle === 'yr' ? r.amount / 12 : r.cycle === '2yr' ? r.amount / 24 : r.amount;
  return (
    <div className="renewal-row" onClick={() => onOpen && onOpen(r)} style={{
      position: 'relative', paddingLeft: 16,
    }}>
      {/* Urgency bar */}
      <div style={{
        position: 'absolute', left: 0, top: 10, bottom: 10, width: 3,
        borderRadius: 3,
        background: r.due === 0 ? 'var(--danger)' :
                    r.due <= 7 ? 'var(--warn)' :
                    r.due <= 30 ? 'var(--amber)' :
                    r.color,
      }}/>
      <LogoTile renewal={r}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className="name" style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{r.name}</div>
        <div className="sub">{r.vendor} · {r.category}</div>
      </div>
      <div className="amt">
        <div className="money mono">₹{r.amount.toLocaleString('en-IN')}</div>
        <DuePill days={r.due}/>
      </div>
    </div>
  );
};

window.CategoriesScreen = CategoriesScreen;
window.RenewalRow = RenewalRow;
