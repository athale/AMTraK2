%% Anushree R. Chaphalkar, IISER Pune
%% Created: June, 2013
%% Modified: June, 2016
function [catInst,catTracs,nooftracks]= makedistribution(multi,fon,outfolder, distUnit, timeUnit)
%% To pool quantification data 
%% from specified subfolders in the parent folder
%================== INPUT =================================================
% 1. USER_TrackStats.txt
% 2. USER_InstStats.txt
% 3. Variables:
%       multi                    % cell array of multiple subfolder titles
%       numpick = 5              % no. of subfolder chosen to pool
%================== OUTPUT ================================================
% 1. PooledOutputStats.txt
% 2. All_InstStats.txt
% 3. All_TrackStats.txt
%==========================================================================
%% IO paths
if exist('BatchPro', 'dir')==0
    mkdir(outfolder, 'BatchPro');
end
out_path= [outfolder, 'BatchPro/'];

%% Making composite files 
tracs=cell(1,length(multi));
inst=tracs;
% Input from files
for idxcount= 1:length(multi)
    
    % track statistics
    % trackno,totaltime,totaldisp,speed,netvel,tortu,meaninvel,sdinvel,
    T=importdata([multi{idxcount},'/USER_TrackStats.txt'],'\t', 1);
    tracs{idxcount}=T.data;

    % inst stats
    % trackno,intime,indisp,signed_disp,invel,signed_invel, cumu_time
    I= importdata([multi{idxcount},'/USER_InstStats.txt'],'\t', 1);
    inst{idxcount}= I.data;
end
if isempty(tracs) && isempty(inst)
   errordlg('No quantification files found', 'Error')
else
catTracs=cat(1, tracs{:});
catInst=cat(1, inst{:});
nooftracks= size(catTracs,1);

%% Time
% tracno_Time= [catTracs(:,1),catTracs(:,2)]; 
% trackno_Intime= [catInst(:,1), catInst(:,2)];
%% Signed disp, signed vel
% signdisp=catInst(:,4);
% signvel=catInst(:,5);

%% Total displacement
tracklength= catTracs(:,3);
avgdisp= mean(tracklength(:,1));
sddisp=std(tracklength(:,1));
% lintl= linspace(0, max(tracklength(:,1)), binNo);
% vectl= hist(tracklength(:,1),lintl);
% figure,bar(lintl, vectl);
% set(gcf,'Visible', visstatus, 'NumberTitle','off', 'Name', 'Total Displacement');
% set(gca,'fontname', 'Times New Roman', 'fontsize', 18, 'fontweight', 'bold');
% xlabel(['\Sigmad (',  distUnit, ')']);
% ylabel('Frequency');
% %axis([0 14 0 6]);
% print(gcf, '-dpdf', [out_path,'Totaldisp.pdf'], '-r720');

%% Speed: total disp/total time
Speed= catTracs(:,4);
avgspeed=mean(Speed(:,1));
sdspeed=std(Speed(:,1));
% linsp= linspace(0,max(Speed(:,1)), binNo);
% vecsp= hist(Speed(:,1),linsp);
% figure,bar(linsp, vecsp);
% set(gcf,'Visible', 'off','NumberTitle','off', 'Name', 'Speed');
% set(gca,'fontname', 'Times New Roman', 'fontsize', 18, 'fontweight', 'bold');
% xlabel(['v (',  distUnit,'/', timeUnit, ')']);
% ylabel('Frequency');
% %axis([0 0.35 0 5]);
% print(gcf, '-dpdf', [out_path,'Speed.pdf'], '-r720');

%% Tortuosity
tortu= catTracs(:,6);
avgtortu=mean(tortu(:,1));
sdtortu=std(tortu(:,1));
% linto= linspace(0, 1, binNo);
% vecto= hist(tortu(:,1),linto);
% figure,bar(linto, vecto);
% set(gcf,'Visible', visstatus,'NumberTitle','off', 'Name', 'Tortuosity');
% set(gca,'fontname', 'Times New Roman', 'fontsize', 18, 'fontweight', 'bold');
% xlabel('\chi');
% ylabel('Frequency');
% %axis([0 1 0 4]);
% print(gcf, '-dpdf', [out_path,'Tortu.pdf'], '-r720');

%% Instantaneous displacement
Indisp= catInst(:,3);
avgindisp= mean(Indisp(:,1));
sdindisp= std(Indisp(:,1));
% linid= linspace(0, max(Indisp(:,1)),binNo);
% vecid= hist(Indisp(:,1),linid);
% figure,bar(linid, vecid);
% set(gcf,'Visible', 'off','NumberTitle','off', 'Name', 'Instantaneous Displacement');
% set(gca,'fontname', 'Times New Roman', 'fontsize', 18, 'fontweight', 'bold');
% xlabel(['\deltax (', distUnit, ')' ]);
% ylabel('Frequency');
% %axis([0 3.5 0 201]);
% print(gcf, '-dpdf', [out_path, 'Instdisp.pdf'], '-r720');

%% Instantaneous velocity
Invel= catInst(:,5);
avginvel= mean(Invel(:,1));
sdinvel= std(Invel(:,1));
% liniv= linspace(0, max(Invel(:,1)),binNo);
% veciv= hist(Invel(:,1),liniv);
% figure,bar(liniv, veciv);
% set(gcf,'Visible', visstatus,'NumberTitle','off', 'Name', 'Instantaneous Velocity');
% set(gca,'fontname', 'Times New Roman', 'fontsize', 18, 'fontweight', 'bold');
% xlabel(['\deltav (',  distUnit,'/', timeUnit, ')']);
% ylabel('Frequency');
% %axis([0 3.5 0 201]);
% print(gcf, '-dpdf', [out_path,'Instvel.pdf'], '-r720');

%% Net velocity
Resvel= catTracs(:,5);
avgresvel= mean(Resvel(:,1));
sdresvel= std(Resvel(:,1));

%% Writing out
fid1 =fopen([out_path,'All_InstStats.txt'], 'w'); 
fprintf(fid1, 'Track    Time	Displacement	SignedDisp	Velocity	SignedVel	CumulativeTime\r\n');
fclose(fid1) ;
dlmwrite([out_path,'All_InstStats.txt'], catInst, '-append',...
    'delimiter', '\t','newline', 'pc', 'precision', '%0.3f');

fid =fopen([out_path,'All_TrackStats.txt'], 'w') ;
fprintf(fid, 'Track    Time    TotalDisplacement    Speed   NetVelocity    Tortuosity    MeanInVel    SDInvel\r\n');
fclose(fid) ;
dlmwrite([out_path,'All_TrackStats.txt'], catTracs, '-append',...
    'delimiter', '\t','newline', 'pc', 'precision', '%0.3f');


%% write out means and sd
outparam{1}= ['Subfolders = ', fon ];
outparam{2}=['Mean Total displacement = ', sprintf('%0.3g', avgdisp), ' ',distUnit];
outparam{3}=['SD Total displacement = ', sprintf('%0.3g', sddisp),' ',distUnit];
outparam{4}=['Mean speed = ', sprintf('%0.3g', avgspeed),' ', distUnit,'/',  timeUnit];
outparam{5}=['SD speed = ', sprintf('%0.3g', sdspeed), ' ',distUnit,'/', timeUnit];
outparam{6}=['Mean tortuosity = ', sprintf('%0.3g', avgtortu)];
outparam{7}=['SD tortuosity = ', sprintf('%0.3g', sdtortu)];
outparam{8}=['Mean instantaneous displacement = ', sprintf('%0.3g', avgindisp), ' ',distUnit];
outparam{9}=['SD instantaneous displacement = ', sprintf('%0.3g', sdindisp),' ', distUnit];
outparam{10}=['Mean instantaneous velocity = ', sprintf('%0.3g', avginvel),' ',distUnit,'/',  timeUnit];
outparam{11}=['SD instantaneous velocity = ', sprintf('%0.3g', sdinvel),' ', distUnit,'/', timeUnit];
outparam{12}=['Mean net(start to end) velocity = ', sprintf('%0.3g', avgresvel), ' ',distUnit,'/',  timeUnit];
outparam{13}=['SD net (start to end) velocity= ', sprintf('%0.3g', sdresvel),' ', distUnit,'/', timeUnit];
outparam{14}=['No. of Tracks = ',sprintf('%i', nooftracks)];
outparamAll= char(outparam);
OUTparam= cellstr(outparamAll);

% save stuff in a txt file
fid =fopen([out_path, 'BatchStats.txt'], 'w');
fmtString = [repmat('%s\t',1,size(OUTparam,2)-1),'%s\r\n'];
fprintf(fid,fmtString,OUTparam{:});
fclose(fid);
end
end