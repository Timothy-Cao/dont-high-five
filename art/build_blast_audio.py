"""Original, deterministic 48 kHz blast pop layers; no external samples."""
from pathlib import Path
import wave,json
import numpy as np
root=Path(__file__).resolve().parents[1];out=root/'assets/audio/sfx';rate=48000
rng=np.random.default_rng(5218);report=[]
for i in range(4):
 t=np.arange(int(rate*.46))/rate
 # Soft air pop + falling rubber resonance + a short bright transient.
 noise=rng.normal(0,1,len(t));hz=np.fft.rfftfreq(len(t),1/rate)
 noise=np.fft.irfft(np.fft.rfft(noise)*np.exp(-(hz/3500)**2)*(1-np.exp(-(hz/100)**2)),n=len(t))
 phase=2*np.pi*((68+i*3)*t+115*.045*(1-np.exp(-t/.045)))
 s=.55*np.sin(phase)*np.exp(-t/0.095)+.43*noise*np.exp(-t/.065)+.06*np.sin(2*np.pi*930*t)*np.exp(-t/.016)
 s*=np.minimum(t/.002,1);s-=s.mean();s[-480:]*=np.linspace(1,0,480)
 s*=10**(-8/20)/np.max(np.abs(s))
 with wave.open(str(out/f'blast_{i}.wav'),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes((s*32767).astype('<i2').tobytes())
 report.append({'file':f'blast_{i}.wav','peak_db':-8,'seconds':.46,'original_synthesis':True})
(root/'art/blast-audio-report.json').write_text(json.dumps(report,indent=2))
manifest_path=out/'manifest.json';manifest=json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
for item in report:
 with wave.open(str(out/item['file']),'rb') as f: samples=np.frombuffer(f.readframes(f.getnframes()),dtype='<i2')/32768.0
 manifest[Path(item['file']).stem]={'seconds':.46,'peak_dbfs':-8,'rms_dbfs':round(float(20*np.log10(np.sqrt(np.mean(samples*samples)))),2),'loop':False,'original_synthesis':True}
manifest_path.write_text(json.dumps(manifest,indent=2));print(report)
