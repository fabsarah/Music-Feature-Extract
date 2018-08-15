%% Adapting MIR code
%The following is taken from the MIR Toolbox code. I adapted
%it to work as a series of loops rather than as a function because of
%course I would. This is how it works for now. If results are good, we can
%look at making it into a function to save time in the future. 

%%%%Requirements: PC Study Sounds folder, Songs.struct file

%% Extracting the features
x = cell(8,46);%8 features, 46 pieces
Arousal = zeros(6,46); % 5 final features, one summed value
Valence = zeros(6,46);
for i = 1:46
rm = mirrms(Songs(i).name,'Frame',.046,.5);%rms
fl = mirfluctuation(Songs(i).name,'Summary');%fluctuation
fp = mirpeaks(fl,'Total',1);
s = mirspectrum(Songs(i).name,'Frame',.046,.5);
sc = mircentroid(s); %spectral centroid
ss = mirspread(s); %spectral spread
c = mirchromagram(Songs(i).name,'Frame','Wrap',0,'Pitch',0);    %%%%%%%%%%%%%%%%%%%% Previous frame size was too small.
cp = mirpeaks(c,'Total',1);
ps = 0;
ks = mirkeystrength(c);
[k, kc] = mirkey(ks);
mo = mirmode(ks);
se = mirentropy(mirspectrum(Songs(i).name,'Collapsed','Min',40,'Smooth',70,'Frame',1.5,.5)); %%%%%%%%% Why 'Frame'?? 
ns = mirnovelty(mirspectrum(Songs(i).name,'Frame',.1,.5,'Max',5000),'Normal',0);
x = {rm,fp,sc,ss,kc,mo,se,ns};
%%
rm = get(x{1},'Data');
fpv = get(x{2},'PeakVal');
sc = get(x{3},'Data');
ss = get(x{4},'Data');
kc = get(x{5},'Data');
mo = get(x{6},'Data');
se = get(x{7},'Data');
ns = get(x{8},'Data');
%% Converting to matrices
rm = cell2mat(rm{1,1});
fpv = cell2mat(fpv{1,1}{1,1});
sc = cell2mat(sc{1,1}{1,1});
ss = cell2mat(ss{1,1}{1,1});
kc = cell2mat(kc{1,1});
mo = cell2mat(mo{1,1});
se = cell2mat(se{1,1});
ns = cell2mat(ns{1,1});
%% Normalizing and Summing: Arousal
% In the code below, removal of nan values added by Ming-Hsu Chang
Arousal(1,i) = 0.6664* ((mean(rm(~isnan(rm))) - 0.0559)/0.0337);
%tmp = fpv{1};
Arousal(2,i) =  0.6099 * ((mean(fpv(~isnan(fpv))) - 13270.1836)/10790.655);
%tmp = cell2mat(sc);
Arousal(3,i) = 0.4486*((mean(sc(~isnan(sc))) - 1677.7)./570.34);
%tmp = cell2mat(ss);
Arousal(4,i) = -0.4639*((mean(ss(~isnan(ss))) - (250.5574*22.88))./(205.3147*22.88)); % New normalisation proposed by Ming-Hsu Chang
Arousal(5,i) = 0.7056*((mean(se(~isnan(se))) - 0.954)./0.0258);

Arousal(isnan(Arousal)) = [];
Arousal(6,i) = sum(Arousal(:,i))+5.4861;

clear temp %make look nice

%% Normalizing and Summing: Valence

Valence(1,i) = -0.3161 * ((std(rm) - 0.024254)./0.015667);
Valence(2,i) =  0.6099 * (fpv - 13270.1836)/10790.655;
Valence(3,i) = 0.8802 * ((mean(kc) - 0.5123)./0.091953);
Valence(4,i) = 0.4565 * ((mean(mo) - -0.0019958)./0.048664);
ns(isnan(ns)) = [];
Valence(5,i) = 0.4015 * ((mean(ns) - 131.9503)./47.6463);
Valence(isnan(Valence)) = [];
Valence(6,i) = sum(Valence(:,i))+5.2749;
end
clear rm fpv sc ss kc mo se ns %make look nice
