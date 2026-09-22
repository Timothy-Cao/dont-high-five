"""Rebuild original layered effects from the included CC0 samples. Requires numpy and FFmpeg."""
from pathlib import Path
import json, math, re, subprocess, wave, sys
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/audio/sfx'
SOURCE = ROOT / 'art/audio/kenney'
RATE = 48000
OUT.mkdir(parents=True, exist_ok=True)
rng = np.random.default_rng(91027)
cache = {}
manifest = {}

def recording(name, n):
    if name not in cache:
        p = subprocess.run(['ffmpeg','-v','error','-i',str(SOURCE/name),'-ac','1','-ar',str(RATE),'-f','f32le','-'], capture_output=True, check=True)
        cache[name] = np.frombuffer(p.stdout, dtype='<f4').copy()
    data = cache[name]
    out = np.zeros(n)
    out[:min(n,len(data))] = data[:n]
    return out

def noise(n, cutoff=2200):
    data = rng.normal(0,1,n)
    spectrum = np.fft.rfft(data)
    hz = np.fft.rfftfreq(n, 1/RATE)
    spectrum *= (1-np.exp(-(hz/80)**2)) * np.exp(-(hz/cutoff)**2)
    return np.fft.irfft(spectrum, n=n)

def save(name, data, peak_db=-7, loop=False):
    data = data - np.mean(data)
    if not loop:
        fade = min(int(RATE*.006),len(data)//3)
        envelope = np.ones(len(data))
        envelope[:fade] = np.linspace(0,1,fade)
        envelope[-fade:] = np.linspace(1,0,fade)
        data *= envelope
        # Remove the small mean introduced by the endpoint taper without a click.
        data -= envelope * (np.sum(data) / np.sum(envelope))
    peak = max(float(np.max(np.abs(data))),1e-7)
    data = data / peak * 10**(peak_db/20)
    samples = (np.clip(data,-1,1)*32767).astype('<i2')
    with wave.open(str(OUT/(name+'.wav')),'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE); w.writeframes(samples.tobytes())
    manifest[name] = {'seconds':round(len(data)/RATE,3),'peak_dbfs':peak_db,'rms_dbfs':round(20*math.log10(max(1e-9,float(np.sqrt(np.mean(data**2))))),2),'loop':loop}

for variant in range(4):
    ratio = rng.uniform(.94,1.06)
    for kind, duration in {'fire':.24,'stick':.22,'cancel':.28,'launch':.68,'jump':.25,'bounce':.50,'land':.42,'brake':.50,'portal':1.10,'pad':.75,'success':.40,'ui':.13}.items():
        n = int(RATE*duration); t = np.arange(n)/RATE; f=t/duration
        air = noise(n,3400)*np.sin(np.pi*f)**1.5
        pitch = (190+variant*7)*ratio
        elastic = np.sin(2*np.pi*(pitch*t+110*t*t))*np.exp(-t*11)
        body = recording(f'impactSoft_medium_{variant:03d}.ogg',n)
        if kind=='fire': data=.55*air*np.exp(-t*7)+.24*elastic+.28*body
        elif kind=='stick': data=.75*body+.10*recording(f'impactMetal_light_{variant:03d}.ogg',n)+.13*elastic
        elif kind=='cancel': data=.35*air*(1-f)+.10*np.sin(2*np.pi*(380*t-360*t*t))*np.exp(-t*12)
        elif kind in ['launch','pad']:
            data=.28*recording(f'thrusterFire_{variant:03d}.ogg',n)+.62*air*np.exp(-t*1.8)+.22*np.sin(2*np.pi*(95*t+55*t*t))*np.exp(-t*10)
        elif kind=='jump': data=.30*body+.22*air+.09*elastic
        elif kind=='bounce': data=.30*body+.21*np.sin(2*np.pi*(125*t+350*t*t))*np.exp(-t*7)+.2*air
        elif kind=='land': data=.65*recording(f'impactSoft_heavy_{variant:03d}.ogg',n)+.20*body+.08*np.sin(2*np.pi*72*t)*np.exp(-t*18)
        elif kind=='brake': data=.35*recording(f'impactSoft_heavy_{variant:03d}.ogg',n)+.42*air*np.exp(-t*5)
        elif kind=='portal': data=.22*recording(f'forceField_{variant:03d}.ogg',n)+.42*air+.12*np.sin(2*np.pi*(180*t+190*t*t))*np.sin(np.pi*f)**2
        elif kind=='success':
            data=sum(np.sin(2*np.pi*hz*ratio*t)*np.exp(-t*(10+j*2))/(j+1) for j,hz in enumerate([880,1320,1760]))*.15
            data+=.12*recording('pluck_001.ogg',n)
        else: data=recording(f'click_{variant+1:03d}.ogg',n)
        save(f'{kind}_{variant}',data,-11 if kind in ['ui','success','jump'] else -7)
for i in range(5):
    data=recording(f'footstep_carpet_{i:03d}.ogg',int(RATE*.35))
    save(f'step_{i}',data,-13)
# FFT-shaped periodic noise and integer-frequency oscillators have seamless loop boundaries.
for kind in ['wind','creak','reel','room']:
    n=RATE*4;t=np.arange(n)/RATE
    data=noise(n,900 if kind=='room' else 2100)
    if kind=='wind': data*=.68+.15*np.sin(2*np.pi*.5*t)
    elif kind=='creak': data=.18*data+.25*np.sin(2*np.pi*112*t+.7*np.sin(2*np.pi*2*t))+.06*np.sin(2*np.pi*224*t)
    elif kind=='reel': data=.3*data+.18*np.sin(2*np.pi*90*t)*(0.7+.3*np.sin(2*np.pi*12*t))
    else: data=.8*data+.08*np.sin(2*np.pi*60*t)
    save(kind,data,-14,True)
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2))
print('Built',len(manifest),'48 kHz effects; no sample clipping.')

import runpy
runpy.run_path(str(ROOT/'art/build_blast_audio.py'),run_name='__main__')
if "--effects-only" in sys.argv: sys.exit(0)

# Measure original music without re-encoding it; apply level matching at playback.
tracks=[]
for p in sorted((ROOT/'assets/audio/music').glob('*.mp3')):
    proc=subprocess.run(['ffmpeg','-hide_banner','-nostats','-i',str(p),'-af','loudnorm=I=-18:TP=-2:LRA=11:print_format=json','-f','null','-'],capture_output=True,text=True,check=True)
    data=json.loads(re.findall(r'\{[^{}]+\}',proc.stderr)[-1])
    duration=float(subprocess.run(['ffprobe','-v','error','-show_entries','format=duration','-of','default=noprint_wrappers=1:nokey=1',str(p)],capture_output=True,text=True,check=True).stdout.strip())
    tracks.append({'file':p.name,'title':p.stem.replace('_',' ').title(),'seconds':duration,'integrated_lufs':float(data['input_i']),'true_peak_db':float(data['input_tp']),'gain_db':round(max(-18,min(6,-18-float(data['input_i']))),2)})
(ROOT/'assets/audio/music/playlist.json').write_text(json.dumps(tracks,indent=2))
print('Measured all five OST tracks:',[(t['title'],t['integrated_lufs']) for t in tracks])
