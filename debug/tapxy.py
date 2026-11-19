import json, sys
raw = open(sys.argv[2]).read().strip()
items = json.loads(raw) if raw.startswith('[') else [json.loads(l) for l in raw.splitlines() if l.strip().startswith('{')]
labels = [(e.get('AXLabel') or '') for e in items]
sys.stderr.write('AX labels: ' + ' | '.join(l for l in labels if l)[:600] + '\n')
m = [e for e in items if (e.get('AXLabel') or '').strip().lower() == sys.argv[1].lower()]
f = m[0]['frame'] if m else None
print('%d %d' % (f['x'] + f['width'] / 2, f['y'] + f['height'] / 2) if f else '78 228')
