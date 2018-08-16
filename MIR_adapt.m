%% Adapting MIR code
%The following is taken from the MIR Toolbox function 'miremotion'
%(Eerola, Lartillot, & Toiviainen, 2009). I adapted
%it to work as a series of loops rather than as a function for now, but can
%look at making it into a function to save time in the future.

% You will need:
    % 1) Songs.struct: a structure variable containing the file names of the
    % songs used in the study
    % 2) PC_study_Sounds: the folder with the songs in it (on the dropbox).
    % Remember to add it to the path.
    % 3) MIR_adapt_WS: this has the mouse tracker data already extracted
    % which you'll need if you want to plot participants vs. features.

%% 1: Extracting the features
x = cell(8,46); %pre-allocating cell to store the variables
Arousal = zeros(6,46);%where the values will eventually go
Valence = zeros(6,46);
for i = 1:46 %number of songs
%Adapted miremotion code starts here. Original authors' notes in parentheses
rm = mirrms(Songs(i).name,'Frame',.046,.5);%rms
fl = mirfluctuation(Songs(i).name,'Summary');%fluctuation
fp = mirpeaks(fl,'Total',1);%finding peak value from the fluctuation
s = mirspectrum(Songs(i).name,'Frame',.046,.5);%general spectrum
sc = mircentroid(s); %spectral centroid
ss = mirspread(s); %spectral spread
c = mirchromagram(Songs(i).name,'Frame','Wrap',0,'Pitch',0);%chromagram (%%%%%%%%%%%%%%%%%%%% Previous frame size was too small.)
cp = mirpeaks(c,'Total',1);
ps = 0;
ks = mirkeystrength(c);%key strength
[k, kc] = mirkey(ks);%key
mo = mirmode(ks);%mode (major/minor)
se = mirentropy(mirspectrum(Songs(i).name,'Collapsed','Min',40,'Smooth',70,'Frame',1.5,.5)); %spectral entropy (%%%%%%%%% Why 'Frame'??) 
ns = mirnovelty(mirspectrum(Songs(i).name,'Frame',.1,.5,'Max',5000),'Normal',0); %novelty
x = {rm,fp,sc,ss,kc,mo,se,ns};% storing the local values for song i

%%
%Getting the values from the MIR objects
rm = get(x{1},'Data');
fpv = get(x{2},'PeakVal');
sc = get(x{3},'Data');
ss = get(x{4},'Data');
kc = get(x{5},'Data');
mo = get(x{6},'Data');
se = get(x{7},'Data');
ns = get(x{8},'Data');
%% 
%Converting to matrices for *math*
rm = cell2mat(rm{1,1});
fpv = cell2mat(fpv{1,1}{1,1});
sc = cell2mat(sc{1,1}{1,1});
ss = cell2mat(ss{1,1}{1,1});
kc = cell2mat(kc{1,1});
mo = cell2mat(mo{1,1});
se = cell2mat(se{1,1});
ns = cell2mat(ns{1,1});
%% 
%Normalizing and Summing: Arousal
%Multiplication values are beta weights from Eerola, Lartillot, &
%Toiviainen (2009).
%(% In the code below, removal of nan values added by Ming-Hsu Chang)
Arousal(1,i) = 0.6664* ((mean(rm(~isnan(rm))) - 0.0559)/0.0337);
Arousal(2,i) =  0.6099 * ((mean(fpv(~isnan(fpv))) - 13270.1836)/10790.655);
Arousal(3,i) = 0.4486*((mean(sc(~isnan(sc))) - 1677.7)./570.34);
Arousal(4,i) = -0.4639*((mean(ss(~isnan(ss))) - (250.5574*22.88))./(205.3147*22.88)); % New normalisation proposed by Ming-Hsu Chang
Arousal(5,i) = 0.7056*((mean(se(~isnan(se))) - 0.954)./0.0258);

Arousal(isnan(Arousal)) = [];
Arousal(6,i) = sum(Arousal(:,i))+5.4861;

%% 
%Normalizing and Summing: Valence
Valence(1,i) = -0.3161 * ((std(rm) - 0.024254)./0.015667);
Valence(2,i) =  0.6099 * (fpv - 13270.1836)/10790.655;
Valence(3,i) = 0.8802 * ((mean(kc) - 0.5123)./0.091953);
Valence(4,i) = 0.4565 * ((mean(mo) - -0.0019958)./0.048664);
ns(isnan(ns)) = [];
Valence(5,i) = 0.4015 * ((mean(ns) - 131.9503)./47.6463);
Valence(isnan(Valence)) = [];
Valence(6,i) = sum(Valence(:,i))+5.2749;
end
%Adapted miremotion code ends here
clear rm fpv sc ss kc ks psmo se ns fp k fl % make look nice
%% 2: Visualizing the Valence/Arousal data
Labels = char(Songs.name);%converting the names into their own vector
Labels = cellstr(Labels);
%%
scatter(Valence(6,:),Arousal(6,:),25,linspace(1,10,length(Valence(6,:))),'filled','d');%the plot
grid on
text(Valence(6,:), Arousal(6,:), Labels);%adding the text
ylabel('Arousal')
xlabel('Valence')
x = (1.5:0.5:6);
y = ones(1,10)*4;
line(x,y)
y = (3.5:0.5:8.5);
x = ones(1,11)*4;
line(x,y)
hold off
clear x y
%% 3: Scatter Plot with Mouse Data
%Valence scatter plot
piece = (1:46);
figure
for i = 1:23
scatter(piece,shortParticipants{1,i}(:,1)/100);%original scale -400:800
grid on
hold on
end
clear i
xlabel('Piece')
xticks(1:46)
xlim([0 47])
xticklabels(Labels)
xtickangle(45)
ylabel('Valence')
%yticklabels(0:8);
title('Mean Valence for all Participants')
%%
%adding the valence feature overlay
tmp = Valence(6,:)-4;%original scale 0:8
a = scatter(piece,tmp,100,'filled','d');
legend(a,'MIR Valence');
clear tmp
%%
%adding all features as overlay
%Labels
Feature_Labels = {'RMS'; 'Fluctuation'; 'Key Clarity'; 'Mode'; 'Novelty';'MIR Valence';'RMS';...
    'Summarized Fluctuation';'Centroid';'Spread';'Entropy';'MIR Arousal'};
%%
%One by one features
a = scatter(piece,Valence(1,:),100,'filled','d');
b = scatter(piece,Valence(2,:),100,'filled','d');
c = scatter(piece,Valence(3,:),100,'fillled','d');
d = scatter(piece,Valence(4,:),100,'filled','d');
e = scatter(piece,Valence(5,:),100,'filled','d');
f = scatter(piece,Valence(6,:)-4,100,'filled','d');
legend([a b c d e f],Feature_Labels{1:6})
clear a b c d e f
hold off

%%
%Arousal scatter plot
figure
for i = 1:23
scatter(piece,shortParticipants{1,i}(:,2)/100);
grid on
hold on
end
clear i
xlabel('Piece')
xticks(1:46)
xlim([0 47])
xticklabels(Labels)
xtickangle(45)
ylabel('Arousal')
yticklabels(0:8);
title('Mean Arousal for all Participants')
tmp = Arousal(6,:)-4;
a = scatter(piece,tmp,100,'filled','d');
legend(a,'MIR Arousal');

%%
%One by one features
a = scatter(piece,Arousal(1,:),100,'filled','d');
b = scatter(piece,Arousal(2,:),100,'filled','d');
c = scatter(piece,Arousal(3,:),100,'fillled','d');
d = scatter(piece,Arousal(4,:),100,'filled','d');
e = scatter(piece,Arousal(5,:),100,'filled','d');
f = scatter(piece,Arousal(6,:)-4,100,'filled','d');

legend([a b c d e f],Feature_Labels{7:12})
clear a b c d e f
hold off
%% 4: k-means clustering of the features
% NB: MIR toolbox needs to be removed from the path, otherwise k-means
% fights with an existing function and won't run
[idx_V, ~] = kmeans(Valence(6,:)',4);
[idx_A, ~] = kmeans(Arousal(6,:)',4);
%% K-means bar plot syntax
figure 
subplot(2,1,1)
bar(idx_V);
xlim([0 47])
xticklabels(Labels)
xtickangle(45)
xticks(1:46)
yticks(0:1:4)
ylabel('Valence')

subplot(2,1,2)
bar_handle = bar(idx_A);
colormap('Jet')
xlim([0 47])
xticklabels(Labels)
xtickangle(45)
xticks(1:46)
yticks(0:1:4)
ylabel('Arousal')
%%
%k-means clustering of participant mouse movement
%arranging the cell into two matrices
PT_Valence = zeros(46,23);% pre-allocating the matrices
PT_Arousal = zeros(46,23);
for i = 1:23
    PT_Valence(:,i) = shortParticipants{1,i}(:,1);%column 1 = x-coordinates = Valence
    PT_Arousal(:,i) = shortParticipants{1,i}(:,2);%column 2 = y-coordinates = Arousal
end
clear i
%%
%the k-means syntax
[idx_PTV, ~] = kmeans(PT_Valence,4);
[idx_PTA, ~] = kmeans(PT_Arousal,4);
%% K-means bar plot syntax
figure 
subplot(2,1,1)
bar(idx_PTV);
xlim([0 47])
xticklabels(Labels)
xtickangle(45)
xticks(1:46)
yticks(0:1:4)
ylabel('Valence')

subplot(2,1,2)
bar_handle = bar(idx_PTA);
colormap('Jet')
xlim([0 47])
xticklabels(Labels)
xtickangle(45)
xticks(1:46)
yticks(0:1:4)
ylabel('Arousal')
%%
% Participant clusters from k-means on participant ratings
VC_1 = [1 4 6 7 10 13 15 17 21];
VC_2 = [2 3 5 8 9 11 12 14 19 20 22 23];
AC_1 = [1 4 6 10 13 15 17 18 21];
AC_2 = [2 3 5 9 14 19 20];
AC_3 = [8 11 12 16 22 23];
%%
%the k-means syntax
[idx_PTA1, ~] = kmeans(PT_Arousal(:,AC_1)',4);
[idx_PTA2, ~] = kmeans(PT_Arousal(:,AC_2)',4);
[idx_PTA3, ~] = kmeans(PT_Arousal(:,AC_3)',4);
%%
%the plot
figure
subplot(3,1,1)
bar(idx_PTA1);
xlim([0 24])
%xticklabels(Labels)
%xtickangle(45)
xticks(1:23)
yticks(0:1:4)
ylabel('Arousal Cluster 1')

subplot(3,1,2)
bar(idx_PTA2);
xlim([0 24])
%xticklabels(Labels)
%xtickangle(45)
xticks(1:23)
yticks(0:1:4)
ylabel('Arousal Cluster 2')

subplot(3,1,3)
bar(idx_PTA3);
xlim([0 24])
%xticklabels(Labels)
%xtickangle(45)
xticks(1:23)
yticks(0:1:4)
ylabel('Arousal Cluster 3')
%% 5: Correlations. Time to figure out what these participants are rating, AMIRITE?
Valence_r = zeros(23,6);%setting the r-value cells
Arousal_r = zeros(23,6);
for p = 1:23%participant
%    for e = 1:46%piece
        for f = 1:6%feature
        [Vr, ~] = corrcoef(PT_Valence(:,p)',Valence(f,:));%doing the correlation
        Valence_r(p,f) = Vr(2,1);%printing the r-value in the r-value cell
        [Ar, ~] = corrcoef(PT_Arousal(:,p)',Arousal(f,:));%doing the correlation
        Arousal_r(p,f) = Ar(2,1);
        end
end
clear Vr Ar p f %make look nice
%%
figure
subplot(1,2,1)
imagesc(Valence_r)
ylabel('Participants')
xlabel('Feature')
xticks(1:6)
title('Valence')
colorbar

subplot(1,2,2)
imagesc(Arousal_r)
ylabel('Participants')
xlabel('Feature')
xticks(1:6)
title('Arousal')
colorbar
