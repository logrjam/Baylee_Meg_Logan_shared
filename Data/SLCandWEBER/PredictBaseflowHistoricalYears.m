close all
clear all

disp('All Creeks MLR to predict baseflow Previous Years(SLC and Weber ')
disp('Jan 2020 ')
disp(' Meg Wolf')
disp(' Multiple Linear Regression of Multiple years of Climate on Baseflow(groundwater variability)')

load('allprecip.mat')
load('allbaseflow.mat')
load('allmeltrate.mat')
load('allmeltduration.mat')
load('allstreamflow.mat')
load('allyield.mat')
load('alltemp.mat')
load('allJanP.mat')
load('allJanT.mat')


%meanJanQ=base1

%load('meltRate.mat') %melt rate Spring of one year before
catchnames = [string('SLC CC'),string('SLC RB'),string('SLC EC'),string('SLC PC')...
    string('SLC MC'),string('SLC BC'),string('SLC LC'),string('WR ECJ'), string('WR CC'),...
    string('WR LC'),string('WR OSF'),string('WR WO')];
ncatch=12;
nyears=1:118;
x1=ones(118,1);
%nCreeks = width(JanQO)-1; % Create width of 7 creeks -1 for the year column
%statsoutput = [];

% Create X variable with variable from Previous Year, 2 years prior, 3 years
% prior...

%% Precip
for j=1:ncatch
p(:,j)=allprecip(:,j)
end
prevP = nan(length(p),11,ncatch); %preallocate matrix

for j = 1:ncatch

    prevP(:,:,j) = repmat(p(:,j),1,11); %fill with p data for each catchment

end

for j=1:ncatch %replace each column of each catchment with previous year's data

    for i = 1:10

        prevP(i+1:end,i+1,j) = prevP(i:end-1,i,j);

        prevP(1:i,i+1,j) = nan;    

    end

end


%% Precip
% %% compute stats on baseflow regression with previous year's metrics 
% precipitation
Pstats=nan(4,10,ncatch); % preallocate: 4 stats, 10 previous years, 12 catchments
P_b = cell(10,ncatch); %preallocate cell array to hold regression coefficients
for j=1:ncatch %regress baseflow against prev Precip, adding one more prev year each time
    for i = 1:10
        [P_b{i,j},~,~,~,Pstats(:,i,j)] = regress(allbaseflow(:,j),[prevP(:,2:i+1,j) ones(length(p),1)]); 
    end
end
%P_b_sign = strings(1,12); %determine positive or negative relationship (first year only)
%% plot precip r^2
% precipitation
ColorSet=varycolor(ncatch)
figure;
for j= 1:ncatch
    plot(0:10, [0 Pstats(1,:,j)],'Color',ColorSet(j,:),'linewidth',3); hold on;% add 0 for 0th year  
  
       
end
xticks(0:10);
xlabel('Previous Years in MLR','fontsize',24);
ylabel('r^2','fontsize',24);
title('Previous Precipitation','fontsize',24);
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=2
ylim([0 1])
xlim([0 5])
set(gca,'fontsize',14)
%% temperature
for j=1:ncatch
t(:,j)=alltemp(:,j)
end
prevT = nan(length(t),11,ncatch);
for j = 1:ncatch
    prevT(:,:,j) = repmat(t(:,j),1,11);
end
for j=1:ncatch
    for i = 1:10
        prevT(i+1:end,i+1,j) = prevT(i:end-1,i,j);
        prevT(1:i,i+1,j) = nan;    
    end
end
%% temp 
% %% compute stats on baseflow regression with previous year's metrics 
% temperature stats
Tstats=nan(4,10,ncatch); % preallocate: 4 stats, 10 previous years, 12 catchments
T_b = cell(10,ncatch); %preallocate cell array to hold regression coefficients
for j=1:ncatch %regress baseflow against prev temperature, adding one more prev year each time
    for i = 1:10
        [T_b{i,j},~,~,~,Tstats(:,i,j)] = regress(allbaseflow(:,j),[prevT(:,2:i+1,j) ones(length(t),1)]); 
    end
end
T_b_sign = strings(1,ncatch); %determine positive or negative relationship (first year only)
%% plot Temp r^2
figure;
for j=1:ncatch
    plot(0:10, [0 Tstats(1,:,j)],'Color',ColorSet(j,:),'linewidth',3); hold on;% add 0 for 0th year  
    
end
xticks(0:10);
xlabel('Previous Years in MLR','fontsize',24);
ylabel('r^2','fontsize',24);
title('Previous Temperature','fontsize',24);
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=2
ylim([0 1])
xlim([0 10])
set(gca,'fontsize',14)
%% Melt Rate
for j=1:ncatch
meltrate(:,j)=allmeltrate(:,j)
end
%melt rate
prevMR = nan(length(meltrate),11,ncatch);
for j = 1:ncatch
    prevMR(:,:,j) = repmat(meltrate(:,j),1,11);
end
for j=1:ncatch
    for i = 1:10
        prevMR(i+1:end,i+1,j) = prevMR(i:end-1,i,j);
        prevMR(1:i,i+1,j) = nan;    
    end
end

%% Melt Rate Stats
MRstats=nan(4,10,ncatch); % preallocate: 4 stats, 10 previous years, 5 catchments
MR_b = cell(10,ncatch); %preallocate cell array to hold regression coefficients
for j=1:ncatch %regress baseflow against prev Precip, adding one more prev year each time
    for i = 1:10
        [MR_b{i,j},~,~,~,MRstats(:,i,j)] = regress(allbaseflow(:,j),[prevMR(:,2:i+1,j) ones(length(t),1)]); 
    end
end%
MR_b_sign = strings(1,5); %determine positive or negative relationship (first year only)
%% plot Melt Rate MLR
figure;
for j=1:ncatch
    plot(0:10, [0 MRstats(1,:,j)],'Color',ColorSet(j,:),'linewidth',3); hold on;% add 0 for 0th year  
    
end
xticks(0:10);
xlabel('Previous Years in MLR','fontsize',24);
ylabel('r^2','fontsize',24);
title('Previous Melt Rate','fontsize',24);
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=2
ylim([0 1])
xlim([0 5])
set(gca,'fontsize',14)
%%
% % streamflow
% prevQ = nan(length(q),11,5);
% for j = 1:7
%     prevQ(:,:,j) = repmat(q(:,j),1,11);
% end
% for j=1:7
%     for i = 1:10
%         prevQ(i+1:end,i+1,j) = prevQ(i:end-1,i,j);
%         prevQ(1:i,i+1,j) = nan;    
%     end
% end

%%  winter precip
% for j=1:ncatch
% winterp(:,j)=hydro_vars1{1,j}.WinterP
% end
% prevWP = nan(length(winterp),11,7);
% for j = 1:7
%     prevWP(:,:,j) = repmat(winterp(:,j),1,11);
% end
% for j=1:7
%     for i = 1:10
%         prevWP(i+1:end,i+1,j) = prevWP(i:end-1,i,j);
%         prevWP(1:i,i+1,j) = nan;    
%     end
% end
% %% Winter Precip Stats
% WPstats=nan(4,10,7); % preallocate: 4 stats, 10 previous years, 5 catchments
% WP_b = cell(10,7); %preallocate cell array to hold regression coefficients
% for j=1:7 %regress baseflow against prev Precip, adding one more prev year each time
%     for i = 1:10
%         [WP_b{i,j},~,~,~,WPstats(:,i,j)] = regress(meanJanQ(:,j),[prevWP(:,2:i+1,j) ones(length(t),1)]); 
%     end
% end%
% %MR_b_sign = strings(1,5); %determine positive or negative relationship (first year only)
% %% plot Winter P MLR
% figure;
% for j=1:7
%     plot(0:10, [0 WPstats(1,:,j)],'linewidth',2); hold on;% add 0 for 0th year   
% end
% xticks(0:10);
% xlabel('Previous Years in MLR','fontsize',24);
% ylabel('r^2','fontsize',24);
% title('Previous Winter Precipitation','fontsize',24);
% legend('CC','RB','EC','PC','MC','BC','LC','fontsize',20);% + P_b_sign);
% ylim([0 1])
% xlim([0 5])
% set(gca,'fontsize',14)
 %% cumulative precipitation
% cumP = nan(length(p),10,7);
% for j =1:7
%     for i =1:10
%         cumP(:,i,j) = sum(prevP(:,2:i+1,j),2); %sum across columns
%     end
% end
% %% Cumulative P Stats
% CumPstats=nan(4,10,7); % preallocate: 4 stats, 10 previous years, 7 catchments
% CumP_b = cell(10,7); %preallocate cell array to hold regression coefficients
% for j=1:7 %regress baseflow against prev cum Precip, adding one more prev year each time
%     for i = 1:10
%         [CumP_b{i,j},~,~,~,CumPstats(:,i,j)] = regress(meanJanQ(:,j),[cumP(:,2:i+1,j) ones(length(t),1)]); 
%     end
% end 
% %cumP_b_sign = strings(1,5); %determine positive or negative relationship (first year only)
% %% plot Cumulative Precip(multi year) MLR
% figure;
% for j=1:7
%     plot(0:10, [0 CumPstats(1,:,j)],'linewidth',2); hold on;% add 0 for 0th year   
% end
% xticks(0:10);
% xlabel('Previous Years in MLR');
% ylabel('r^2');
% title('Cumulative Precipitation(Mulit-Year) Influence on Baseflow');
% legend('CC','RB','EC','PC','MC','BC','LC');% + P_b_sign);
% ylim([0 1])

%% melt duration
for j=1:ncatch
meltdur(:,j)=allmeltduration(:,j)
end
prevMD = nan(length(meltdur),11,ncatch);
for j = 1:ncatch
    prevMD(:,:,j) = repmat(meltdur(:,j),1,11);
end
for j=1:ncatch
    for i = 1:10
        prevMD(i+1:end,i+1,j) = prevMD(i:end-1,i,j);
        prevMD(1:i,i+1,j) = nan;    
    end
end

%% Melt Duration Stats
MDstats=nan(4,10,ncatch); % preallocate: 4 stats, 10 previous years, 5 catchments
MD_b = cell(10,ncatch); %preallocate cell array to hold regression coefficients
for j=1:ncatch %regress baseflow against prev Melt Duration, adding one more prev year each time
    for i = 1:10
        [MD_b{i,j},~,~,~,MDstats(:,i,j)] = regress(allbaseflow(:,j),[prevMD(:,2:i+1,j) ones(length(t),1)]); 
    end
end%
%MD_b_sign = strings(1,5); %determine positive or negative relationship (first year only)
%% plot Melt Duration MLR
figure;
for j=1:ncatch
    plot(0:10, [0 MDstats(1,:,j)],'Color',ColorSet(j,:),'linewidth',2); hold on;% add 0 for 0th year  
   
    
end
xticks(0:10);
xlabel('Previous Years in MLR','fontsize',24);
ylabel('r^2','fontsize',24);
title('Previous Melt Duration','fontsize',24);
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=2
ylim([0 1])
xlim([0 5])
set(gca,'fontsize',14)
%% % compute correlations with baseflow for each variable 

%% calculate correlations and p-values for each variable and previous years
% combine all previous years' data into 4-d matrix
% yearly value x prior years x catchments x variable
alldata = nan(118,10,ncatch,4);
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
for i = 1:ncatch
    for j =1:10
        alldata(:,j,i,1) = prevP(:,j+1,i);
        alldata(:,j,i,2) = prevT(:,j+1,i);
        alldata(:,j,i,3) = prevMR(:,j+1,i);
        alldata(:,j,i,4) = prevMD(:,j+1,i);
        %alldata(:,j,i,5) = prevWP(:,j+1,i);
    end
end
corrs = nan(5,10,ncatch);
significance = nan(5,10,ncatch);
for i = 1:ncatch   
    for j = 1:10
        for k =1:4
            [r,p] = corrcoef(alldata(:,j,i,k),allbaseflow(:,i),'rows','complete');
            corrs(k,j,i) = r(2);
            significance(k,j,i) = p(2);
        end
    end
end

issig = significance < 0.05; % p val < 0.05 is significant
direction = sign(corrs);

relation = zeros(5,10,ncatch); %pick out only significant values and show sign
for i =1:4
    for j = 1:10
        for k =1:ncatch
            if  issig(i,j,k) ==1
                relation(i,j,k) = direction(i,j,k);
            end
        end
    end
end

% reshape relation matrix and display +/- for sign of correlation
relation2 = permute(relation,[3 2 1]);
relationsymbol = cell(ncatch,10,4);
for i = 1:ncatch
    for j=1:10
        for k=1:4
            if relation2(i,j,k) == 1
                relationsymbol(i,j,k) = cellstr('+');
            elseif relation2(i,j,k) == -1
                relationsymbol(i,j,k) = cellstr('-');
            else
                relationsymbol(i,j,k) = cellstr(' ');
            end
        end
    end
end

for i = 1:4
    figure; t = uitable('RowName',catchnames,'FontSize',13,'Data',relationsymbol(:,:,i));
    t.Position(3:4) = t.Extent(3:4);
end


%% After determining the positive and negative correlations to predict baseflow ith one to one relations
%% now normalize melt rate to the amount of winter P
%does above average winterP control melt rate
%% load in winter P montsh for all creeks

load('allDecP.mat')
load('allJanP.mat')
load('allFebP.mat')
load('allMarP.mat')


for j=1:ncatch
    LongWinterP(:,j)=[allDecP(:,j)+allJanP(:,j)+allFebP(:,j)+allMarP(:,j)] 
end



%preallocate size of matrix for residual and stats
WPMRr=nan(118,ncatch);
WPMRstats= nan(4,ncatch);
figure;
for j=1:ncatch
    
 hold on
    plot(LongWinterP(:,j),allmeltrate(:,j),'.','Color',ColorSet(j,:),'markersize',14)
    hold on
   
    [~,~,WPMRr(:,j),~,WPMRstats(:,j)] = regress(allmeltrate(:,j),[LongWinterP(:,j) ones(118,1)]); %calculate residuals
    title(' Calculate Residual from LongWinter P vs Melt Rate','fontsize',24);

xlabel('Dec-Mar Precip')

ylabel('meltrate')
end
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=2
 lsline
%does residual melt rate normalized by winter P control baseflow
%% Melt Rate residual
for j=1:ncatch
meltrateRes(:,j)=WPMRr(:,j)
end
%melt rate
prevMRres = nan(length(meltrateRes),11,ncatch);
for j = 1:ncatch
    prevMRres(:,:,j) = repmat(meltrateRes(:,j),1,11);
end
for j=1:ncatch
    for i = 1:10
        prevMRres(i+1:end,i+1,j) = prevMRres(i:end-1,i,j);
        prevMRres(1:i,i+1,j) = nan;    
    end
end

%% Melt Rate residual Stats
WPMRStoragestats=nan(4,10,ncatch); % preallocate: 4 stats, 10 previous years, 12 catchments
MRRes_b = cell(10,ncatch); %preallocate cell array to hold regression coefficients
for j=1:ncatch %regress baseflow against prev Precip, adding one more prev year each time
    for i = 1:10
        [MRRes_b{i,j},~,~,~,WPMRStoragestats(:,i,j)] = regress(allbaseflow(:,j),[prevMRres(:,2:i+1,j) ones(length(nyears),1)]); 
    end
end%
MRres_b_sign = strings(1,ncatch); %determine positive or negative relationship (first year only)
%% plot Melt Rate residual MLR
figure;
for j=1:ncatch
    plot(0:10, [0 WPMRStoragestats(1,:,j)],'Color',ColorSet(j,:),'linewidth',3); hold on;% add 0 for 0th year   
end
xticks(0:10);
xlabel('Previous Years in MLR','fontsize',24);
ylabel('r^2','fontsize',24);
title('Previous Melt Rate Residual From Long Winter P','fontsize',24);
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=2
ylim([0 1])
xlim([0 5])
set(gca,'fontsize',14)
%%
%% now normalize melt duration to the amount of winter P
%does above average winterP control melt rate



%preallocate size of matrix for residual and stats
WPMDr=nan(118,ncatch);
WPMDstats= nan(4,ncatch);
figure;
for j=1:ncatch
    
 hold on
    plot(LongWinterP(:,j),allmeltduration(:,j),'.','Color',ColorSet(j,:),'markersize',14)
    hold on
   
    [~,~,WPMDr(:,j),~,WPMDstats(:,j)] = regress(allmeltduration(:,j),[LongWinterP(:,j) ones(118,1)]); %calculate residuals
    title(' Calculate Residual from LongWinter P vs Melt Duration','fontsize',24);

xlabel('Dec-Mar Precip')

ylabel('MeltDuration (days)')
end
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=2
 lsline
%does residual melt rate normalized by winter P control baseflow
%% Melt Duration residual
for j=1:ncatch
meltdurationRes(:,j)=WPMDr(:,j)
end
%melt rate
prevMDres = nan(length(meltdurationRes),11,5);
for j = 1:ncatch
    prevMDres(:,:,j) = repmat(meltdurationRes(:,j),1,11);
end
for j=1:ncatch
    for i = 1:10
        prevMDres(i+1:end,i+1,j) = prevMDres(i:end-1,i,j);
        prevMDres(1:i,i+1,j) = nan;    
    end
end

%% Melt Duration residual Stats
WPMDStoragestats=nan(4,10,ncatch); % preallocate: 4 stats, 10 previous years, 5 catchments
MDRes_b = cell(10,ncatch); %preallocate cell array to hold regression coefficients
for j=1:ncatch %regress baseflow against prev Precip, adding one more prev year each time
    for i = 1:10
        [MDRes_b{i,j},~,~,~,WPMDStoragestats(:,i,j)] = regress(allbaseflow(:,j),[prevMDres(:,2:i+1,j) ones(length(nyears),1)]); 
    end
end%
MDres_b_sign = strings(1,ncatch); %determine positive or negative relationship (first year only)
%% plot Melt duration residual MLR
figure;
for j=1:ncatch
    plot(0:10, [0 WPMDStoragestats(1,:,j)],'Color',ColorSet(j,:),'linewidth',3); hold on;% add 0 for 0th year   
end
xticks(0:10);
xlabel('Previous Years in MLR','fontsize',24);
ylabel('r^2','fontsize',24);
title('Previous Melt Duration Residual From Long Winter P','fontsize',24);
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=2
ylim([0 1])
xlim([0 10])
set(gca,'fontsize',14)
%%
%% calculate correlations and p-values for each variable and previous years
% combine all previous years' data into 4-d matrix
% yearly value x prior years x catchments x variable
nvars=4 %(Previous precipitation, previous temperature, previous melt rate(noramilzed to winter P, previous melt duration(normalized to winter P)
alldata = nan(118,10,ncatch,nvars);
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)

%%

%% % compute correlations with baseflow for each variable 

%% calculate correlations and p-values for each variable and previous years
% combine all previous years' data into 4-d matrix
% yearly value x prior years x catchments x variable
alldata = nan(118,10,ncatch,4);
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
for i = 1:ncatch
    for j =1:10
        alldata(:,j,i,1) = prevP(:,j+1,i);
        alldata(:,j,i,2) = prevT(:,j+1,i);
        alldata(:,j,i,3) = prevMRres(:,j+1,i);
        alldata(:,j,i,4) = prevMDres(:,j+1,i);
        %alldata(:,j,i,5) = prevWP(:,j+1,i);
    end
end
corrs = nan(5,10,ncatch);
significance = nan(5,10,ncatch);
for i = 1:ncatch   
    for j = 1:10
        for k =1:4
            [r,p] = corrcoef(alldata(:,j,i,k),allbaseflow(:,i),'rows','complete');
            corrs(k,j,i) = r(2);
            significance(k,j,i) = p(2);
        end
    end
end

issig = significance < 0.05; % p val < 0.05 is significant
direction = sign(corrs);

relation = zeros(5,10,ncatch); %pick out only significant values and show sign
for i =1:4
    for j = 1:10
        for k =1:ncatch
            if  issig(i,j,k) ==1
                relation(i,j,k) = direction(i,j,k);
            end
        end
    end
end

% reshape relation matrix and display +/- for sign of correlation
relation2 = permute(relation,[3 2 1]);
relationsymbol = cell(ncatch,10,4);
for i = 1:ncatch
    for j=1:10
        for k=1:4
            if relation2(i,j,k) == 1
                relationsymbol(i,j,k) = cellstr('+');
            elseif relation2(i,j,k) == -1
                relationsymbol(i,j,k) = cellstr('-');
            else
                relationsymbol(i,j,k) = cellstr(' ');
            end
        end
    end
end

for i = 1:4
    figure; t = uitable('RowName',catchnames,'FontSize',13,'Data',relationsymbol(:,:,i));
    t.Position(3:4) = t.Extent(3:4);
end


%% CC with melt residuals 
%CC - 2 years annual P, 1 year annual T, 3 years Melt rate, 3 years melt
%duration, 1 year Winter P
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
% Annual P= position 1 MLR Vars
% Annual T Position 2
% Melt Rate position 3
% Melt Duration position 4
% Winter P position 5
for i=1 %(annual P)
CC(:,1)=alldata(:,1,1,1) %the entire column from 1 year prev in the past of CITY CREEK, and annual P
CC(:,2)=alldata(:,2,1,1) % 2 years prev annual P
CC(:,3)=alldata(:,1,1,2) % Prev 1 year annualtT \
CC(:,4)=alldata(:,1,1,3) % 1st year prev melt rate
CC(:,5)=alldata(:,2,1,3) % 2nd year prev melt rate
CC(:,6)=alldata(:,3,1,3) % 3rd year prev melt rate
CC(:,7)=alldata(:,1,1,4) % 1st year prev melt duration
CC(:,8)=alldata(:,2,1,4) % 2nd year prev melt duration
CC(:,9)=alldata(:,3,1,4) % 3rd year prev melt duration
% maybe add in winter P later only 1 year prev
end

[CCB,~,~,~,CCstats]= regress(allbaseflow(:,1),[CC ones(length(CC))])

    CCBaseflowPredicted=(CCB(1).*CC(:,1)+CCB(2).*CC(:,2)+CCB(3).*CC(:,3)+CCB(4).*CC(:,4)...
        +CCB(5).*CC(:,5)+CCB(6).*CC(:,6)+CCB(7).*CC(:,7)+CCB(8).*CC(:,8)+CCB(9).*CC(:,9)+CCB(10))

    figure;
plot(CCBaseflowPredicted,allbaseflow(:,1),'*','MarkerSize',14) %predicted Baseflow vs observed baseflow
lsline
title('Predicted Baseflow Using Antecedent Climate Conditions: City Creek','FontSize',14)
xlabel('Predicted Baseflow','FontSize',14)
ylabel('Observed Baseflow','FontSize',14)
text1={['CC R^2: ',sprintf('%.2f',CCstats(1,1))]}
    annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',14);
    text8={['Baseflow= 2yearAP+1YearAT+ 3YearMR+3YearsMD']}
    annotation('textbox',[.6 .2 .1 .2],'String',text8,'EdgeColor','none');


   %% Corr coef normalized
   %zscore= (vals-nanmean)/(nanstd(vals)
   for k=1:9
CCzscore(:,k)=(CC(:,k)-(nanmean(CC(:,k)))/nanstd(CC(:,k)))
   end
[CCBNorm,~,~,~,CCstatsnorm]= regress(allbaseflow(:,1),[CCzscore ones(length(CC))])
%%
figure;
names = {'P(1Yr)'; 'P(2Yr)'; 'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MR(3Yr)';'MD(1Yr)';'MD(2Yr)';'MD(3Yr)'};
    bar(CCBNorm)
    ylim([-.1 .1])
    xlim([1 9])
    set(gca,'xtick',[1:9],'xticklabel',names,'fontsize',14)
    ylabel('Normalized Corr Coef','fontsize',14')
    title('City Creek')

%% RB 3 years AP, 1 year AT, 2 year MR, 1 Year MD, 3 year WP
%% RB 
%RB - 3 years annual P, 1 year annual T, 2 years Melt rate, 1 years melt
%duration, 1 year Winter P
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
% Annual P= position 1 MLR Vars
% Annual T Position 2
% Melt Rate position 3
% Melt Duration position 4
% Winter P position 5
%Melt rate normalized to WP= 6
%Meltduration normalized to winter P=7
for i=1 %(annual P)
RB(:,1)=alldata(:,1,2,1) %the entire column from 1 year prev in the past of red Butte  CREEK, and annual P
RB(:,2)=alldata(:,2,2,1) % 2 years prev annual P
RB(:,3)=alldata(:,3,2,1) % 2 years prev annual P
RB(:,4)=alldata(:,1,2,2) % entire column (:),1 year prev (1), REd BUtte creek (1), annualtT ((2) 
RB(:,5)=alldata(:,1,2,3) % 1st year prev melt rate res
RB(:,6)=alldata(:,2,2,3) % 2nd year prev melt rate residual
RB(:,7)=alldata(:,1,2,4) % 1st year prev melt duration residual

% maybe add in winter P later only 1 year prev
end

[RBB,~,~,~,RBstats]= regress(allbaseflow(:,2),[RB ones(length(RB))])

    RBBaseflowPredicted=(RBB(1).*RB(:,1)+RBB(2).*RB(:,2)+RBB(3).*RB(:,3)+RBB(4).*RB(:,4)...
        +RBB(5).*RB(:,5)+RBB(6).*RB(:,6)+RBB(7).*RB(:,7)+RBB(8))

    figure;
plot(RBBaseflowPredicted,allbaseflow(:,2),'.','MarkerSize',14) %predicted Baseflow vs observed baseflow
lsline
title('Predicted S Using Antecedent Climate Conditions: Red Butte Creek','FontSize',20)
xlabel('Predicted S','FontSize',20)
ylabel('Observed S','FontSize',20)
text1={['RB R^2: ',sprintf('%.2f',RBstats(1,1))]}
    annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',20);
    text8={['?S=2yearAP+1YearAT+2YearMRres+2YearsMDres']}
    annotation('textbox',[.2 .1 .1 .2],'String',text8,'EdgeColor','none','fontsize',20);
ax = gca; % current axes
ax.FontSize = 20;
%ylim([.2 .8])
%xlim([.2 .8])

   for k=1:7
RBzscore(:,k)=(RB(:,k)-(nanmean(RB(:,k)))/nanstd(RB(:,k)))
   end
[RBBNorm,~,~,~,RBstatsnorm]= regress(allbaseflow(:,2),[RBzscore ones(length(RB))])

figure;
namesRB = {'P(1Yr)'; 'P(2Yr)';'P(3Yr)'; 'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MD(1Yr)'};
    bar(RBBNorm)
    ylim([-.1 .1])
    xlim([1 7])
    set(gca,'xtick',[1:7],'xticklabel',namesRB,'fontsize',14)
    ylabel('Normalized Corr Coef','fontsize',14')
    title('Red Butte Creek')

%% EC  2 year AP, 1,2,2
%% EC 
%EC - 2 years annual P, 1 year annual T, 2 years Melt rate, 1 years melt duration, 1 year Winter P
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
% Annual P= position 1 MLR Vars
% Annual T Position 2
% Melt Rate position 3
% Melt Duration position 4
% Winter P position 5
%Melt rate normalized to WP= 6
%Meltduration normalized to winter P=7
for i=1 %(annual P)
EC(:,1)=alldata(:,1,3,1) %the entire column from 1 year prev in the past of Emigration  CREEK, and annual P
EC(:,2)=alldata(:,2,3,1) % 2 years prev annual P
EC(:,3)=alldata(:,1,3,2) % entire column (:),1 year prev (1), Emigration creek (1), annualtT ((2) 
EC(:,4)=alldata(:,1,3,3) % 1st year prev melt rate res
EC(:,5)=alldata(:,2,3,3) % 2nd year prev melt rate residual
EC(:,6)=alldata(:,1,3,4) % 1st year prev melt duration residual
EC(:,7)=alldata(:,2,3,4) % 2nd year prev melt duration residual
% maybe add in winter P later only 1 year prev
end

[ECB,~,~,~,ECstats]= regress(allbaseflow(:,3),[EC ones(length(EC))])

    ECBaseflowPredicted=(ECB(1).*EC(:,1)+ECB(2).*EC(:,2)+ECB(3).*EC(:,3)+ECB(4).*EC(:,4)...
        +ECB(5).*EC(:,5)+ECB(6).*EC(:,6)+ECB(7).*EC(:,7)+ECB(8))

    figure;
plot(ECBaseflowPredicted,allbaseflow(:,3),'.','MarkerSize',14) %predicted Baseflow vs observed baseflow
lsline
title('Predicted S Using Antecedent Climate Conditions: Emigration Creek','FontSize',20)
xlabel('Predicted S','FontSize',20)
ylabel('Observed S','FontSize',20)
text1={['EC R^2: ',sprintf('%.2f',ECstats(1,1))]}
    annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',20);
    text8={['S=2yearAP+1YearAT+2YearMRres+1YearsMDres']}
    annotation('textbox',[.2 .1 .1 .2],'String',text8,'EdgeColor','none','fontsize',20);
ax = gca; % current axes
ax.FontSize = 20;
%ylim([.2 .8])
%xlim([.2 .8])

   for k=1:7
ECzscore(:,k)=(EC(:,k)-(nanmean(EC(:,k)))/nanstd(EC(:,k)))
   end
[ECBNorm,~,~,~,ECstatsnorm]= regress(allbaseflow(:,4),[ECzscore ones(length(EC))])

figure;
namesEC = {'P(1Yr)'; 'P(2Yr)'; 'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MD(1Yr)';'MD(2Yr)'};
    bar(ECBNorm)
    ylim([-.1 .1])
    xlim([1 7])
    set(gca,'xtick',[1:7],'xticklabel',namesEC,'fontsize',14)
    ylabel('Normalized Corr Coef','fontsize',14')
    title('Emigration Creek')

%% PC 3,1,2,3

%% PC 
%PC - 2 years annual P, 1 year annual T, 2 years Melt rate, 3 years melt
%duration, 1 year Winter P
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
% Annual P= position 1 MLR Vars
% Annual T Position 2
% Melt Rate position 3
% Melt Duration position 4
% Winter P position 5
%Melt rate normalized to WP= 6
%Meltduration normalized to winter P=7
for i=1 %(annual P)
PC(:,1)=alldata(:,1,4,1) %the entire column from 1 year prev in the past of Big cottonwood  CREEK, and annual P
PC(:,2)=alldata(:,2,4,1) % 2 years prev annual P
PC(:,3)=alldata(:,3,4,1) % 3 years prev annual P
PC(:,4)=alldata(:,1,4,2) % 1 year annualtT  
PC(:,5)=alldata(:,1,4,3) % 1st year prev melt rate res
PC(:,6)=alldata(:,2,4,3) % 2nd year prev melt rate residual
PC(:,7)=alldata(:,1,4,4) % 1st year prev melt duration residual
PC(:,8)=alldata(:,2,4,4) % 2st year prev melt duration residual
PC(:,9)=alldata(:,3,4,4) % 3st year prev melt duration residual
% maybe add in winter P later only 1 year prev
end

[PCB,~,~,~,PCstats]= regress(allbaseflow(:,4),[PC ones(length(PC))])

    PCBaseflowPredicted=(PCB(1).*PC(:,1)+PCB(2).*PC(:,2)+PCB(3).*PC(:,3)+PCB(4).*PC(:,4)...
        +PCB(5).*PC(:,5)+PCB(6).*PC(:,6)+PCB(7).*PC(:,7)+PCB(8).*PC(:,8)+PCB(9).*PC(:,9)+PCB(10))

    figure;
plot(PCBaseflowPredicted,allbaseflow(:,4),'.','MarkerSize',14) %predicted Baseflow vs observed baseflow
lsline
title('Predicted S Using Antecedent Climate Conditions: Parleys Creek','FontSize',20)
xlabel('Predicted S','FontSize',20)
ylabel('Observed S','FontSize',20)
text1={['PC R^2: ',sprintf('%.2f',PCstats(1,1))]}

    annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',20);
    text8={['S=3yearAP+1YearAT+2YearMRres+3YearsMDres']}
    annotation('textbox',[.2 .1 .1 .2],'String',text8,'EdgeColor','none','fontsize',20);
ax = gca; % current axes
ax.FontSize = 20;
%ylim([.2 .8])
%xlim([.2 .8])


   for k=1:9
PCzscore(:,k)=(PC(:,k)-(nanmean(PC(:,k)))/nanstd(PC(:,k)))
   end
[PCBNorm,~,~,~,PCstatsnorm]= regress(allbaseflow(:,4),[PCzscore ones(length(PC))])

figure;
namesPC = {'P(1Yr)'; 'P(2Yr)'; 'P(3Yr)';'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MD(1Yr)';'MD(2Yr)';'MD(3Yr)'};
    bar(PCBNorm)
    ylim([-.1 .1])
    xlim([1 9])
    set(gca,'xtick',[1:9],'xticklabel',namesPC,'fontsize',14)
    ylabel('Normalized Corr Coef','fontsize',14')
    title('Parleys Creek')

    
%% MC 3,1,2,3,1
%% MC 
%MC - 2 years annual P, 1 year annual T, 2 years Melt rate, 3 years melt
%duration, 1 year Winter P
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
% Annual P= position 1 MLR Vars
% Annual T Position 2
% Melt Rate position 3
% Melt Duration position 4
% Winter P position 5
%Melt rate normalized to WP= 6
%Meltduration normalized to winter P=7
for i=1 %(annual P)
MC(:,1)=alldata(:,1,5,1) %the entire column from 1 year prev in the past of Mill  CREEK, and annual P
MC(:,2)=alldata(:,2,5,1) % 2 years prev annual P
MC(:,3)=alldata(:,3,5,1) % 3 years prev annual P
MC(:,4)=alldata(:,1,5,2) % entire column (:),1 year prev (1), Mill creek (1), annualtT ((2) 
MC(:,5)=alldata(:,1,5,3) % 1st year prev melt rate res
MC(:,6)=alldata(:,2,5,3) % 2nd year prev melt rate residual
MC(:,7)=alldata(:,1,5,4) % 1st year prev melt duration residual
MC(:,8)=alldata(:,2,5,4) % 2nd year prev melt duration reidual
MC(:,9)=alldata(:,2,5,4) % 2nd year prev melt duration reidual
% maybe add in winter P later only 1 year prev
end

[MCB,~,~,~,MCstats]= regress(allbaseflow(:,5),[MC ones(length(MC))])

    MCBaseflowPredicted=(MCB(1).*MC(:,1)+MCB(2).*MC(:,2)+MCB(3).*MC(:,3)+MCB(4).*MC(:,4)...
        +MCB(5).*MC(:,5)+MCB(6).*MC(:,6)+MCB(7).*MC(:,7)+MCB(8).*MC(:,8)+MCB(9).*MC(:,9)+MCB(10))

    figure;
plot(MCBaseflowPredicted,allbaseflow(:,5),'.','MarkerSize',14) %predicted Baseflow vs observed baseflow
lsline
title('Predicted S Using Antecedent Climate Conditions: Mill Creek','FontSize',20)
xlabel('Predicted S','FontSize',20)
ylabel('Observed S','FontSize',20)
text1={['MC R^2: ',sprintf('%.2f',MCstats(1,1))]}
    annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',20);
    text8={['S=3yearAP+1YearAT+2YearMRres+3YearsMDres']}
    annotation('textbox',[.2 .1 .1 .2],'String',text8,'EdgeColor','none','fontsize',20);
ax = gca; % current axes
ax.FontSize = 20;
ylim([.2 .8])
xlim([.2 .8])


   for k=1:9
MCzscore(:,k)=(MC(:,k)-(nanmean(MC(:,k)))/nanstd(MC(:,k)))
   end
[MCBNorm,~,~,~,MCstatsnorm]= regress(allbaseflow(:,5),[MCzscore ones(length(MC))])

figure;
namesMC = {'P(1Yr)'; 'P(2Yr)'; 'P(3Yr)';'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MD(1Yr)';'MD(2Yr)';'MD(3Yr)'};
    bar(MCBNorm)
    ylim([-.1 .1])
    xlim([1 9])
    set(gca,'xtick',[1:9],'xticklabel',namesMC,'fontsize',14)
    ylabel('Normalized Corr Coef','fontsize',14')
    title('Mill Creek')

%% BC 3,1,3,3,1
%% BC 
%BC - 2 years annual P, 1 year annual T, 2 years Melt rate, 1 years melt
%duration, 1 year Winter P
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
% Annual P= position 1 MLR Vars
% Annual T Position 2
% Melt Rate position 3
% Melt Duration position 4
% Winter P position 5
%Melt rate normalized to WP= 6
%Meltduration normalized to winter P=7
for i=1 %(annual P)
BC(:,1)=alldata(:,1,6,1) %the entire column from 1 year prev in the past of Big cottonwood  CREEK, and annual P
BC(:,2)=alldata(:,2,6,1) % 2 years prev annual P
BC(:,3)=alldata(:,3,6,1) % 3 years prev annual P
BC(:,4)=alldata(:,1,6,2) % entire column (:),1 year prev (1), Big cottonwood creek (1), annualtT ((2) 
BC(:,5)=alldata(:,1,6,3) % 1st year prev melt rate res
BC(:,6)=alldata(:,2,6,3) % 2nd year prev melt rate residual
BC(:,7)=alldata(:,3,6,3) % 3nd year prev melt rate residual
BC(:,8)=alldata(:,1,6,4) % 1st year prev melt duration residual
BC(:,9)=alldata(:,2,6,4) % 2nd year prev melt duration reidual
BC(:,10)=alldata(:,3,6,4) % 2nd year prev melt duration reidual
% maybe add in winter P later only 1 year prev
end

[BCB,~,~,~,BCstats]= regress(allbaseflow(:,6),[BC ones(length(BC))])

    BCBaseflowPredicted=(BCB(1).*BC(:,1)+BCB(2).*BC(:,2)+BCB(3).*BC(:,3)+BCB(4).*BC(:,4)...
        +BCB(5).*BC(:,5)+BCB(6).*BC(:,6)+BCB(7).*BC(:,7)+BCB(8).*BC(:,8)+BCB(9).*BC(:,9)+BCB(10).*BC(:,10)+BCB(11))

    figure;
plot(BCBaseflowPredicted,allbaseflow(:,6),'.','MarkerSize',14) %predicted Baseflow vs observed baseflow
lsline
title('Predicted S Using Antecedent Climate Conditions: Big Cottonwood Creek','FontSize',20)
xlabel('Predicted S','FontSize',20)
ylabel('Observed S','FontSize',20)
text1={['BC R^2:  ',sprintf('%.2f',BCstats(1,1))]}
    annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',20);
    text8={['S=3yearAP+1YearAT+3YearMRres+3YearsMDres']}
    annotation('textbox',[.2 .1 .1 .2],'String',text8,'EdgeColor','none','fontsize',20);
ax = gca; % current axes
ax.FontSize = 20;
ylim([.2 .8])
xlim([.2 .8])

   for k=1:10
BCzscore(:,k)=(BC(:,k)-(nanmean(BC(:,k)))/nanstd(BC(:,k)))
   end
[BCBNorm,~,~,~,BCstatsnorm]= regress(allbaseflow(:,6),[BCzscore ones(length(BC))])

figure;
namesBC = {'P(1Yr)'; 'P(2Yr)'; 'P(3Yr)';'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MR(3Yr)';'MD(1Yr)';'MD(2Yr)';'MD(3Yr)'};
    bar(BCBNorm)
    ylim([-.1 .1])
    xlim([1 10])
    set(gca,'xtick',[1:10],'xticklabel',namesBC,'fontsize',14)
    ylabel('Normalized Corr Coef','fontsize',14')
    title('Big Cottonwood Creek')
%% LC 1,1,1,3

%% LC 
%LC - 1 years annual P, 1 year annual T, 1 years Melt rate, 3 years melt
%duration, 1 year Winter P
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
% Annual P= position 1 MLR Vars
% Annual T Position 2
% Melt Rate position 3
% Melt Duration position 4
% Winter P position 5
%Melt rate normalized to WP= 6
%Meltduration normalized to winter P=7
for i=1 %(annual P)
LC(:,1)=alldata(:,1,7,1) %the entire column from 1 year prev in the past of Big cottonwood  CREEK, and annual P
LC(:,2)=alldata(:,1,7,2) % 1 year annual T
LC(:,3)=alldata(:,1,7,3) % 1st year prev melt rate res
LC(:,4)=alldata(:,1,7,4) % 1st year prev melt dur residual
LC(:,5)=alldata(:,2,7,4) % 2nd year prev melt rate residual
LC(:,6)=alldata(:,3,7,4) % 1st year prev melt duration residual


% maybe add in winter P later only 1 year prev
end

[LCB,~,~,~,LCstats]= regress(allbaseflow(:,7),[LC ones(length(LC))])

    LCBaseflowPredicted=(LCB(1).*LC(:,1)+LCB(2).*LC(:,2)+LCB(3).*LC(:,3)+LCB(4).*LC(:,4)...
        +LCB(5).*LC(:,5)+LCB(6).*LC(:,6)+LCB(7))

    figure;
plot(LCBaseflowPredicted,allbaseflow(:,7),'.','MarkerSize',14) %predicted Baseflow vs observed baseflow
lsline
title('Predicted S Using Antecedent Climate Conditions: Little Cottonwood Creek','FontSize',20)
xlabel('Predicted S','FontSize',20)
ylabel('Observed S','FontSize',20)
text1={['LC R^2: ',sprintf('%.2f',LCstats(1,1))]}
    annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',20);
    text8={['S=1yearAP+1YearAT+1YearMRres+3YearsMDres']}
    annotation('textbox',[.2 .1 .1 .2],'String',text8,'EdgeColor','none','fontsize',20);
ax = gca; % current axes
ax.FontSize = 20;
ylim([.2 .8])
xlim([.2 .8])

   for k=1:6
LCzscore(:,k)=(LC(:,k)-(nanmean(LC(:,k)))/nanstd(LC(:,k)))
   end
[LCBNorm,~,~,~,LCstatsnorm]= regress(allbaseflow(:,7),[LCzscore ones(length(LC))])

figure;
namesLC = {'P(1Yr)';'T(1Yr)'; 'MR(1Yr)';'MD(1Yr)';'MD(2Yr)';'MD(3Yr)'};
 subplot(2,1,1)
    bar(LCBNorm)
    ylim([-.1 .1])
    xlim([1 6])
    ylabel('Normalized Corr Coef','fontsize',14')
    subplot(2,1,2)
    bar(LCB)
    ylim([-.1 .1])
    xlim([1 6])
    set(gca,'xtick',[1:6],'xticklabel',namesLC,'fontsize',14)
    ylabel('Corr Coef','fontsize',14')
    title('Little Cottonwood Creek')
    
    %%   %% Weber CC (9th catchment) 4,1,2,0

%% WCC 
%WCC - 4 years annual P, 1 year annual T, 2 years Melt rate
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
% Annual P= position 1 MLR Vars
% Annual T Position 2
% Melt Rate position 3
% Melt Duration position 4

for i=1 %(annual P)
WC(:,1)=alldata(:,1,9,1)%the entire column from 1 year prev in the past of Chalk Creek, and annual P
WC(:,2)=alldata(:,2,9,1)
WC(:,3)=alldata(:,3,9,1)
WC(:,4)=alldata(:,4,9,1)
WC(:,5)=alldata(:,1,9,2) % 1 year annual T
WC(:,6)=alldata(:,1,9,3) % 1st year prev melt rate res
WC(:,7)=alldata(:,2,9,3) % 2nd melt rate
end

[WCB,~,~,~,WCstats]= regress(allbaseflow(:,9),[WC ones(length(WC))])

    WCCBaseflowPredicted=(WCB(1).*WC(:,1)+WCB(2).*WC(:,2)+WCB(3).*WC(:,3)+WCB(4).*WC(:,4)...
        +WCB(5).*WC(:,5)+WCB(6).*WC(:,6)+WCB(7).*WC(:,7)+WCB(7))

    figure;
plot(WCCBaseflowPredicted,allbaseflow(:,9),'.','MarkerSize',14) %predicted Baseflow vs observed baseflow
lsline
title('Predicted S Using Antecedent Climate Conditions: Chalk Creek','FontSize',20)
xlabel('Predicted S','FontSize',20)
ylabel('Observed S','FontSize',20)
text1={['WCC R^2: ',sprintf('%.2f',WCstats(1,1))]}
    annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',20);
    text8={['S=4yearAP+1YearAT+2YearMRres']}
    annotation('textbox',[.2 .1 .1 .2],'String',text8,'EdgeColor','none','fontsize',20);
ax = gca; % current axes
ax.FontSize = 20;
%ylim([.2 .8])
%xlim([.2 .8])

   for k=1:7
WCzscore(:,k)=(WC(:,k)-(nanmean(WC(:,k)))/nanstd(WC(:,k)))
   end
[WCBNorm,~,~,~,WCstatsnorm]= regress(allbaseflow(:,9),[WCzscore ones(length(WC))])

figure;
namesWC = {'P(1Yr)';'P(2Yr)';'P(3Yr)';'P(4Yr)';'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)'};
 subplot(2,1,1)
    bar(WCBNorm)
    ylim([-.1 .1])
    xlim([1 7])
    ylabel('Normalized Corr Coef','fontsize',14')
    subplot(2,1,2)
    bar(WCB)
    ylim([-.1 .1])
    xlim([1 7])
    set(gca,'xtick',[1:7],'xticklabel',namesLC,'fontsize',14)
    ylabel('Corr Coef','fontsize',14')
    title('Chalk Creek')
    
    %%   %% Weber Lost Creek WLC (10th catchment) 1,2,4,0

%% WLC 
%WLC - 1 years annual P, 1 year annual T, 4 years Melt rate
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
% Annual P= position 1 MLR Vars
% Annual T Position 2
% Melt Rate position 3
% Melt Duration position 4

for i=1 %(annual P)
WLC(:,1)=alldata(:,1,10,1)%the entire column from 1 year prev in the past of LostCreek, and annual P
WLC(:,2)=alldata(:,1,10,2)%1 year annual T
WLC(:,3)=alldata(:,1,10,3)% 1st year prev melt rate res
WLC(:,4)=alldata(:,2,10,3)% 2nd year prev melt rate res
WLC(:,5)=alldata(:,3,10,3) % 3rd year prev melt rate res
WLC(:,6)=alldata(:,4,10,3) % 4th year prev melt rate res

end

[WLCB,~,~,~,WLCstats]= regress(allbaseflow(:,10),[WLC ones(length(WLC))])

    WLCBaseflowPredicted=(WLCB(1).*WLC(:,1)+WLCB(2).*WLC(:,2)+WLCB(3).*WLC(:,3)+WLCB(4).*WLC(:,4)...
        +WLCB(5).*WLC(:,5)+WLCB(6).*WLC(:,6)+WLCB(7))

    figure;
plot(WLCBaseflowPredicted,allbaseflow(:,10),'.','MarkerSize',14) %predicted Baseflow vs observed baseflow
lsline
title('Predicted S Using Antecedent Climate Conditions: Lost Creek','FontSize',20)
xlabel('Predicted S','FontSize',20)
ylabel('Observed S','FontSize',20)
text1={['LC R^2: ',sprintf('%.2f',WLCstats(1,1))]}
    annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',20);
    text8={['S=1yearAP+1YearAT+4YearMRres']}
    annotation('textbox',[.2 .1 .1 .2],'String',text8,'EdgeColor','none','fontsize',20);
ax = gca; % current axes
ax.FontSize = 20;
%ylim([.2 .8])
%xlim([.2 .8])

   for k=1:6
WLCzscore(:,k)=(WLC(:,k)-(nanmean(WLC(:,k)))/nanstd(WLC(:,k)))
   end
[WLCBNorm,~,~,~,WLCstatsnorm]= regress(allbaseflow(:,10),[WLCzscore ones(length(WLC))])

figure;
namesWLC = {'P(1Yr)';'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MR(3Yr)';'MR(4Yr)'};
 subplot(2,1,1)
    bar(WLCBNorm)
    ylim([-.1 .1])
    xlim([1 6])
    ylabel('Normalized Corr Coef','fontsize',14')
    subplot(2,1,2)
    bar(WLCB)
    ylim([-.1 .1])
    xlim([1 6])
    set(gca,'xtick',[1:6],'xticklabel',namesWLC,'fontsize',14)
    ylabel('Corr Coef','fontsize',14')
    title('Lost Creek')
    
    %%   %% Weber Ogden South Fork Creek WOSF (11th catchment) 1,1,1,0

%% WOSF 
%WOSF - 1 years annual P, 1 year annual T, 1 years Melt rate
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
% Annual P= position 1 MLR Vars
% Annual T Position 2
% Melt Rate position 3
% Melt Duration position 4

for i=1 %(annual P)
WOSF(:,1)=alldata(:,1,11,1)%the entire column from 1 year prev in the past of LostCreek, and annual P
WOSF(:,2)=alldata(:,1,11,2)%1 year annual T
WOSF(:,3)=alldata(:,1,11,3)% 1st year prev melt rate res


end

[WOSFB,~,~,~,WOSFstats]= regress(allbaseflow(:,11),[WOSF ones(length(WOSF))])

    WOSFBaseflowPredicted=(WOSFB(1).*WOSF(:,1)+WOSFB(2).*WOSF(:,2)+WOSFB(3).*WOSF(:,3)+WOSFB(4))

    figure;
plot(WOSFBaseflowPredicted,allbaseflow(:,11),'.','MarkerSize',14) %predicted Baseflow vs observed baseflow
lsline
title('Predicted S Using Antecedent Climate Conditions: Ogden South Fork','FontSize',20)
xlabel('Predicted S','FontSize',20)
ylabel('Observed S','FontSize',20)
text1={['OSF R^2: ',sprintf('%.2f',WOSFstats(1,1))]}
    annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',20);
    text8={['S=1yearAP+1YearAT+1YearMRres']}
    annotation('textbox',[.2 .1 .1 .2],'String',text8,'EdgeColor','none','fontsize',20);
ax = gca; % current axes
ax.FontSize = 20;
%ylim([.2 .8])
%xlim([.2 .8])

   for k=1:3
WOSFzscore(:,k)=(WOSF(:,k)-(nanmean(WOSF(:,k)))/nanstd(WOSF(:,k)))
   end
[WOSFNorm,~,~,~,WOSFstatsnorm]= regress(allbaseflow(:,11),[WOSFzscore ones(length(WOSF))])

figure;
namesWOSF = {'P(1Yr)';'T(1Yr)'; 'MR(1Yr)'};
 subplot(2,1,1)
    bar(WOSFNorm)
    ylim([-.1 .1])
    xlim([1 3])
    ylabel('Normalized Corr Coef','fontsize',14')
    subplot(2,1,2)
    bar(WOSFB)
    ylim([-.1 .1])
    xlim([1 3])
    set(gca,'xtick',[1:3],'xticklabel',namesWOSF,'fontsize',14)
    ylabel('Corr Coef','fontsize',14')
    title('Ogden South Fork Creek')
    
    %%
   
   %% Weber Headwaters WO (12th catchment) 4,1,2,0
%% WO
%WO - 4 years annual P, 1 year annual T, 2 years Melt rate
%alldata=(year on record, prev years calculated, number of catchments, number of mlr
%vars)
% Annual P= position 1 MLR Vars
% Annual T Position 2
% Melt Rate position 3
% Melt Duration position 4

for i=1 %(annual P)
WO(:,1)=alldata(:,1,12,1)%1st year annual P
WO(:,2)=alldata(:,2,12,1)%2nd year annual P
WO(:,3)=alldata(:,3,12,1)%3rd year annual P
WO(:,4)=alldata(:,4,12,1)%4th year annual P
WO(:,5)=alldata(:,1,12,2)%1 year annual T
WO(:,6)=alldata(:,1,12,3)%1st year prev melt rate res
WO(:,7)=alldata(:,2,12,3)%2nd year prev melt rate res


end

[WOB,~,~,~,WOstats]= regress(allbaseflow(:,12),[WO ones(length(WO))])

    WOBaseflowPredicted=(WOB(1).*WO(:,1)+WOB(2).*WO(:,2)+WOB(3).*WO(:,3)+WOB(4).*WO(:,4)+WOB(5).*WO(:,5)...
        +WOB(6).*WO(:,6)+WOB(7).*WO(:,7)+WOB(8))

    figure;
plot(WOBaseflowPredicted,allbaseflow(:,12),'.','MarkerSize',14) %predicted Baseflow vs observed baseflow
lsline
title('Predicted S Using Antecedent Climate Conditions: Weber Headwaters','FontSize',20)
xlabel('Predicted S','FontSize',20)
ylabel('Observed S','FontSize',20)
text1={['WO R^2: ',sprintf('%.2f',WOstats(1,1))]}
    annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',20);
    text8={['S=4yearAP+1YearAT+2YearMRres']}
    annotation('textbox',[.2 .1 .1 .2],'String',text8,'EdgeColor','none','fontsize',20);
ax = gca; % current axes
ax.FontSize = 20;
%ylim([.2 .8])
%xlim([.2 .8])

   for k=1:7
WOzscore(:,k)=(WO(:,k)-(nanmean(WO(:,k)))/nanstd(WO(:,k)))
   end
[WONorm,~,~,~,WOstatsnorm]= regress(allbaseflow(:,12),[WOzscore ones(length(WO))])

figure;
namesWOSF = {'P(1Yr)';'P(2Yr)';'P(3Yr)';'P(4Yr)';'T(1Yr)'; 'MR(1Yr)'; 'MR(2Yr)'};
 subplot(2,1,1)
    bar(WONorm)
    ylim([-.1 .1])
    xlim([1 7])
    ylabel('Normalized Corr Coef','fontsize',14')
    subplot(2,1,2)
    bar(WOB)
    ylim([-.1 .1])
    xlim([1 7])
    set(gca,'xtick',[1:3],'xticklabel',namesWOSF,'fontsize',14)
    ylabel('Corr Coef','fontsize',14')
    title('Weber at Ogden')
    
%% Corrcoefs of all 7 creeks in one plot

figure;
namesCC = {'P(1Yr)'; 'P(2Yr)'; 'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MR(3Yr)';'MD(1Yr)';'MD(2Yr)';'MD(3Yr)'};
        subplot(7,1,1)    
bar(CCBNorm)
    ylim([-.1 .1])
    xlim([1 9])
    set(gca,'xtick',[1:9],'xticklabel',namesCC)
    %ylabel('Normalized Corr Coef','fontsize',14')
    %title('City Creek')
        subplot(7,1,2)
    namesRB = {'P(1Yr)'; 'P(2Yr)';'P(3Yr)'; 'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MD(1Yr)'};
    bar(RBBNorm)
    ylim([-.1 .1])
    xlim([1 7])
    set(gca,'xtick',[1:7],'xticklabel',namesRB)
    %ylabel('Normalized Corr Coef','fontsize',14')
    %title('Red Butte Creek')
        subplot(7,1,3)
    namesEC = {'P(1Yr)'; 'P(2Yr)'; 'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MD(1Yr)';'MD(2Yr)'};
    bar(ECBNorm)
    ylim([-.1 .1])
    xlim([1 7])
    set(gca,'xtick',[1:7],'xticklabel',namesEC)
    %ylabel('Normalized Corr Coef','fontsize',14')
    %title('Emigration Creek')
        subplot(7,1,4)
    namesPC = {'P(1Yr)'; 'P(2Yr)'; 'P(3Yr)';'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MD(1Yr)';'MD(2Yr)';'MD(3Yr)'};
    bar(PCBNorm)
    ylim([-.1 .1])
    xlim([1 9])
    set(gca,'xtick',[1:9],'xticklabel',namesPC)
    %ylabel('Normalized Corr Coef','fontsize',14')
    %title('Parleys Creek')
         subplot(7,1,5)
    namesMC = {'P(1Yr)'; 'P(2Yr)'; 'P(3Yr)';'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MD(1Yr)';'MD(2Yr)';'MD(3Yr)'};
    bar(MCBNorm)
    ylim([-.1 .1])
    xlim([1 9])
    set(gca,'xtick',[1:9],'xticklabel',namesMC)
    %ylabel('Normalized Corr Coef','fontsize',14')
    %title('Mill Creek')
         subplot(7,1,6)
    namesBC = {'P(1Yr)'; 'P(2Yr)'; 'P(3Yr)';'T(1Yr)'; 'MR(1Yr)';'MR(2Yr)';'MR(3Yr)';'MD(1Yr)';'MD(2Yr)';'MD(3Yr)'};
    bar(BCBNorm)
    ylim([-.1 .1])
    xlim([1 10])
    set(gca,'xtick',[1:10],'xticklabel',namesBC)
    %ylabel('Normalized Corr Coef','fontsize',14')
    %title('Big Cottonwood Creek')
         subplot(7,1,7)
    namesLC = {'P(1Yr)';'T(1Yr)'; 'MR(1Yr)';'MD(1Yr)';'MD(2Yr)';'MD(3Yr)'};
    bar(LCBNorm)
    ylim([-.1 .1])
    xlim([1 6])
    set(gca,'xtick',[1:6],'xticklabel',namesLC)
    %ylabel('Normalized Corr Coef','fontsize',14')
    
%%

%PS=predictedStorage
PS(:,1)=CCBaseflowPredicted
PS(:,2)=RBBaseflowPredicted
PS(:,3)=ECBaseflowPredicted
PS(:,4)=PCBaseflowPredicted
PS(:,5)=MCBaseflowPredicted
PS(:,6)=BCBaseflowPredicted
PS(:,7)=LCBaseflowPredicted
PS(:,8)=WCCBaseflowPredicted
PS(:,9)=WLCBaseflowPredicted
PS(:,10)=WOSFBaseflowPredicted
PS(:,11)=WOBaseflowPredicted
save('PredictedStorage.mat','PS')

  figure
    for i=1:11 
plot(PS(:,i),allbaseflow(:,i),'.','Color',ColorSet(i,:),'MarkerSize',14) %predicted change in storage vs observed change in storage
hold on
title('Predicted S Using Antecedent Climate Conditions','FontSize',20)
xlabel('Predicted S','FontSize',20)
ylabel('Observed S','FontSize',20)
% text1={['CC-R^2: ',num2str(CCstats(1,1),'%.2f')...
%     'RB-R^2: ',num2str(RBstats(1,1) ,'%.2f'),...
%     'EC-R^2: ',num2str(ECstats(1,1) ,'%.2f'),... 
%     'PC-R^2: ',num2str(PCstats(1,1) ,'%.2f'),... 
%     'MC-R^2: ',num2str(MCstats(1,1) ,'%.2f'),... 
%     'BC-R^2: ',num2str(BCstats(1,1) ,'%.2f'),... 
%     'LC-R^2: ',num2str(LCstats(1,1) ,'%.2f')]}
%     annotation('textbox',[.2 .7 .1 .2],'String',text1,'EdgeColor','none','fontsize',20);
%     text8={['?S=2yearAP+1YearAT+2YearMRres+2YearsMDres']}
%     annotation('textbox',[.2 .1 .1 .2],'String',text8,'EdgeColor','none','fontsize',20);
ax = gca; % current axes
ax.FontSize = 20;
ylim([0 1])
xlim([0 1])
    end
%lsline
%ylim([0 1])
%xlim([0 1])
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=4

%%
%predictedvsobserved storage stats
POSR(:,1)=CCstats(1,1)
POSR(:,2)=RBstats(1,1)
POSR(:,3)=ECstats(1,1)
POSR(:,4)=PCstats(1,1)
POSR(:,5)=MCstats(1,1)
POSR(:,6)=BCstats(1,1)
POSR(:,7)=LCstats(1,1)
POSR(:,8)=WCstats(1,1)
POSR(:,9)=WLCstats(1,1)
POSR(:,10)=WOSFstats(1,1)
POSR(:,11)=WOstats(1,1)

%%
[slope(:,1),~,~,~,stats(1,:)]=regress(meanJanQ(:,1),[CCBaseflowPredicted ones(length(CC))])
[slope(:,2),~,~,~,stats(2,:)]=regress(meanJanQ(:,2),[RBBaseflowPredicted ones(length(LC))])
[slope(:,3),~,~,~,stats(3,:)]=regress(meanJanQ(:,3),[ECBaseflowPredicted ones(length(LC))])
[slope(:,4),~,~,~,stats(4,:)]=regress(meanJanQ(:,4),[PCBaseflowPredicted ones(length(LC))])
[slope(:,5),~,~,~,stats(5,:)]=regress(meanJanQ(:,5),[MCBaseflowPredicted ones(length(LC))])
[slope(:,6),~,~,~,stats(6,:)]=regress(meanJanQ(:,6),[BCBaseflowPredicted ones(length(LC))])
[slope(:,7),~,~,~,stats(7,:)]=regress(meanJanQ(:,7),[LCBaseflowPredicted ones(length(LC))])

%% Precip vs Discharge

figure
    for i=1:11 
plot(allprecip(:,i),allstreamflow(:,i),'.','Color',ColorSet(i,:),'MarkerSize',14) %predicted change in storage vs observed change in storage
hold on
title('Precipitation vs Discharge','FontSize',20)
xlabel('Precipitation','FontSize',20)
ylabel('Discharge','FontSize',20)
ax = gca; % current axes
ax.FontSize = 20;
[~,~,~,~,PQstats(i,:)]=regress(allstreamflow(:,i),[allprecip(:,i) ones(length(allprecip(:,1)),1)])
    end
%lsline
%ylim([0 1])
%xlim([0 1])
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=4

%%
%predictedvsobserved storage stats
POSR(:,1)=CCstats(1,1)
POSR(:,2)=RBstats(1,1)
POSR(:,3)=ECstats(1,1)
POSR(:,4)=PCstats(1,1)
POSR(:,5)=MCstats(1,1)
POSR(:,6)=BCstats(1,1)
POSR(:,7)=LCstats(1,1)
POSR(:,8)=WCstats(1,1)
POSR(:,9)=WLCstats(1,1)
POSR(:,10)=WOSFstats(1,1)
POSR(:,11)=WOstats(1,1)