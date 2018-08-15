%% Adapting MIR code

%% Extracting the features
rm = mirrms(x,'Frame',.046,.5);

le = 0; %mirlowenergy(rm,'ASR');

o = mironsets(x,'Filterbank',15,'Contrast',0.1);
at = mirattacktime(o);
as = 0; %mirattackslope(o);
ed = 0; %mireventdensity(o,'Option1');

fl = mirfluctuation(x,'Summary');
fp = mirpeaks(fl,'Total',1);
fc = 0; %mircentroid(fl);

tp = 0; %mirtempo(x,'Frame',2,.5,'Autocor','Spectrum');
pc = mirpulseclarity(x,'Frame',2,.5); %%%%%%%%%%% Why 'Frame'?? 

s = mirspectrum(x,'Frame',.046,.5);
sc = mircentroid(s);
ss = mirspread(s);
sr = mirroughness(s);

%ps = mirpitch(x,'Frame',.046,.5,'Tolonen');

c = mirchromagram(x,'Frame','Wrap',0,'Pitch',0);    %%%%%%%%%%%%%%%%%%%% Previous frame size was too small.
cp = mirpeaks(c,'Total',1);
ps = 0;%cp;
ks = mirkeystrength(c);
[k kc] = mirkey(ks);
mo = mirmode(ks);
hc = mirhcdf(c);

se = mirentropy(mirspectrum(x,'Collapsed','Min',40,'Smooth',70,'Frame',1.5,.5)); %%%%%%%%% Why 'Frame'?? 

ns = mirnovelty(mirspectrum(x,'Frame',.1,.5,'Max',5000),'Normal',0);
nt = mirnovelty(mirchromagram(x,'Frame',.2,.25),'Normal',0);    %%%%%%%%%%%%%%%%%%%% Previous frame size was too small.
nr = mirnovelty(mirchromagram(x,'Frame',.2,.25,'Wrap',0),'Normal',0);   %%%%%%%%%%%%%%%%%%%% Previous frame size was too small.



x = {rm,le, at,as,ed, fp,fc, tp,pc, sc,ss,sr, ps, cp,kc,mo,hc, se, ns,nt,nr}; %Compiling into a massive cell
%% Extracting from the massive cell
option = process(option);
rm = get(x{1},'Data');
%le = get(x{2},'Data');
at = get(x{3},'Data');
%as = get(x{4},'Data');
%ed = get(x{5},'Data');
%fpp = get(x{6},'PeakPosUnit');
fpv = get(x{6},'PeakVal');
%fc = get(x{7},'Data');
%tp = get(x{8},'Data');
pc = get(x{9},'Data');
sc = get(x{10},'Data');
ss = get(x{11},'Data');
rg = get(x{12},'Data');
%ps = get(x{13},'PeakPosUnit');
cp = get(x{14},'PeakPosUnit');
kc = get(x{15},'Data');
mo = get(x{16},'Data');
hc = get(x{17},'Data');
se = get(x{18},'Data');
ns = get(x{19},'Data');
nt = get(x{20},'Data');
nr = get(x{21},'Data');

%% Normalizing and Summing
function [e af] = activity(e,rm,fpv,sc,ss,se) % without the box-cox transformation, revised coefficients
af = zeros(5,1);

% In the code below, removal of nan values added by Ming-Hsu Chang
af(1) = 0.6664* ((mean(rm(~isnan(rm))) - 0.0559)/0.0337);
tmp = fpv{1};
af(2) =  0.6099 * ((mean(tmp(~isnan(tmp))) - 13270.1836)/10790.655);
tmp = cell2mat(sc);
af(3) = 0.4486*((mean(tmp(~isnan(tmp))) - 1677.7)./570.34);
tmp = cell2mat(ss);
af(4) = -0.4639*((mean(tmp(~isnan(tmp))) - (250.5574*22.88))./(205.3147*22.88)); % New normalisation proposed by Ming-Hsu Chang
af(5) = 0.7056*((mean(se(~isnan(se))) - 0.954)./0.0258);

af(isnan(af)) = [];
e(end+1,:) = sum(af)+5.4861;

function [e vf] = valence(e,rm,fpv,kc,mo,ns) % without the box-cox transformation, revised coefficients
vf = zeros(5,1);
vf(1) = -0.3161 * ((std(rm) - 0.024254)./0.015667);
vf(2) =  0.6099 * ((mean(fpv{1}) - 13270.1836)/10790.655);
vf(3) = 0.8802 * ((mean(kc) - 0.5123)./0.091953);
vf(4) = 0.4565 * ((mean(mo) - -0.0019958)./0.048664);
ns(isnan(ns)) = [];
vf(5) = 0.4015 * ((mean(ns) - 131.9503)./47.6463);
vf(isnan(vf)) = [];
e(end+1,:) = sum(vf)+5.2749;
