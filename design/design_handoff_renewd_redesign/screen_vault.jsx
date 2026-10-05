// Vault screen
const VaultScreen = ({ onTab }) => {
  const [filter, setFilter] = React.useState('all');
  const [search, setSearch] = React.useState('');
  const [uploading, setUploading] = React.useState(false);

  const filtered = DOCUMENTS.filter(d => {
    if (search && !d.name.toLowerCase().includes(search.toLowerCase())) return false;
    if (filter === 'byRenewal' && !d.linked) return false;
    if (filter === 'unlinked' && d.linked) return false;
    return true;
  });

  const handleUpload = () => {
    setUploading(true);
    setTimeout(() => setUploading(false), 2200);
  };

  return (
    <div className="app" data-screen-label="Vault">
      <StatusBar/>
      <div className="app-scroll">
        <div className="screen-header">
          <div>
            <div className="screen-title">Vault</div>
            <div className="screen-subtitle">{DOCUMENTS.length} documents · 3.3 MB</div>
          </div>
          <div className="icon-btn"><Icon name="refresh" size={17}/></div>
        </div>

        {/* Security banner — more refined */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          padding: '10px 12px', marginBottom: 14,
          border: '1px solid transparent',
          background: 'var(--success-soft)',
          borderRadius: 12,
        }}>
          <Icon name="lock" size={15} color="var(--success)"/>
          <div style={{ flex: 1, fontSize: 12, color: 'var(--text-2)', fontWeight: 500 }}>
            <span style={{ color: 'var(--success)', fontWeight: 700, letterSpacing: 0.3 }}>AES-256</span>
            <span style={{ margin: '0 6px', color: 'var(--text-4)' }}>·</span>
            end-to-end encrypted
          </div>
          <Icon name="chevron" size={13} color="var(--text-3)"/>
        </div>

        {/* Search */}
        <div className="search" style={{ marginBottom: 12 }}>
          <Icon name="search" size={17} color="var(--text-3)"/>
          <input placeholder="Search documents…" value={search} onChange={e => setSearch(e.target.value)}/>
          <Icon name="sparkle" size={15} color="var(--ai-accent)"/>
        </div>

        {/* Filter chips */}
        <div className="chip-row">
          <div className={`chip ${filter === 'all' ? 'active' : ''}`} onClick={() => setFilter('all')}>
            All <span className="count">{DOCUMENTS.length}</span>
          </div>
          <div className={`chip ${filter === 'byRenewal' ? 'active' : ''}`} onClick={() => setFilter('byRenewal')}>
            <Icon name="link" size={13}/> Linked <span className="count">{DOCUMENTS.filter(d => d.linked).length}</span>
          </div>
          <div className={`chip ${filter === 'unlinked' ? 'active' : ''}`} onClick={() => setFilter('unlinked')}>
            Unlinked <span className="count">{DOCUMENTS.filter(d => !d.linked).length}</span>
          </div>
          <div className="chip">
            <Icon name="sparkle" size={13} color="var(--ai-accent)"/> AI-analyzed
          </div>
        </div>

        {/* Uploading row */}
        {uploading && (
          <div className="card shimmer" style={{ padding: 12, marginBottom: 10, display: 'flex', alignItems: 'center', gap: 12 }}>
            <div className="doc-icon"><Icon name="upload" size={18}/></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13.5, fontWeight: 500 }}>Uploading…</div>
              <div className="doc-meta">Encrypting · AI is reading this</div>
            </div>
          </div>
        )}

        {/* Documents list */}
        <div className="card" style={{ overflow: 'hidden' }}>
          {filtered.map((d, i) => (
            <DocRow key={d.id} doc={d} isLast={i === filtered.length - 1}/>
          ))}
          {filtered.length === 0 && (
            <div style={{ padding: 40, textAlign: 'center', color: 'var(--text-3)', fontSize: 13 }}>
              No documents match.
            </div>
          )}
        </div>

        <div style={{ height: 20 }}/>
      </div>

      {/* FAB */}
      <button onClick={handleUpload} style={{
        position: 'absolute', bottom: 96, right: 18, zIndex: 25,
        width: 52, height: 52, borderRadius: 17, border: 0, cursor: 'pointer',
        background: 'var(--ai-accent)', color: '#fff',
        display: 'grid', placeItems: 'center',
        boxShadow: '0 14px 30px var(--ai-glow)',
      }}>
        <Icon name="plus" size={22} stroke={2.2}/>
      </button>

      <TabBar active="vault" onTab={onTab}/>
    </div>
  );
};

const DocRow = ({ doc, isLast }) => {
  const linkedRenewal = doc.linked && RENEWALS.find(r => r.id === doc.linked);
  return (
    <div className="doc-row" style={{ borderBottom: isLast ? 0 : '1px solid var(--border)' }}>
      <div className="doc-icon" style={{
        background: linkedRenewal
          ? `linear-gradient(135deg, ${linkedRenewal.color}22, ${linkedRenewal.color}0a)`
          : 'var(--surface-2)',
        borderColor: linkedRenewal ? `${linkedRenewal.color}30` : 'var(--border)',
      }}>
        <Icon name="file" size={18} color={linkedRenewal ? linkedRenewal.color : 'var(--text-2)'}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <div className="doc-name">{doc.name}</div>
        </div>
        <div className="doc-meta">
          <span>{doc.size}</span>
          <span style={{ color: 'var(--text-4)' }}>·</span>
          <span>{doc.added}</span>
          {doc.analyzed && (
            <span className="ai-tag" style={{ marginLeft: 4 }}>
              <Sparkle size={9}/> AI
            </span>
          )}
        </div>
        {linkedRenewal && (
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 5, marginTop: 6,
            fontSize: 10.5, padding: '3px 8px', borderRadius: 6,
            background: `${linkedRenewal.color}18`,
            border: `1px solid ${linkedRenewal.color}30`,
            color: linkedRenewal.color, fontWeight: 600,
          }}>
            <Icon name="link" size={10}/> {linkedRenewal.name}
          </div>
        )}
      </div>
      <Icon name="chevron" size={14} color="var(--text-3)"/>
    </div>
  );
};

window.VaultScreen = VaultScreen;
