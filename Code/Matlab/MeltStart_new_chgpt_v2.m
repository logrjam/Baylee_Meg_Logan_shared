clearvars;
close all;

load LoganThesisDatasets/LoganUpdatedMeltMetrics/allmeltstart.mat % compare against thresh technique
load LoganThesisDatasets/LoganUpdatedMeltMetrics/allmeltend.mat
ncatch=12; nyrs=118;
load alldailyq.mat;
% different way to find peak q, but with identical results
ipeakq=nan(nyrs,ncatch);
for i =1:nyrs
    for j=1:ncatch
        if (sum(isnan(alldailyq(:,i,j))))<1
            [pks, locs] =findpeaks(alldailyq(100:end,i,j)); %look after 100th day only
            ipeakq(i,j) = 99 + locs(find(pks==max(pks),1)); %add in offset           
        else
            continue
        end
    end
end
ipeakq(67:end,10)=nan; %remove WLC data after dam was built-not indicative of melt
ipeakq(34,1:5)=nan; %other screened site-years with bad data
ipeakq(11,3)=nan;
ipeakq(61,3) = nan;
ipeakq(92,3) = nan;
ipeakq(77,11) = nan;

meltstartcp=nan(nyrs,ncatch);
for i =1:nyrs
    for j=1:ncatch
        if (~isnan(ipeakq(i,j)))&&(~isnan(allmeltstart(i,j)))
            chgpt = findchangepts(alldailyq(allmeltstart(i,j):ipeakq(i,j),i,j),'statistic','linear');
            if ~isempty(chgpt)
                meltstartcp(i,j)=allmeltstart(i,j) + chgpt;
            else
                meltstartcp(i,j)=allmeltstart(i,j);
            end
        else
            continue
        end
    end
end

catchid =1; %plot to verify
for i =76
    figure; plot(alldailyq(:,i,catchid)); hold on;
    plot(meltstartcp(i,catchid),0,'*'); plot(allmeltstart(i,catchid),0,'o');
end

meltendcp = nan(nyrs,ncatch);
for i =1:nyrs
    for j =1:ncatch
        if ~isnan(ipeakq(i,j))
            [meltendcp(i,j),~] = findchangepts(smooth(alldailyq(ipeakq(i,j):end,i,j)),'statistic','linear');
        else
            continue
        end
    end
end
meltendcp = meltendcp + ipeakq;
meltdurcp = meltendcp - meltstartcp;

meltvolcp = nan(nyrs,ncatch);
meltvolrisingcp = nan(nyrs,ncatch);
meltvolfallingcp = nan(nyrs,ncatch);

for i =1:nyrs
    for j=1:ncatch
        if(~isnan(meltstartcp(i,j)))&&(~isnan(meltendcp(i,j)))
            meltvolcp(i,j) = sum(alldailyq(meltstartcp(i,j):meltendcp(i,j),i,j));
            meltvolrisingcp(i,j) = sum(alldailyq(meltstartcp(i,j):ipeakq(i,j),i,j));
            meltvolfallingcp(i,j) = sum(alldailyq(ipeakq(i,j):meltendcp(i,j),i,j));

        else 
            continue
        end
    end
end

meltratecp = meltvolcp./meltdurcp;
meltraterisingcp = meltvolrisingcp./(ipeakq-meltstartcp);
meltratefallingcp = meltvolfallingcp./(meltendcp-ipeakq);

% save('SLCandWeber/LoganUpdatedMeltMetrics/meltstartcp.mat','meltstartcp');
% save('SLCandWeber/LoganUpdatedMeltMetrics/meltendcp.mat','meltendcp');
% save('SLCandWeber/LoganUpdatedMeltMetrics/meltdurcp.mat','meltdurcp');
% save('SLCandWeber/LoganUpdatedMeltMetrics/meltratecp.mat','meltratecp');
% save('SLCandWeber/LoganUpdatedMeltMetrics/meltvolcp.mat','meltvolcp');
% save('SLCandWeber/LoganUpdatedMeltMetrics/meltraterisingcp.mat','meltraterisingcp');
% save('SLCandWeber/LoganUpdatedMeltMetrics/meltvolrisingcp.mat','meltvolrisingcp');
% save('LoganThesisDatasets/LoganUpdatedMeltMetrics/meltratefallingcp.mat','meltratefallingcp');
% save('LoganThesisDatasets/LoganUpdatedMeltMetrics/meltvolfallingcp.mat','meltvolfallingcp');
% save('BoxSync/LoganUpdatedMeltMetrics/ipeakq.mat','ipeakq');



    