from pathlib import Path
import hashlib,json,sys
root=Path(__file__).resolve().parent
value={'sources':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((root/'src').rglob('*.java'))},'dex_sha256':hashlib.sha256((root/'classes.dex').read_bytes()).hexdigest(),'compile_api':35,'min_api':24}
meta=root/'artifact.json'
if '--write' in sys.argv:meta.write_text(json.dumps(value,indent=2)+'\n')
else:
 assert json.loads(meta.read_text())==value,'Native source changed: run native/build_native.sh before exporting'
 print('Native source/dex identity verified')
