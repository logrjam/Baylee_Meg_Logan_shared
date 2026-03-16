% determine why variable streamflow response to climate across catchments
clear
close all

% monthly precipitation
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJanP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allFebP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allMarP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allAprP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allMayP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJunP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJulP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allAugP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allSepP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allOctP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allNovP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allDecP

% load monthly temperature files
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJanT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allFebT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allMarT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allAprT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allMayT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJunT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJulT
% load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allAugT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allSepT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allOctT
% load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allNovT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allDecT


wintert = (allDecT + allJanT + allFebT)./3;
springt = (allMarT + allAprT + allMayT)./3;
winterp = allDecP + allJanP + allFebP;
springp = allMarP + allAprP + allMayP;
snowP = winterp + allMarP;
snowT = (allDecT +allJanT + allFebT + allMarT +allAprT + allMayT)./6;
% load melt dynamics data- determined via threshold
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allmeltrate.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allmeltraterising.mat %MR rising limb only
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allmeltdur.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allmeltstart.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allmeltend.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allspringrh.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allwinterrh.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allstreamflow.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allprecip.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/alltemperature.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allbaseflow.mat
diffT = mean(t(85:end,:),'omitnan')-mean(t(1:84,:),'omitnan');

%load melt data- determined via change pt
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltstartcp.mat 
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltdurcp.mat 
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltratecp.mat 
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltraterisingcp.mat 
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltratefallingcp.mat 
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltendcp.mat 
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltvolcp.mat 
% load monthly mean PET data
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/monthlymeanPET.mat 

% load landscaper characteristics: columns slc -> wr
% rows: 1area, 2elevation, 3,4,5temp (mean,sd,change post 1985)
% 6,7precip (mean,SD), 8,9streamflow (mean,SD), 10,11WY(mean,SD),
% 12aspectN,13E,14S,15W,16slopeangle
lscape = csvread('F:\BoxSync\LoganThesisDatasets\LandscapeCharacteristics.csv',1,1);
% add rows for CV of T,P,Q,WY,  mean winter p, mean annual PET, PET/P, & delta Temp 
lscape = [lscape; lscape(4,:)./lscape(3,:); lscape(7,:)./lscape(6,:);...
    lscape(9,:)./lscape(8,:); lscape(11,:)./lscape(10,:); mean(winterp,'omitnan');...
    sum(monthlymeanPET); sum(monthlymeanPET)./lscape(6,:); diffT];
% add rows for %N+E and S+W and winter/spring T
lscape = [lscape; (lscape(12,:)+lscape(13,:)); (lscape(14,:)+lscape(15,:)); mean(snowT,'omitnan')];
RoW = nan(1,12);%calculate more precise rate of warming since 1985
for i =1:12
    tempB = regress(t(85:end,i),[(85:118)' ones(118-84,1)]);
    RoW(i) = tempB(1);
end
lscape(5,:)=RoW;
%create string array with catchment abbreviations
catchnames = [string('J-CC'),string('J-RB'),string('J-EC'),string('J-PC')...
    string('J-MC'), string('J-BC'),string('J-LC'), string('W-ECJ'),string('W-CC')...
    ,string('W-LC'),string('W-OSF'), string('W-WO')];
ncatch = size(catchnames,2);
catchnamesfullrec =[catchnames(1:7) catchnames(9) catchnames(11:12)];

% set colors of plots- RGB triplets
c = {[1 0 1],[1 0 0],[0 1 0],[0 1 1],[0 0 1],[.8 .7 .1],[0 0 0],[.75 0 .5],...
    [1 .5 0],[0 .75 .5],[0 .5 1],[.5 0 1]};
cmat = [1 0 1;1 0 0;0 1 0;0 1 1;0 0 1;.8 .7 .1;0 0 0;.75 0 .5;...
    1 .5 0;0 .75 .5;0 .5 1;.5 0 1]; %matrix of colors codes

cnew =  c([2 3 4 5 8 7 11 6 9 10 1 12]);

%normalize melt rate for winter p - commented out
% allmeltrate = allmeltrate./winterp;

% water yield
wy = q./p;
%normalize melt rate for winter P- use residuals of MR snowP regression
% nmr = allmeltrate./snowP;
% nmrcp = meltratecp./snowP;


for i=1:ncatch
    [Bmrwp(:,i),~,Rmrwp(:,i),~,Smrwp(:,i)] = regress(allmeltrate(:,i),[snowP(:,i) ones(118,1)]);
    [Bmrwpcp(:,i),~,Rmrwpcp(:,i),~,Smrwpcp(:,i)] = regress(meltratecp(:,i),[snowP(:,i) ones(118,1)]);
    [Bmrrwpcp(:,i),~,Rmrrwpcp(:,i),~,Smrrwpcp(:,i)] = regress(meltraterisingcp(:,i),[snowP(:,i) ones(118,1)]);
    [Bmrfwpcp(:,i),~,Rmrfwpcp(:,i),~,Smrfwpcp(:,i)] = regress(meltratefallingcp(:,i),[snowP(:,i) ones(118,1)]); 
end
nmr = Rmrwp;
nmrcp = Rmrwpcp;
nmrrcp = Rmrrwpcp;
nmrfcp = Rmrfwpcp;

%z-score metrics
zwy = (wy-mean(wy,'omitnan'))./std(wy,'omitnan');
zp = (p-mean(p,'omitnan'))./std(p,'omitnan');
zt = (t-mean(t,'omitnan'))./std(t,'omitnan');
zsnowp = (snowP-mean(snowP,'omitnan'))./std(snowP,'omitnan');
zsnowt = (snowT-mean(snowT,'omitnan'))./std(snowT,'omitnan');
zq = (q-nanmean(q))./nanstd(q);
zbf = (allbaseflow-nanmean(allbaseflow))./nanstd(allbaseflow);
zmr = (allmeltrate-nanmean(allmeltrate))./nanstd(allmeltrate);
zms = (allmeltstart-nanmean(allmeltstart))./nanstd(allmeltstart);
zmscp = (meltstartcp-nanmean(meltstartcp))./nanstd(meltstartcp);
zmd = (allmeltdur-nanmean(allmeltdur))./nanstd(allmeltdur);
zmrcp = (meltratecp-nanmean(meltratecp))./nanstd(meltratecp);
zmrrcp = (meltraterisingcp-nanmean(meltraterisingcp))./nanstd(meltraterisingcp);
zmrfcp = (meltratefallingcp-nanmean(meltratefallingcp))./nanstd(meltratefallingcp);
znmr = (nmr-nanmean(nmr))./nanstd(nmr);
% znmrcp = (nmrcp-nanmean(nmrcp))./nanstd(nmrcp); % normalize after z
% scoring, as below

%normalize melt rate for winter P by regressing and taking residuals
% normalize z scored mr for winter p
Bmrwp = nan(2,ncatch);
Rmrwp = nan(118,ncatch);
Smrwp = nan(4,ncatch);
for i=1:ncatch
    [Bmrwp(:,i),~,Rmrwp(:,i),~,Smrwp(:,i)] = regress(zmrcp(:,i),[zsnowp(:,i) ones(118,1)]);
    [Bmrrwp(:,i),~,Rmrrwp(:,i),~,Smrrwp(:,i)] = regress(zmrrcp(:,i),[zsnowp(:,i) ones(118,1)]);
    [Bmrfwp(:,i),~,Rmrfwp(:,i),~,Smrfwp(:,i)] = regress(zmrfcp(:,i),[zsnowp(:,i) ones(118,1)]);
end
znmrcp = Rmrwp;
znmrrcp = Rmrrwp;
znmrfcp = Rmrfwp;

%% estimate water yield using BF + MR (normalized for winter P)
% use changepoint melt rate

%bf and nmr
Bznwy2 = nan(3,ncatch);
Rznwy2 = nan(118,ncatch);
Sznwy2 = nan(4,ncatch);
for i =1:ncatch
    [Bznwy2(:,i),~,Rznwy2(:,i),~,Sznwy2(:,i)] = regress(zwy(:,i),[zbf(:,i) znmrcp(:,i) ones(118,1)]);
end


estnwy2 = zbf.*Bznwy2(1,:) + znmrcp.*Bznwy2(2,:) + Bznwy2(3,:);

% estimate WY using bf and mr, not z-scored or normalized
Bwy = nan(3,ncatch);
Rwy = nan(118,ncatch);
Swy = nan(4,ncatch);
for i =1:ncatch
    [Bwy(:,i),~,Rwy(:,i),~,Swy(:,i)] = regress(wy(:,i),[allbaseflow(:,i) meltratecp(:,i) ones(118,1)]);
end

%% basic timeseries showing T,P, and Q
figure;
subplot(4,1,1)
plot(1901:2018,p,'linewidth',1.7)
ylabel('Precipitation (mm)'); ylim([0 2200])
xticks([])
ax = gca; ax.FontSize = 12;
subplot(4,1,2)
plot(1901:2018,t,'linewidth',1.7)
ylabel('Temperature (C)'); xticks([])
ax = gca; ax.FontSize = 12;
subplot(4,1,3)
plot(1901:2018,q,'linewidth',1.7)
ylabel('Streamflow (mm)'); ylim([0 1600]); xticks([])
ax = gca; ax.FontSize = 12;
subplot(4,1,4)
plot(1901:2018,wy,'linewidth',1.7)
ylabel('Runoff Efficiency'); 
ax = gca; ax.FontSize = 12;
% legend(catchnames)

%% basic timeseries showing melt rate, start
figure;
subplot(2,1,1)
for i=1:12
plot(1901:2018,meltratecp(:,i),'linewidth',2,'color',c{i}); hold on
end
ylabel('Melt Rate (mm/day)'); xticks([])
ax = gca; ax.FontSize = 14;

subplot(2,1,2)
for i=1:12
plot(1901:2018,meltstartcp(:,i),'linewidth',2,'color',c{i}); hold on
end
ylabel('Melt Start (DOY)');
ax = gca; ax.FontSize = 14;
%% basic timeseries showing winter/spring T,P, and Q
figure;
subplot(3,1,1)
plot(1901:2018,snowP,'linewidth',2)
ylabel('Winter Precipitation (mm)'); ylim([0 2200])
xticks([])
ax = gca; ax.FontSize = 14;
subplot(3,1,2)
plot(1901:2018,snowT,'linewidth',2)
ylabel('Winter/Spring Temperature (C)'); xticks([])
ax = gca; ax.FontSize = 14;
subplot(3,1,3)
plot(1901:2018,q,'linewidth',2)
ylabel('Streamflow (mm)'); ylim([0 1600])
ax = gca; ax.FontSize = 14;
legend(catchnames)
%% plot MR vs winterP and time series of MR (norm) and WY
% and time series of MR (norm) + storage and WY on separate panel
figure; 
subplot(3,2,1)
plot(snowP,meltratecp,'o')
xlabel('Winter Precipitation (mm)'); ylabel('Melt Rate (mm/day)')
legend(catchnames)
ax = gca;
ax.FontSize = 14;
subplot(3,2,3:4)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(znmrcp,2),'LineWidth',2);
xlabel('Water Year'); ylabel('z-score'); ylim([-3 3])
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Melt Rate (norm for winter P)','location','southeast')
subplot(3,2,5:6)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estnwy2,2),'LineWidth',2);
xlabel('Water Year'); ylabel('z-score'); ylim([-3 3])
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Storage + Melt Rate (norm for winter P)')

%% plot MR vs winterP and time series of MR (norm) and WY
% MR + storage on same panel
figure; 
subplot(2,3,1)
plot(snowP,meltratecp,'o')
xlabel('Winter Precipitation (mm)'); ylabel('Melt Rate (mm/day)')
legend(catchnames)
ax = gca;
ax.FontSize = 14;
subplot(2,3,2)
plot(snowT(:,[1:7,9,11,12]),meltratecp(:,[1:7,9,11,12]),'o')
xlim([-7 5])
xlabel('Winter/Spring Temperature (C)'); ylabel('Melt Rate (mm/day)')
ax = gca;
ax.FontSize = 14;
subplot(2,3,3)
plot(meltstartcp,meltratecp,'o')
xlabel('Melt Start (DOY)'); ylabel('Melt Rate (mm/day)')
ax = gca;
ax.FontSize = 14;
subplot(2,3,4:6)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(znmrcp,2),'LineWidth',2);
plot(1901:2018, nanmean(estnwy2,2),'LineWidth',2);
xlabel('Water Year'); ylabel('z-score'); ylim([-3 3])
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Melt Rate (norm for winter P)','Storage + Melt Rate (norm for winter P)','location','southeast')


%% calculate correlations between mr and winter p,t, and ms
rwp = nan(1,12); pwp = nan(1,12);
rwt = nan(1,12); pwt = nan(1,12);
rms = nan(1,12); pms = nan(1,12);
%rising limb
rrwp = nan(1,12); prwp = nan(1,12);
rrwt = nan(1,12); prwt = nan(1,12);
rrms = nan(1,12); prms = nan(1,12);
%falling limb
rfwp = nan(1,12); pfwp = nan(1,12);
rfwt = nan(1,12); pfwt = nan(1,12);
rfms = nan(1,12); pfms = nan(1,12);
for i =1:12
    [rwp(i),pwp(i)]= corr(meltratecp(:,i),snowP(:,i),'rows','complete');
    [rwt(i),pwt(i)]= corr(meltratecp(:,i),snowT(:,i),'rows','complete');
    [rms(i),pms(i)]= corr(meltratecp(:,i),meltstartcp(:,i),'rows','complete');
    [rrwp(i),prwp(i)]= corr(meltraterisingcp(:,i),snowP(:,i),'rows','complete');
    [rrwt(i),prwt(i)]= corr(meltraterisingcp(:,i),snowT(:,i),'rows','complete');
    [rrms(i),prms(i)]= corr(meltraterisingcp(:,i),meltstartcp(:,i),'rows','complete');
    [rfwp(i),pfwp(i)]= corr(meltratefallingcp(:,i),snowP(:,i),'rows','complete');
    [rfwt(i),pfwt(i)]= corr(meltratefallingcp(:,i),snowT(:,i),'rows','complete');
    [rfms(i),pfms(i)]= corr(meltratefallingcp(:,i),meltstartcp(:,i),'rows','complete');    
end
[rwp; rwt; rms]
[pwp; pwt; pms]

[rrwp; rrwt; rrms]
[prwp; prwt; prms]

[rfwp; rfwt; rfms]
[pfwp; pfwt; pfms]
%% MR scatters- each catchment on separate panel
fig = figure;
for i =1:12
    subplot(3,4,i)
    plot(snowP(:,i),meltratecp(:,i),'o')
    lsline;
    title(catchnames(i))
end

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Melt Rate (mm/day)');
xlabel(han,'Winter Precipitation (mm)');
ax = gca;
ax.FontSize = 14;

%% calculate percent deviation from mean
devmr = nan(118,12);
devmrn = nan(118,12);
devwp = nan(118,12);
devwt = nan(118,12);
devms = nan(118,12);
devwy = nan(118,12);
devbf = nan(118,12);
devq = nan(118,12);

for i =1:12
    devmr(:,i) = (meltratecp(:,i)- nanmean(meltratecp(:,i)))./nanmean(meltratecp(:,i)).*100;
    devmrn(:,i) = (nmrcp(:,i)- nanmean(nmrcp(:,i)))./nanmean(nmrcp(:,i)).*100;
    devwp(:,i) = (snowP(:,i)- nanmean(snowP(:,i)))./nanmean(snowP(:,i)).*100;
    devwt(:,i) = (snowT(:,i)- nanmean(snowT(:,i)))./nanmean(snowT(:,i)).*100;
    devms(:,i) = (meltstartcp(:,i)- nanmean(meltstartcp(:,i)))./nanmean(meltstartcp(:,i)).*100;
    devwy(:,i) = (wy(:,i)- nanmean(wy(:,i)))./nanmean(wy(:,i)).*100;
    devbf(:,i) = (allbaseflow(:,i)- nanmean(allbaseflow(:,i)))./nanmean(allbaseflow(:,i)).*100;
    devq(:,i) = (q(:,i)- nanmean(q(:,i)))./nanmean(q(:,i)).*100;
end    

% predict wy with bf and melt rate deviations from mean
%bf and nmr
Bwydev = nan(3,ncatch);
Rwydev = nan(118,ncatch);
Swydev = nan(4,ncatch);
for i =1:ncatch
    [Bwydev(:,i),~,Rwydev(:,i),~,Swydev(:,i)] = regress(devwy(:,i),[devbf(:,i) devmrn(:,i) ones(118,1)]);
end


estwydev = devbf.*Bwydev(1,:) + devmrn.*Bwydev(2,:) + Bwydev(3,:);

%% plot timeseries of dev mean WY + storage, WY + melt, WY storage + melt
% all on separate figures

figure;
plot(1901:2018,nanmean(devwy,2),'b','LineWidth',2); hold on
plot(1901:2018, nanmean(devbf,2),'r','LineWidth',2);
xlabel('Water Year'); ylabel('% Deviation from Mean')
ylim([-100 200])
legend('Runoff Efficiency','Storage')

figure;
plot(1901:2018,nanmean(devwy,2),'b','LineWidth',2); hold on
plot(1901:2018, nanmean(devmr,2),'color',[0.85 0.33 0.09],'LineWidth',2);
xlabel('Water Year'); ylabel('% Deviation from Mean')
ylim([-100 200])
legend('Runoff Efficiency','Melt Rate')

figure;
plot(1901:2018,nanmean(devwy,2),'b','LineWidth',2); hold on
plot(1901:2018, nanmean(estwydev,2),'k','LineWidth',2);
xlabel('Water Year'); ylabel('% Deviation from Mean')
ylim([-100 200])
legend('Runoff Efficiency','Storage + Melt Rate')


%% plot timeseries of dev mean WY + storage, WY + melt, WY storage + melt, with variability shown
% all on separate figures

figure;
plot(1901:2018,nanmean(devwy,2),'b','LineWidth',2); hold on
plot(1901:2018,nanmean(devwy,2)+nanstd(devwy,0,2),'.b','LineWidth',1.5);
plot(1901:2018,nanmean(devwy,2)-nanstd(devwy,0,2),'.b','LineWidth',1.5);

plot(1901:2018, nanmean(devbf,2),'r','LineWidth',2);
xlabel('Water Year'); ylabel('% Deviation from Mean')
ylim([-100 200])
legend('Runoff Efficiency','Storage')

figure;
plot(1901:2018,nanmean(devwy,2),'b','LineWidth',2); hold on
plot(1901:2018, nanmean(devmr,2),'color',[0.85 0.33 0.09],'LineWidth',2);
xlabel('Water Year'); ylabel('% Deviation from Mean')
ylim([-100 200])
legend('Runoff Efficiency','Melt Rate')

figure;
plot(1901:2018,nanmean(devwy,2),'b','LineWidth',2); hold on
plot(1901:2018, nanmean(estwydev,2),'k','LineWidth',2);
xlabel('Water Year'); ylabel('% Deviation from Mean')
ylim([-100 200])
legend('Runoff Efficiency','Storage + Melt Rate')

%% MR scatters vs P,T,MS- each catchment on separate panel
fig = figure;
for i =1:12
    subplot(3,4,i)
    plot(snowP(:,i),meltratecp(:,i),'bo')
    title(catchnames(i))
end

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Melt Rate (mm/day)');
xlabel(han,'Winter Precipitation (mm)');
ax = gca;
ax.FontSize = 14;

fig = figure;
for i =1:12
  subplot(3,4,i)
    if i == 8 || i==10
continue
    else
    plot(snowT(:,i),meltratecp(:,i),'ro')
    title(catchnames(i))
    end
    
end

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Melt Rate (mm/day)');
xlabel(han,'Winter/Spring Temperature (C)');
ax = gca;
ax.FontSize = 14;

fig = figure;
for i =1:12
    subplot(3,4,i)
    plot(meltstartcp(:,i),meltratecp(:,i),'ko')
    title(catchnames(i))
end

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Melt Rate (mm/day)');
xlabel(han,'Melt Start (DOY)');
ax = gca;
ax.FontSize = 14;

%% MR rising and falling scatters vs P,T,MS- each catchment on separate panel
fig = figure;
for i =1:12
    subplot(3,4,i)
    plot(snowP(:,i),meltraterisingcp(:,i),'bo')
    title(catchnames(i))
end

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Melt Rate (Rising limb mm/day)');
xlabel(han,'Winter Precipitation (mm)');
ax = gca;
ax.FontSize = 14;

fig = figure;
for i =1:12
  subplot(3,4,i)
    if i == 8 || i==10
continue
    else
    plot(snowT(:,i),meltraterisingcp(:,i),'ro')
    title(catchnames(i))
    end
    
end

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Melt Rate (Rising Limb mm/day)');
xlabel(han,'Winter/Spring Temperature (C)');
ax = gca;
ax.FontSize = 14;

fig = figure;
for i =1:12
    subplot(3,4,i)
    plot(meltstartcp(:,i),meltraterisingcp(:,i),'ko')
    title(catchnames(i))
end

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Melt Rate (Rising Limb mm/day)');
xlabel(han,'Melt Start (DOY)');
ax = gca;
ax.FontSize = 14;
%% MR vs WP,WT,and MS, average and standard deviation of each
figure;
subplot(1,3,1)
errorbar(nanmean(snowP),nanmean(meltratecp),nanstd(meltratecp),nanstd(meltratecp),nanstd(snowP),nanstd(snowP),'o','MarkerEdgeColor','b','MarkerFaceColor','b')
xlabel('Winter Precipitation (mm)'); ylabel('Melt Rate (mm/day)')
ax = gca;
ax.FontSize = 14;
subplot(1,3,2)
errorbar(nanmean(snowT),nanmean(meltratecp),nanstd(meltratecp),nanstd(meltratecp),nanstd(snowT),nanstd(snowT),'o','MarkerEdgeColor','r','MarkerFaceColor','r')
xlabel('Winter/Spring Temperature  (C)'); ylabel('Melt Rate (mm/day)')
ax = gca;
ax.FontSize = 14;
subplot(1,3,3)
errorbar(nanmean(meltstartcp),nanmean(meltratecp),nanstd(meltratecp),nanstd(meltratecp),nanstd(meltstartcp),nanstd(meltstartcp),'o','MarkerEdgeColor','k','MarkerFaceColor','k')
xlabel('Melt Start (DOY)'); ylabel('Melt Rate (mm/day)'); xlim([140 230])
ax = gca;
ax.FontSize = 14;


%% MR vs WP,WT,MS, and PET: average and standard deviation of each- diff color markers
figure;
subplot(2,1,1)
for i =1:12
errorbar(nanmean(snowP(:,i)),nanmean(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(snowP(:,i)),nanstd(snowP(:,i)),...
    'o','color','k','MarkerEdgeColor',c{i},'MarkerFaceColor',c{i})
hold on
end
xlabel('Winter Precipitation (mm)'); ylabel('Melt Rate (mm/day)')
ax = gca;
% ax.FontSize = 14;

subplot(2,1,2)
for i =1:12
errorbar(nanmean(snowT(:,i)),nanmean(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(snowT(:,i)),nanstd(snowT(:,i)),...
    'o','color','k','MarkerEdgeColor',c{i},'MarkerFaceColor',c{i})
hold on
end
xlabel('Winter/Spring Temperature  (C)'); ylabel('Melt Rate (mm/day)')
ax = gca;
% ax.FontSize = 14;

% exclude PET for now
% subplot(2,2,3)
% for i =1:12
% errorbar(lscape(23,i),nanmean(meltratecp(:,i)),nanstd(meltratecp(:,i)),...
%     'o','color','k','MarkerEdgeColor',c{i},'MarkerFaceColor',c{i})
% hold on
% end
% xlabel('PET/P'); ylabel('Melt Rate (mm/day)')
% ax = gca;
% ax.FontSize = 14;

% subplot(3,1,3)
% for i =1:12
% plot(0,0,'o','markerfacecolor',c{i},'markeredgecolor',c{i}); hold on %necessary so error bars dont show up in legend icons
% errorbar(nanmean(meltstartcp(:,i)),nanmean(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(meltstartcp(:,i)),nanstd(meltstartcp(:,i))...
%     ,'o','color','k','MarkerEdgeColor',c{i},'MarkerFaceColor',c{i},'handlevisibility','off')
% end
% xlabel('Melt Start (DOY)'); ylabel('Melt Rate (mm/day)'); xlim([140 230])
% ax = gca;
% % ax.FontSize = 14;

%% MR vs WP,WT,and MS, average and standard deviation of each- diff color markers
figure;
subplot(1,3,1)
for i =1:12
errorbar(nanmean(snowT(:,i)),nanmean(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(snowT(:,i)),nanstd(snowT(:,i)),...
    'o','color','k','MarkerEdgeColor',c{i},'MarkerFaceColor',c{i})
hold on
end
xlabel(['Winter/Spring Temperature  (' char(176) 'C)']); ylabel('Melt Rate (mm/day)')
ax = gca;
ax.FontSize = 14;

subplot(1,3,2)
for i =1:12
errorbar(nanmean(snowP(:,i)),nanmean(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(snowP(:,i)),nanstd(snowP(:,i)),...
    'o','color','k','MarkerEdgeColor',c{i},'MarkerFaceColor',c{i})
hold on
end
xlabel('Winter Precipitation (mm)'); ylabel('Melt Rate (mm/day)')
ax = gca;
ax.FontSize = 14;

subplot(1,3,3)
for i =1:12
plot(0,0,'o','markerfacecolor',c{i},'markeredgecolor',c{i}); hold on %necessary so error bars dont show up in legend icons
errorbar(nanmean(meltstartcp(:,i)),nanmean(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(meltratecp(:,i)),nanstd(meltstartcp(:,i)),nanstd(meltstartcp(:,i))...
    ,'o','color','k','MarkerEdgeColor',c{i},'MarkerFaceColor',c{i},'handlevisibility','off')
end
xlabel('Melt Start (DOY)'); ylabel('Melt Rate (mm/day)'); xlim([140 230])
ax = gca;
ax.FontSize = 14;
legend(catchnames)

%% Spatial patterns: regressions to predict mean melt rate with T, P, and MS

[BspatialT,~,RspatialT,~,SspatialT] = regress(nanmean(meltratecp)',[nanmean(snowT)' ones(12,1)])
[BspatialP,~,RspatialP,~,SspatialP] = regress(nanmean(meltratecp)',[nanmean(snowP)' ones(12,1)])
[BspatialMS,~,RspatialMS,~,SspatialMS] = regress(nanmean(meltratecp)',[(nanmean(meltstartcp).^2)' ones(12,1)])

[BspatialTP,~,RspatialTP,~,SspatialTP] = regress(nanmean(meltratecp)',[nanmean(snowP)' nanmean(snowT)' ones(12,1)])

% plot T + P in MLR to predict avg melt rate
figure;
scatter(nanmean(snowP).*BspatialTP(1) + nanmean(snowT).*BspatialTP(2) + BspatialTP(3), nanmean(meltratecp),50,cmat,'filled');
xlabel('Predicted Mean Melt Rate (mm/day)'); ylabel('Observed Mean Melt Rate (mm/day)');
ax = gca;
% ax.FontSize = 14;

%% bar chart showing loadings of regression coefficients

%% bootstrap regression coefficients (assume random X- better way)
%bootstrap 1000 times to find distribution of beta coefficients
x = [nanmean(snowP)' nanmean(snowT)']; y = nanmean(meltratecp)';
n = length(x);
for i=1:1000 % use randsample
  %disp(i);
  si = randsample(n,n,'true'); 
  bb = regress(y(si),[x(si,:) ones(n,1)]); 
  s(i,1:2) = bb(1:2)'; 
end;

%plot the distribution of b1 and the 95% and 99% confidence intervals
figure(1); 
subplot(1,2,1)
h = histogram(s(:,1)); 
hold on;
yl = get(gca,'ylim'); yl = yl(2); 
plot([prctile(s(:,1),97.5) prctile(s(:,1),97.5)],[0 yl],'r-','linewidth',1.5); 
plot([prctile(s(:,1),2.5) prctile(s(:,1),2.5)],[0 yl],'r-','linewidth',1.5);
xlabel('Beta Coefficient'); ylabel('Occurances');
% xlim([0 .03]); 
ylim([0 yl])
% width = 300; height = 200;
% set(gcf,'position',[100,100,width,height])

ci1 = [prctile(s(:,1),2.5) prctile(s(:,1),97.5)]

subplot(1,2,2)
h = histogram(s(:,2)); 
hold on;
yl = get(gca,'ylim'); yl = yl(2); 
plot([prctile(s(:,2),97.5) prctile(s(:,2),97.5)],[0 yl],'r-','linewidth',1.5); 
plot([prctile(s(:,2),2.5) prctile(s(:,2),2.5)],[0 yl],'r-','linewidth',1.5);
xlabel('Beta Coefficient'); ylabel('Occurances');
% xlim([0 .03]); 
ylim([0 yl])
% width = 300; height = 200;
% set(gcf,'position',[100,100,width,height])

ci2 = [prctile(s(:,2),2.5) prctile(s(:,2),97.5)]
%% bootstrap  regression coefficients (using residuals- don't use this way)
% enter variables to be regressed here:
x = [ones(12,1) nanmean(snowP)' nanmean(snowT)'];
y = nanmean(meltratecp)';

b = regress(y,x);
yfit = x*b;
resid = y - yfit;

ci = bootci(1000,{@(bootr)regress(yfit+bootr,x),resid}, ...
    'Type','normal')

slopes = b(2:end)';
lowerBarLengths = slopes-ci(1,2:end);
upperBarLengths = ci(2,2:end)-slopes;
errorbar(1:2,slopes,lowerBarLengths,upperBarLengths)
xlim([0 5])
title('Coefficient Confidence Intervals')
%% stepwise regression to predict melt rate
for i =1:12
    stepwise([meltstartcp(:,i) meltstartcp(:,i).^2], meltraterisingcp(:,i))
end
% results
% WP only- W-LC
% WP + WT + MS- W-OSF only
% WP = MS- all other catchments

%% regress wp, wt, and ms to predict melt rate

Bmr1 = nan(2,12);
Rmr1 = nan(118,12);
Smr1 = nan(4,12);

for i =1:12
    [Bmr1(:,i),~,Rmr1(:,i),~,Smr1(:,i)] = regress(meltratecp(:,i),[snowP(:,i) ones(118,1)]);
end

% melt start vs melt rate
Bmrms = nan(2,12);
Rmrms = nan(118,12);
Smrms = nan(4,12);

for i =1:12
    [Bmrms(:,i),~,Rmrms(:,i),~,Smrms(:,i)] = regress(meltratecp(:,i),[meltstartcp(:,i) ones(118,1)]);
end

Bmst = nan(2,12);
Rmst = nan(118,12);
Smst = nan(4,12);

for i =1:12
    [Bmst(:,i),~,Rmst(:,i),~,Smst(:,i)] = regress(meltstartcp(:,i),[snowT(:,i) ones(118,1)]);
end

Btp = nan(2,12);
Rtp = nan(118,12);
Stp = nan(4,12);

for i =1:12
    [Btp(:,i),~,Rtp(:,i),~,Stp(:,i)] = regress(springt(:,i),[springp(:,i) ones(118,1)]);
end

% residuals of T-P vs. melt start
Bmstp = nan(2,12);
Rmstp = nan(118,12);
Smstp = nan(4,12);

for i =1:12
    [Bmstp(:,i),~,Rmstp(:,i),~,Smstp(:,i)] = regress(meltstartcp(:,i),[Rtp(:,i) ones(118,1)]);
end

Bmr2 = cell(1,12);
Rmr2 = nan(118,12);
Smr2 = nan(4,12);

for i =1:12
    if i == 10
        [Bmr2{i},~,Rmr2(:,i),~,Smr2(:,i)] = regress(meltratecp(:,i),[snowP(:,i) ones(118,1)]);
    else
        [Bmr2{i},~,Rmr2(:,i),~,Smr2(:,i)] = regress(meltratecp(:,i),[snowP(:,i) meltstartcp(:,i) ones(118,1)]);
    end
end

Bmr3 = cell(1,12);
Rmr3 = nan(118,12);
Smr3 = nan(4,12);

for i =1:12
    if i == 10
        [Bmr3{i},~,Rmr3(:,i),~,Smr3(:,i)] = regress(meltratecp(:,i),[snowP(:,i) ones(118,1)]);
    elseif i == 11
        [Bmr3{i},~,Rmr3(:,i),~,Smr3(:,i)] = regress(meltratecp(:,i),[snowP(:,i) meltstartcp(:,i) snowT(:,i) ones(118,1)]);
    else
        [Bmr3{i},~,Rmr3(:,i),~,Smr3(:,i)] = regress(meltratecp(:,i),[snowP(:,i) meltstartcp(:,i) ones(118,1)]);
    end
end

% use just WP and MS for all catchments
Bmr4 = nan(3,12);
Rmr4 = nan(118,12);
Smr4 = nan(4,12);

for i =1:12
        [Bmr4(:,i),~,Rmr4(:,i),~,Smr4(:,i)] = regress(meltratecp(:,i),[snowP(:,i) meltstartcp(:,i) ones(118,1)]);
end

% use just WP and MS for all catchments (z scored)
Bzmr4 = nan(3,12);
Rzmr4 = nan(118,12);
Szmr4 = nan(4,12);

for i =1:12
        [Bzmr4(:,i),~,Rzmr4(:,i),~,Szmr4(:,i)] = regress(zmrcp(:,i),[zsnowp(:,i) zmscp(:,i) ones(118,1)]);
end
% z-score residuals from wp + ms regression
zresid = (Rmr4 - nanmean(Rmr4))./nanstd(Rmr4);

% estimate wy using storage and mr (norm for wp and ms)
Bznwy3 = nan(3,ncatch);
Rznwy3 = nan(118,ncatch);
Sznwy3 = nan(4,ncatch);
for i =1:ncatch
    [Bznwy3(:,i),~,Rznwy3(:,i),~,Sznwy3(:,i)] = regress(zwy(:,i),[zbf(:,i) zresid(:,i) ones(118,1)]);
end


estnwy3 = zbf.*Bznwy3(1,:) + zresid.*Bznwy3(2,:) + Bznwy3(3,:);

%% estimate Q using P + MR (norm) and P + MR + storage
BznQ = nan(3,ncatch);
RznQ = nan(118,ncatch);
SznQ = nan(4,ncatch);
for i =1:ncatch
    [BznQ(:,i),~,RznQ(:,i),~,SznQ(:,i)] = regress(zq(:,i),[zp(:,i) zresid(:,i) ones(118,1)]);
end

BznQ2 = nan(4,ncatch);
RznQ2 = nan(118,ncatch);
SznQ2 = nan(4,ncatch);
for i =1:ncatch
    [BznQ2(:,i),~,RznQ2(:,i),~,SznQ2(:,i)] = regress(zq(:,i),[zp(:,i) zresid(:,i) zbf(:,i) ones(118,1)]);
end

BznQ3 = nan(3,ncatch);
RznQ3 = nan(118,ncatch);
SznQ3 = nan(4,ncatch);
for i =1:ncatch
    [BznQ3(:,i),~,RznQ3(:,i),~,SznQ3(:,i)] = regress(zq(:,i),[zp(:,i) zbf(:,i) ones(118,1)]);
end
estnQ = zp.*BznQ(1,:) + zresid.*BznQ(2,:) + BznQ(3,:);
estnQ2 = zp.*BznQ2(1,:) + zresid.*BznQ2(2,:) + zbf.*BznQ2(3,:) + BznQ2(4,:);
estnQ3 = zp.*BznQ3(1,:) + zbf.*BznQ3(2,:) + BznQ3(3,:);

%% plot (scatter)- series of previously calculated regressions

figure; 
subplot(1,2,1)
plot(snowP, meltratecp,'o')
xlabel('Winter Precipitation (mm)'); ylabel('Melt Rate (mm/day)')
ax = gca;
ax.FontSize = 14;
subplot(1,2,2)
plot(snowP.*Bmr4(1,:) + meltstartcp.*Bmr4(2,:) + Bmr4(3,:),meltratecp,'o')
xlabel('Winter Precipitation + Melt Start Day'); ylabel('Melt Rate (mm/day)')
xlim([0 15])
ax = gca;
ax.FontSize = 14;
legend(catchnames)

%% plot (scatter)- series of previously calculated regressions, color match to other figure

figure; 
subplot(1,2,1)
for i =1:12
    plot(snowP(:,i), meltratecp(:,i),'o','color',c{i}); hold on
end
xlabel('Winter Precipitation (mm)'); ylabel('Melt Rate (mm/day)')
ax = gca;
ax.FontSize = 14;
subplot(1,2,2)
for i=1:12
    plot(snowP(:,i).*Bmr4(1,i) + meltstartcp(:,i).*Bmr4(2,i) + Bmr4(3,i),meltratecp(:,i),'o','color',c{i}); hold on
end
xlabel('Winter Precipitation + Melt Start Day'); ylabel('Melt Rate (mm/day)')
xlim([0 15])
ax = gca;
ax.FontSize = 14;
legend(catchnames)

%% plot (scatter)- series of previously calculated relationships, color match to other figure
% not MLR, just individual

figure; 
subplot(1,3,1)
for i =1:12
    plot(snowP(:,i), meltratecp(:,i),'o','color',c{i}); hold on
end
xlabel('Winter Precipitation (mm)'); ylabel('Melt Rate (mm/day)')
ax = gca;
ax.FontSize = 14;
subplot(1,3,2)
for i=1:12
    plot(meltstartcp(:,i), meltratecp(:,i),'o','color',c{i}); hold on
end
xlabel('Melt Start Day'); ylabel('Melt Rate (mm/day)')
ax = gca;
ax.FontSize = 14;
legend(catchnames)
subplot(1,3,3)

% adding in winter T
for i=1:12
    plot(snowT(:,i), meltratecp(:,i),'o','color',c{i}); hold on
end
xlabel('Winter/Spring T'); ylabel('Melt Rate (mm/day)')
ax = gca;
ax.FontSize = 14;

% adding in winter T new figure vs melt start
figure;
for i=1:12
    plot(Rtp(:,i), meltstartcp(:,i),'o','color',c{i}); hold on
end
xlabel('Winter/Spring T (norm for P)'); ylabel('Melt Start (DOY)')
ax = gca;
ax.FontSize = 14;

%% adding in winter T (norm for winterP) new figure vs melt start
fig=figure;
for i=1:12
    subplot(3,4,i)
    if (i==8 || i==10)
    plot(Rtp(:,i), meltstartcp(:,i),'o','color',c{i}); 
    title(catchnames(i))
    else
        plot(Rtp(:,i), meltstartcp(:,i),'o','color',c{i}); 
        ls = lsline; set(ls(1),'color', c{i});
        title(catchnames(i))
    end
    xlim([-5 5]); ylim([100 250]);
end
% xlabel('Winter/Spring T (norm for P)'); ylabel('Melt Start (DOY)')

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
xlabel(han,'Spring Temperature (Normalized for Precipitation)');
ylabel(han,'Melt Start Day (DOY)');

%% bootstrap previous relationships - same results as above (all significant except WLC and WECJ)
x = Rtp; y = meltstartcp;
n = length(x);
for i =1:12
    %bootstrap 1000 times to find distribution of b1
    for j=1:1000 % use randsample
        %disp(i);
        si = randsample(n,n,'true');
        bb = regress(y(si,i),[x(si,i) ones(n,1)]);
        s(j,i) = bb(1);
    end
end
for i =1:12
    figure;
    h = histogram(s(:,i));
    hold on;
    yl = get(gca,'ylim'); yl = yl(2);
    plot([prctile(s(:,i),99.5) prctile(s(:,i),99.5)],[0 yl],'r-');
    plot([prctile(s(:,i),.5) prctile(s(:,i),.5)],[0 yl],'r-');
    plot([prctile(s(:,i),97.5) prctile(s(:,i),97.5)],[0 yl],'b-');
    plot([prctile(s(:,i),2.5) prctile(s(:,i),2.5)],[0 yl],'b-');
end
%% plot previous regressions individually
figure;
for i=1:12
    subplot(4,3,i)
    plot(snowP(:,i).*Bmr4(1,i) + meltstartcp(:,i).*Bmr4(2,i) + Bmr4(3,i),meltratecp(:,i),'o','color',c{i}); 
    title(catchnames(i))
    xlabel('Winter Precipitation + Melt Start Day'); ylabel('Melt Rate (mm/day)')
end

%% bar plot showing beta coefficients for z-scored winter p and melt start
figure; 
bar([Bzmr4(1,:)' Bzmr4(2,:)'])
legend('Winter Precip','Melt Start Day')
xticklabels(catchnames)


%% determine relationships between coefficients and landscape/climate
[wpcor, wprho] = corr(lscape',Bzmr4(1,:)');
[mscor,msrho] = corr(lscape',Bzmr4(2,:)');
[mstpcor,mstprho] = corr(lscape(:,[1:7,9,11:12])',Bmstp(1,[1:7,9,11:12])');% exclude ECJ and W-LC as those slopes weren't sig
[mstpcorr2,mstprhor2] = corr(lscape',Smstp(1,:)');
[ratiocor,ratiorho] = corr(lscape',(Bzmr4(1,:)./Bzmr4(2,:))');
[mrpcor, mrprho] = corr(lscape',Smr1(1,:)');
[mrpmscor, mrpmsrho] = corr(lscape',(Smr4(1,:)-Smr1(1,:))');

wpsig = wpcor; wpsig(wprho>0.05)=0;
mssig = mscor; mssig(msrho>0.05)=0;
mstpsig = mstpcor; mstpsig(mstprho>0.05)=0;
mstpsigr2 = mstpcorr2; mstpsigr2(mstprhor2>0.05)=0;
ratiosig = ratiocor; ratiosig(ratiorho>0.05)=0;
mrpsig = mrpcor; mrpsig(mrprho>0.05)=0;
mrpmssig = mrpmscor; mrpmssig(mrpmsrho>0.05)=0;

%% scatter plot of slope of T-MS regressions vs elevation and temperature
% exclude ECJ and W-LC as those slopes weren't sig
figure;
subplot(1,2,1)
scatter(lscape(2,[1:7,9,11:12]),Bmstp(1,[1:7,9,11:12]),[],cmat([1:7,9,11:12],:),'filled'); 
xlabel('Mean Elevation (m)'); ylabel({'Change in Melt'; ['Start Day per ' char(176) 'C']});
xlim([1800 3000]); ylim([-9 -1])
ls = lsline; ls.LineWidth = 1;

subplot(1,2,2)
scatter(lscape(27,[1:7,9,11:12]),Bmstp(1,[1:7,9,11:12]),[],cmat([1:7,9,11:12],:),'filled'); 
xlabel(['Mean Winter/Spring Temperature (' char(176) 'C)']); 
ls = lsline; ls.LineWidth = 1;
% xlim([2 8]); ylim([-9 -1])

% subplot(1,3,3)
% plot(nanmean(meltstartcp(:,[1:7,9,11:12])),Bmstp(1,[1:7,9,11:12]),'o'); lsline;
% xlabel('Mean Melt Start Day'); 
% xlim([170 220]); ylim([-9 -1])

%% regression between mean temp and change in MS per deg C
% exclude ECJ and W-LC as those slopes weren't sig

[BBtms,~,RBtms,~,SBtms] = regress(Bmstp(1,[1:7,9,11:12])',[lscape(27,[1:7,9,11:12])' ones(10,1)]);


% BBtms is second derivative of function of temp vs melt start date: MS'' = BBtms
% integrate: MS' = BBtms(1)(t) + BBtms(2), where t = mean annual
% temperature. this is just regression equation calculated above.
% integrate again: MS = BBtms(1)/2 (t^2) + BBtms(2)(t) + C
% C is difference between 0 and where catchment's mean annual temp lies on
% this curve plus catchment's mean melt start date

MAT = nanmean(t);
offset = BBtms(1)./2.*MAT.^2 + BBtms(2).*MAT; % these are the amounts needed to "center" each catchment at 0 days change in melt start (when T = MAT)
% set constants based on offset and mean melt start day
C = nanmean(meltstartcp) - offset; % subtract because offsets are negative values

% round MAT to nearest 0.25 degree
MATrnd = round(MAT.*4)/4;

% fill projected temperature matrix with 0.25 deg intervals, starting from
% MAT and going to MAT + 4 degrees
projtemps = nan(9,12);
for i =1:12
    projtemps(:,i) = (MATrnd(i): 0.5: MATrnd(i)+4)'; % temperature range must be set according to catchment
end


%% plot up each catchment's predicted change in melt start 
fig=figure;
for i =1:12
    subplot(3,4,i)
    if i==8 ||i==10
        continue
    else
    plot(projtemps(:,i),(BBtms(1).*(projtemps(:,i).^2)./2)+ (BBtms(2).*projtemps(:,i)) + C(i),'color',c{i},'LineWidth',1.5)
    xlim([projtemps(1,i) projtemps(end,i)]);
    xticks([projtemps(1,i) :1 : projtemps(end,i)]);
    xticklabels([0:1:4]);
    title(catchnames(i))
    end
end
% x axis is increase in MAT (deg C)
% y- axis is predicted MS day (DOY)

han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
xlabel(han,['Increase in Mean Annual Temperature (' char(176) 'C)']);
ylabel(han,'Predicted Melt Start Day (DOY)');
%% plot up each catchment's predicted change in melt start 
% inverted so that change in melt increases along y-axis
% also start each catchment from 0, not average melt start day
% exclude W-ECJ and W-LC
fig=figure;
for i =1:12
    if i==8 ||i==10
        continue
    elseif i<=7
    subplot(3,4,i)
    plot(projtemps(:,i),-((BBtms(1).*(projtemps(:,i).^2)./2)+ (BBtms(2).*projtemps(:,i))-offset(i)) ,'color',c{i},'LineWidth',2)
    xlim([projtemps(1,i) projtemps(end,i)]); 
    xticks([projtemps(1,i) :1 : projtemps(end,i)]);
    xticklabels([0:1:4]);
    ylim([0 40]); yticks([0:10:40]);
    title(catchnames(i))
    elseif i==9
    subplot(3,4,8)
    plot(projtemps(:,i),-((BBtms(1).*(projtemps(:,i).^2)./2)+ (BBtms(2).*projtemps(:,i))-offset(i)) ,'color',c{i},'LineWidth',2)
    xlim([projtemps(1,i) projtemps(end,i)]); 
    xticks([projtemps(1,i) :1 : projtemps(end,i)]);
    xticklabels([0:1:4]);
    ylim([0 40]); yticks([0:10:40]);
    title(catchnames(i))
    else
    subplot(3,4,i-2)
    plot(projtemps(:,i),-((BBtms(1).*(projtemps(:,i).^2)./2)+ (BBtms(2).*projtemps(:,i))-offset(i)) ,'color',c{i},'LineWidth',2)
    xlim([projtemps(1,i) projtemps(end,i)]);
    xticks([projtemps(1,i) :1 : projtemps(end,i)]);
    xticklabels([0:1:4]);
    ylim([0 40]); yticks([0:10:40]);
    title(catchnames(i))   
    end
end
% x axis is increase in MAT (deg C)
% y- axis is predicted MS day (DOY)

han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
xlabel(han,['\Delta Temperature (' char(176) 'C)']);
ylabel(han,'\Delta Melt Start (Days Earlier)');



%% estimate change in melt rate given x increase in T -> y earlier melt start
%projtemps = MAT + 0 to 4 deg C
estms = -((BBtms(1).*(projtemps.^2)./2)+ (BBtms(2).*projtemps)-offset); % number of days earlier melt may start for 0 to 4 deg warming
% calc new melt start days
newms = nanmean(meltstartcp) - estms;
% calc new melt rates - assuming winter P = avgerage
newmr = Bmr4(1,:).*nanmean(snowP) + Bmr4(2,:).*newms + Bmr4(3,:); 

% calc new runoff eff - assuming BF = average
newwy = Bwy(1,:).*nanmean(allbaseflow) + Bwy(2,:).*newmr + Bwy(3,:);

% calc percent change from average water yield
wychange = (newwy - nanmean(wy))./nanmean(wy);

%% plot change in water yield given 0 to 4 deg warming

fig=figure;
for i =1:12
    if i==8 ||i==10
        continue
    elseif i<=7
        subplot(3,4,i)
        plot(projtemps(:,i),wychange(:,i).*100,'color',c{i},'LineWidth',1.5)
        xlim([projtemps(1,i) projtemps(end,i)]);
        xticks([projtemps(1,i) :1 : projtemps(end,i)]);
        xticklabels([0:1:4]);
        ylim([-35 05])
        title(catchnames(i))
    elseif i==9
        subplot(3,4,8)
        plot(projtemps(:,i),wychange(:,i).*100,'color',c{i},'LineWidth',1.5)
        xlim([projtemps(1,i) projtemps(end,i)]);
        xticks([projtemps(1,i) :1 : projtemps(end,i)]);
        xticklabels([0:1:4]);
        ylim([-35 05])
        title(catchnames(i))
    else
        subplot(3,4,i-2)
        plot(projtemps(:,i),wychange(:,i).*100,'color',c{i},'LineWidth',1.5)
        xlim([projtemps(1,i) projtemps(end,i)]);
        xticks([projtemps(1,i) :1 : projtemps(end,i)]);
        xticklabels([0:1:4]);
        ylim([-35 05])
        title(catchnames(i))
    end
end
% x axis is increase in MAT (deg C)
% y- axis is predicted MS day (DOY)

han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
xlabel(han,['\Delta Temperature (' char(176) 'C)']);
ylabel(han,'\Delta Runoff Efficiency (%)');

%% plot change in water yield given 0 to 4 deg warming
% supply catchments only for SLCDPU

fig=figure;
for i =1:7
    if i==2 ||i==3||i==5
        continue
    elseif i==1
        subplot(2,2,i)
        plot(projtemps(:,i),wychange(:,i).*100,'color',c{i},'LineWidth',1.5) % times 100 for percent instead of decimal
        xlim([projtemps(1,i) projtemps(end,i)]);
        xticks([projtemps(1,i) :1 : projtemps(end,i)]);
        xticklabels([0:1:4]);
        ylim([-27 05])
        title(catchnames(i))
    elseif i==4
        subplot(2,2,2)
        plot(projtemps(:,i),wychange(:,i).*100,'color',c{i},'LineWidth',1.5)
        xlim([projtemps(1,i) projtemps(end,i)]);
        xticks([projtemps(1,i) :1 : projtemps(end,i)]);
        xticklabels([0:1:4]);
        ylim([-27 05])
        title(catchnames(i))
    else
        subplot(2,2,i-3)
        plot(projtemps(:,i),wychange(:,i).*100,'color',c{i},'LineWidth',1.5)
        xlim([projtemps(1,i) projtemps(end,i)]);
        xticks([projtemps(1,i) :1 : projtemps(end,i)]);
        xticklabels([0:1:4]);
        ylim([-27 05])
        title(catchnames(i))
    end
end
% x axis is increase in MAT (deg C)
% y- axis is predicted MS day (DOY)

han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
xlabel(han,['\Delta Temperature (' char(176) 'C)']);
ylabel(han,'\Delta Runoff Efficiency (%)');
%%
figure; plot(projtemps,(BBtms(1).*(projtemps.^2)./2)+ (BBtms(2).*projtemps) ) %scale so that no change in annual T = long term mean Melt Start day
xlabel(['Mean Annual Temperature (' char(176) 'C)']);
% xticklabels([0 :0.5: 4])
ylabel('Predicted Melt Start Day (DOY)');
% title('J-BC')

%% plot time series of WY and predicted WY using MR (norm for wp and ms) and storage
figure;
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(zresid,2),'LineWidth',2);
plot(1901:2018, nanmean(estnwy3,2),'LineWidth',2);
xlabel('Water Year'); ylabel('z-score'); ylim([-3 4])
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Melt Rate (normalized)','Storage + Melt Rate (normalized)','location','southeast')

%% plot time series of Q and predicted Q using P, MR (norm for wp and ms), and storage
figure;
subplot(3,1,1)
plot(1901:2018,nanmean(zq,2),'LineWidth',1.5); hold on
plot(1901:2018,nanmean(zp,2),'LineWidth',1.5);
legend('Streamflow', 'Precipitation','location','north')
ylabel('z-score'); ylim([-2 3])
subplot(3,1,2)
plot(1901:2018,nanmean(zq,2),'LineWidth',1.5); hold on
plot(1901:2018, nanmean(estnQ3,2),'LineWidth',1.5);
legend('Streamflow', 'Precipitation + Storage','location','north')
ylabel('z-score'); ylim([-2 3])
subplot(3,1,3)
plot(1901:2018,nanmean(zq,2),'LineWidth',1.5); hold on
plot(1901:2018, nanmean(estnQ2,2),'LineWidth',1.5);
legend('Streamflow', 'Precipitation + Melt + Storage','location','north')

xlabel('Water Year'); ylabel('z-score'); ylim([-2 3])
% ax = gca;
% ax.FontSize = 12;

%% Changes over time
% Is melt changing? Over entire record or since mid 80s?
% entire record
Bmrtime = nan(2,12);
Bmstime = nan(2,12);
Smrtime = nan(4,12);
Smstime = nan(4,12);
for i =1:12
    [Bmrtime(:,i),~,~,~,Smrtime(:,i)] = regress(t(:,i), [(1901:2018)' ones(118,1)]);
    [Bmstime(:,i),~,~,~,Smstime(:,i)] = regress(t(:,i), [(1901:2018)' ones(118,1)]);
end
% since 1985
Bmrtime2 = nan(2,12);
Bmstime2 = nan(2,12);
Smrtime2 = nan(4,12);
Smstime2 = nan(4,12);
for i =1:12
    [Bmrtime2(:,i),~,~,~,Smrtime2(:,i)] = regress(t(85:end,i), [(1985:2018)' ones(34,1)]);
    [Bmstime2(:,i),~,~,~,Smstime2(:,i)] = regress(t(85:end,i), [(1985:2018)' ones(34,1)]);
end