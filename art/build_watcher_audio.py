"""Original deterministic weapon synthesis, 48 kHz. No external samples."""
from pathlib import Path
import wave,json
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/audio/sfx'
RATE=48000
rng=np.random.default_rng(92318)
report=[]
for kind,duration,peak in [('watcher_mg',.27,-5),('watcher_sniper',1.8,-2),('watcher_blast',1.35,-3),('watcher_orbital',4.6,-3)]:
 for variant in range(4):
  t=np.arange(int(RATE*duration))/RATE
  noise=rng.normal(0,1,len(t))
  hz=np.fft.rfftfreq(len(t),1/RATE)
  def filtered(cutoff):
   return np.fft.irfft(np.fft.rfft(noise)*np.exp(-(hz/cutoff)**2)*(1-np.exp(-(hz/40)**2)),n=len(t))
  if kind=='watcher_orbital':
   # Ignition crack, sustained electrical roar, beating subharmonics, power-down tail.
   envelope=np.minimum(t/.08,1)*np.clip((4.6-t)/.65,0,1)
   phase=2*np.pi*(52*t+140*.07*(1-np.exp(-t/.07)))
   s=(.28*filtered(1800)+.17*filtered(4800)*(0.6+0.4*np.sin(t*2*np.pi*9)))
   s+=.22*np.sin(phase)+.12*np.sin(phase*1.51)
   s=s*envelope+.3*filtered(7000)*np.exp(-t/.02)
  elif kind=='watcher_mg':
   s=.5*filtered(6000)*np.exp(-t/.026)+.3*np.sin(2*np.pi*(105*t+75*.018*(1-np.exp(-t/.018))))*np.exp(-t/.045)
   s+=.11*filtered(1500)*np.exp(-t/.11)
  else:
   # Short crack, descending low body, diffuse delayed indoor tail.
   s=.42*filtered(7000)*np.exp(-t/.018)+.58*filtered(1100)*np.exp(-t/.22)
   s+=.33*np.sin(2*np.pi*(48*t+85*.04*(1-np.exp(-t/.04))))*np.exp(-t/.20)
   dry=s.copy()
   for delay,gain in [(.051,.26),(.097,.18),(.163,.14),(.271,.10),(.389,.07)]:
    offset=int((delay+variant*.001)*RATE);s[offset:]+=dry[:-offset]*gain
   s+=.12*filtered(550)*(1-np.exp(-t/.06))*np.exp(-t/.42)
   if kind=='watcher_blast':
    s+=.18*np.sin(2*np.pi*(42*t+270*.10*(1-np.exp(-t/.10))))*np.exp(-t/.35)
    s+=.12*filtered(2200)*(np.sin(t*2*np.pi*13)>0)*np.exp(-t/.5)
  s*=np.minimum(t/.0008,1);s-=s.mean();s[:48]*=np.linspace(0,1,48);s[-960:]*=np.linspace(1,0,960)
  s*=10**(peak/20)/np.max(np.abs(s))
  name=f'{kind}_{variant}.wav'
  with wave.open(str(OUT/name),'wb') as f:
   f.setnchannels(1);f.setsampwidth(2);f.setframerate(RATE);f.writeframes((s*32767).astype('<i2').tobytes())
  report.append({'file':name,'seconds':duration,'peak_dbfs':peak,'rms_dbfs':round(float(20*np.log10(np.sqrt(np.mean(s*s)))),2),'original_synthesis':True})
(ROOT/'art/watcher-audio-report.json').write_text(json.dumps(report,indent=2)+'\n')
p=OUT/'manifest.json';manifest=json.loads(p.read_text())
for item in report:manifest[Path(item['file']).stem]={**item,'loop':False}
p.write_text(json.dumps(manifest,indent=2)+'\n')
print(f'Generated {len(report)} original weapon samples; peak <= -2 dBFS.')
