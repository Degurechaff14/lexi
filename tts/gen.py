import asyncio, json, os, edge_tts
cfg = json.load(open('tts/lines.json', encoding='utf-8'))
os.makedirs('voces', exist_ok=True)
import traceback
async def main():
    avail = {v['ShortName'] for v in await edge_tts.list_voices()}
    open('voces/disponibles.txt', 'w').write('\n'.join(sorted(x for x in avail if x.startswith('es-'))))
    used = {}
    for lid, who, text in cfg['lines']:
        v = cfg['voices'][who]
        name = v['voice'] if v['voice'] in avail else v['fallback']
        used[who] = name
        await edge_tts.Communicate(text, name, rate=v['rate'], pitch=v['pitch']).save(f'voces/{lid}.mp3')
        print(lid, who, name)
    json.dump(used, open('voces/usadas.json', 'w'))
try:
    asyncio.run(main())
except Exception:
    traceback.print_exc()
    raise
