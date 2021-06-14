%% Anushree R. Chaphalkar, IISER Pune
%% Created: June, 2013
%% Modified: June, 2016
function [stats_per_track,inst_stats,nooftracks]= quantify(outpath,  scal_fact, interval, distUnit, timeUnit)
% To measure displacement(dx), velocity(dx/dy) and
% tortuosity(displacement/distance)
% from tracks generated automatically in the kymograph
%=========== INPUT ========================================================
% 1. Tracklist.txt
% 2. Variables:
%    outpath= 'd:/test'       % input-output path 
%    distUnit='Pixels'        % units of length
%    timeUnit='Frame'         % units of time
%    scal_fact=1              % microscopy scaling factor(distUnit/pixel)
%    interval=1               % time interval between frames (timeUnit)
%=========== OUTPUT (in folder 'amtrak')===================================
% 1. OutputStats.txt
% 2. USER_InstStats.txt
% 3. USER_TrackStats.txt
%==========================================================================
% output folder path

%% reading in Track coords
INT=importdata([outpath, '/Tracklist.txt'],'\t', 1);
cont=INT.data;
if isempty(cont)
   errordlg('No tracks detected in the kymograph', 'Error')
else
%% Number of tracks
nooftracks= numel(unique(cont(:,1)));

% initialize arrays
maxcont=max(cont(:,1));
mincont=min(cont(:,1));
arr=cell(1,maxcont); % preallocation of 'arr'
Dtotal=arr;
Vtotal=arr;
inst_time=arr;
Ttotal=arr;
nonabs_instdisp=arr;
inst_disp=arr;
frno=arr;
nonabs_vel=arr;
inst_velocity=arr;
meaninvel=arr;
tortu_numerator=zeros(maxcont,2);
%% arranging all tracs in separate cells
% looping over each track, grp= each Track
for grp=mincont: maxcont
    [kappa]= find(cont(:,1)== grp);  % search track numbers
    arr{grp}= cont(kappa,2:3);
    X= arr{grp}(:,1);  % x coords
    Y= arr{grp}(:,2);  % y coords
    siz= size(arr{grp},1);

        % initializing arrays
        inst_time{grp}=[];
        nonabs_instdisp{grp}=[];
        Ttotal{grp}=[];
        
        %% looping over each coordinate-pair in a track
        for idx= 1: size(X,1)-1
            % signs for direction of movement, left=minus, right=plus
            nonabs_disp= (X(idx+1)- X(idx))*scal_fact; % signed inst disp
            nonabs_instdisp{grp}= [nonabs_instdisp{grp}; grp,nonabs_disp];
            
            % inst time (subtraction)
            dy_now= (abs((Y(idx+1)- Y(idx))))*interval;
            inst_time{grp}= [inst_time{grp}; grp,  dy_now];
        end
        
        %% net displacement (subtraction)
        first_last_coords= [arr{grp}(1,:); arr{grp}(siz,:)];
        Disp_per_trac=(abs(first_last_coords(2,1)-first_last_coords(1,1)))*scal_fact;
               
        tortu_numerator(grp,:)= [grp, Disp_per_trac];
        
        % total time
        samay= (first_last_coords(2,2)- first_last_coords(1,2))*interval;
        Ttotal{grp}= [Ttotal{grp}; grp,samay];
        
        % normalizing time
        frno{grp}= (Y(2:end)- Y(1))*interval;
        % (required for a few plots)
        
        % absolute inst disp
        inst_disp{grp}= [nonabs_instdisp{grp}(:,1),  abs(nonabs_instdisp{grp}(:,2))];
        % inst velocity = displacement/time
        nonabs= nonabs_instdisp{grp}(:,2)./inst_time{grp}(:,2);
        % searching and replacing NaNs with 0
        findnanvel= nonabs;
        fn=isnan(findnanvel);
        [pos]=find(fn(:,1)==1);  %change NaN velocities to 0
        findnanvel(pos)=0;
        nonabs_vel{grp}=[nonabs_instdisp{grp}(:,1), findnanvel];
        clear findnanvel nonabs pos;
        inst_velocity{grp}= abs(nonabs_vel{grp}(:,2)); % abs vel
        % (vel vector for plot against norm time)
        
        % total displacement
        Dtotal{grp}= [grp, (sum(inst_disp{grp}(:,2)))];
        
        % speed= Total disp/total time
        findnanV= Dtotal{grp}(:,2)./Ttotal{grp}(:,2);  %speed
        % searching and replacing NaNs with 0
        fn=isnan(findnanV);
        [pos]=find(fn(:,1)==1);
        findnanV(pos)=0;
        Vtotal{grp}= [grp, findnanV];
        clear findnanV fn pos;
        
        % mean and sd of invel
        meaninvel{grp}=[grp, mean(inst_velocity{grp}), std(inst_velocity{grp})];
    %end
end

%% Total pathlength for each Track
tortu_denom= cat(1, Dtotal{:});
avgdisp= mean(tortu_denom(:,2));
sddisp= std(tortu_denom(:,2));
% figure, bar(tortu_denom(:,1), tortu_denom(:,2));
% set(gcf,'Visible', visstatus,'NumberTitle','off', 'Name', 'Total Displacement per Track')
% set(gca,'fontname', 'Times New Roman', 'fontsize', 18, 'fontweight', 'bold')
% xlabel('Track no.'), ylabel(['D (',distUnit, ')' ])
% print(gcf, '-dpdf', [outpath, '/Totaldisppertrack', '.pdf'], '-r720');

%% Speed i.e pathlength/time
vAll= cat(1, Vtotal{:});
avgspeed= mean(vAll(:,2));
sdspeed= std(vAll(:,2));
% figure, bar(vAll(:,1), vAll(:,2));
% set(gcf,'Visible', 'off','NumberTitle','off', 'Name', 'Speed per Track')
% set(gca,'fontname', 'Times New Roman', 'fontsize', 18, 'fontweight', 'bold')
% xlabel('Track no.'), ylabel(['S (', distUnit,' per ',  timeUnit,')'])
% print(gcf, '-dpdf', [outpath,'/Speedpertrack', '.pdf'], '-r720');

%% Tot time for each Track
tAll= cat(1, Ttotal{:});
avgtime= mean(tAll(:,2));
sdtime=std(tAll(:,2));
% figure, bar(tAll(:,1), tAll(:,2));
% set(gcf,'Visible', 'off','NumberTitle','off', 'Name', 'Time per Track')
% set(gca,'fontname', 'Times New Roman', 'fontsize', 18, 'fontweight', 'bold')
% xlabel('Track no.'), ylabel(['Total time (',  timeUnit,')'])
% print(gcf, '-dpdf', [outpath, '/Timepertrack', '.pdf'], '-r720');

%% All inst velocities distribution
IVEL= cat(1, inst_velocity{:});
MEANinvel=cat(1, meaninvel{:});
avginvel= mean(IVEL);
sdinvel=std(IVEL);
% figure, bar(MEANinvel(:,1), MEANinvel(:,2));
% %hold on, errorbar(MEANinvel(:,2),MEANinvel(:,3), '.k', 'linewidth',2)
% set(gcf,'Visible', visstatus,'NumberTitle','off', 'Name', 'Instantaneous Velocity')
% set(gca,'fontname', 'Times New Roman', 'fontsize', 18, 'fontweight', 'bold')
% xlabel(['\deltav (',distUnit,'/',  timeUnit, ')'])
% ylabel('Frequency')
% print(gcf, '-dpdf', [outpath, '/Inst_velpertrack', '.pdf'], '-r720');

%% All inst disp distribution
IDISP= cat(1, inst_disp{:});
avgindisp= mean(IDISP(:,2));
sdindisp=std(IDISP(:,2));
% figure, hist(IDISP(:,2));
% set(gcf,'Visible', 'off','NumberTitle','off', 'Name', 'Distribution: Instantaneous Displacement')
% set(gca,'fontname', 'Times New Roman', 'fontsize', 18, 'fontweight', 'bold')
% xlabel(['\deltax (', distUnit,')'])
% ylabel('Frequency')
% print(gcf, '-dpdf', [outpath, '/All_inst_disp', '.pdf'], '-r720');
%% Nonabs inst disp
ITIME= cat(1, inst_time{:});
NADISP = cat(1,nonabs_instdisp{:});
NAVEL= cat(1,nonabs_vel{:});
FRNO= cat(1, frno{:});

%% Net velocity-- resultant disp/time for each Track
% net velocity
Vel_per_trac=[tortu_numerator(:,1),tortu_numerator(:,2)./tAll(:,2)];
avgnetvel=mean(Vel_per_trac(:,2));
sdnetvel=std(Vel_per_trac(:,2));
%% Tortuosity
T= tortu_numerator(:,2)./tortu_denom(:,2);
fn=isnan(T);
[pos]=find(fn==1);  %change NaN velocities to 0
T(pos)=0;
avgtortu= mean(T);
sdtortu= std(T);
tortuosity= [tortu_numerator(:,1), T];
clear T fn pos

% figure, bar(tortuosity(:,1), tortuosity(:,2));
% set(gcf,'Visible', visstatus,'NumberTitle','off', 'Name', 'Tortuosity per Track')
% set(gca,'fontname', 'Times New Roman', 'fontsize', 18, 'fontweight', 'bold')
% xlabel('Track no.'), ylabel('\chi')
% print(gcf, '-dpdf', [outpath, '/Tortuosity', '.pdf'], '-r720');

%% write out means and sd
outparam{1}=['Mean pathlength = ', sprintf('%0.3g', avgdisp),' ', distUnit];
outparam{2}=['SD pathlength = ', sprintf('%0.3g', sddisp),' ',distUnit];
outparam{3}=['Mean speed = ', sprintf('%0.3g', avgspeed),' ',distUnit,'/',  timeUnit];
outparam{4}=['SD speed = ', sprintf('%0.3g', sdspeed), ' ', distUnit,'/',  timeUnit];
outparam{5}=['Mean tortuosity = ', sprintf('%0.3g', avgtortu)];
outparam{6}=['SD tortuosity = ', sprintf('%0.3g', sdtortu)];
outparam{7}=['Mean instantaneous displacement = ', sprintf('%0.3g', avgindisp),' ',distUnit];
outparam{8}=['SD instantaneous displacement = ', sprintf('%0.3g', sdindisp),' ', distUnit];
outparam{9}=['Mean instantaneous velocity = ', sprintf('%0.3g', avginvel),' ',distUnit,'/',  timeUnit];
outparam{10}=['SD instantaneous velocity = ', sprintf('%0.3g', sdinvel),' ',distUnit,'/',timeUnit];
outparam{11}=['Mean net(start to end) velocity = ', sprintf('%0.3g', avgnetvel),' ',distUnit,'/',  timeUnit];
outparam{12}=['SD net (start to end) velocity= ', sprintf('%0.3g', sdnetvel),' ',distUnit,'/',  timeUnit];
outparam{13}=['Mean total time = ', sprintf('%0.3g', avgtime),' ',timeUnit];
outparam{14}=['SD total time = ', sprintf('%0.3g', sdtime), ' ',timeUnit];
outparam{15}=['No. of Tracks = ', sprintf('%i', nooftracks)];
outparamAll= char(outparam);
OUTparam= cellstr(outparamAll);
% save stuff in a txt file
fid =fopen([outpath,'/OutputStats.txt'], 'w');
fmtString = [repmat('%s\t',1,size(OUTparam,2)-1),'%s\r\n'];
fprintf(fid,fmtString,OUTparam{:});
fclose(fid);
%% Trackno, totaltime, totaldisp, speed, netvel, tortu, meaninvel, sdinvel
stats_per_track=[tAll,tortu_denom(:,2),vAll(:,2),Vel_per_trac(:,2),tortuosity(:,2), MEANinvel(:,2), MEANinvel(:,3)];
fid =fopen([outpath,'/USER_TrackStats.txt'], 'w');
fprintf(fid, 'Track    Time    Pathlength    Speed    NetVelocity    Tortuosity    MeanInstvel    SDInstvel\r\n');
fclose(fid);
dlmwrite([outpath,'/USER_TrackStats.txt'], stats_per_track,...
'-append', 'delimiter', '\t','newline', 'pc', 'precision', '%.3f');
% Track = tAll(:,1);
% Time = round(tAll(:,2),3);
% Displacement = round(tortu_denom(:,2),3);
% Speed = round(vAll(:,2),3);
% NetVelocity = round(Vel_per_trac(:,2),3);
% Tortuosity=round(tortuosity(:,2),3);
% MeanInstVel = round(MEANinvel(:,2),3);
% SDInstVel =round(MEANinvel(:,3),3);
% stats_per_track=table(Track, Time, Displacement, Speed, NetVelocity, Tortuosity, MeanInstVel, SDInstVel);
% writetable(stats_per_track,[outpath,'/USER_TrackStats.txt'],'Delimiter', '\t');
% clear Track Time Displacement Speed NetVelocity Tortuosity MeanInstVel SDInstVel

%% Trackno,intime, indisp, signed_disp, invel, signed_invel, cumu time
inst_stats =[NADISP(:,1),ITIME(:,2), abs(NADISP(:,2)),NADISP(:,2),IVEL,NAVEL(:,2), FRNO];
fid1 =fopen([outpath,'/USER_InstStats.txt'], 'w');
fprintf(fid1, 'Track    Time    Displacement    SignedDisp  Velocity    SignedVel   CumulativeTime\r\n');
fclose(fid1);
dlmwrite([outpath,'/USER_InstStats.txt'], inst_stats,...
'-append', 'delimiter', '\t','newline', 'pc', 'precision', '%.3f');

% Track = NADISP(:,1);
% Timestep = round(ITIME(:,2),3);
% Displacement = round(abs(NADISP(:,2)), 3);
% SignedDisp = round(NADISP(:,2),3);
% Velocity = round(IVEL,3);
% SignedVel=round(NAVEL(:,2),3);
% CumulativeTime=round(FRNO,3);
% 
% inst_stats=table(Track, Timestep, Displacement, SignedDisp, Velocity, SignedVel, CumulativeTime);
% writetable(inst_stats,[outpath,'/USER_InstStats.txt'],'Delimiter', '\t');
% clear Track Timestep Displacement SignedDisp Velocity SignedVel CumulativeTime
end
end