%% Anushree R. Chaphalkar, IISER Pune
%% Created: June, 2013
%% Modified: June, 2016
function nsplits=maketracks(outpath, min_thresh, splitting, X_axis_thr, time_thresh, remove_extra, minpeak, scal_fact, interval, distUnit, timeUnit,usedcanny,figg)
%% Join minimally distant peaks along the time axis in the kymograph.
%==================== INPUT ===============================================
% 1.OutputKymo.txt
% 2.Brightcoords.txt
% 3.Variables:
%  outpath= 'd:/amtrak-1'   % input-output path
%  min_thresh=10            % peak search radius (pixels)
%  splitting=0              % boolean for convergence of tracks in proximity
%  X_axis_thr= 5            % distance threshold (pixels) for splitting
%  time_thresh= 5           % time threshold (y axis) for splitting
%  remove_extra=1           % boolean to remove redundant tracks
%  distUnit='Pixels'        % units of length
%  timeUnit='Frame'         % units of time
%  scal_fact=1              % microscopy scaling factor(distUnit/pixel)
%  interval=1               % time interval between frames (timeUnit)
%  usedcanny=1              % boolean,1:edge detectn was used to find peaks
%================== OUTPUT ================================================
% 1. PlotContour.tif
% 2. Tracklist.txt
% 3. Branchpoints.txt
%==========================================================================
%% Reading peak coords and kymo matrix
% brightcoords = 1:x-coordinates of peaks, 2:slice numbers(y- coordinates) 
CONT=importdata([outpath, '/Brightcoords.txt'],'\t', 1);
contours=CONT.data;
Image= dlmread([outpath, '/OutputKymo.txt']);
siz=size(Image);
% if canny edge detection is used, pads of zeroes on the sides of
% the kymograph have to be taken off
if usedcanny==1
    Image(:,1)=[];
    Image(:,end)=[];
end


%% Lowest and highest slice numbers that carry bright points
mn= min(contours(:,2));
mx= max(contours(:,2));
NEW=cell(1,mx-mn);
%% Arranging the peaks time-wise
i=0;
for g= mn: mx
    [row]= find(contours(:,2)== g);
    if ~isempty(row) % getting rid of empty cells
        i=i+1;
        NEW{i}= contours(row,1:2); % slicewise peak arrangement
    else
        continue
    end
end
clear i
%% Initializing the trajectory start-points
% trac= cell array of trajectories
peaksinfirstSlice= size(NEW{1},1); %initial no. of tracks
trac=cell(1,peaksinfirstSlice); %preallocating

for u=1: peaksinfirstSlice
    % each bright peak in the first slice makes a new track
    trac{u}= NEW{1}(u,:);%  x,y
end

exclu=cell(length(NEW),1); %length of exclu is total no. of slices
exclu{1}=NEW{1}; % slice one

%% Display kymo
spacingXAxis= round(siz(2)/4);
spacingYAxis= round(siz(1)/4);
fh=figure(figg);
movegui(fh, 'west');
set(fh,'NumberTitle','off', 'Name', 'Track Detection');
imshow(imadjust(Image),'InitialMagnification', 'fit');
%colorbar;
colormap(gray);
axis ij, axis on;
axis normal;
set(gca,'fontname', 'Times New Roman',...
    'fontsize', 18,...
    'XTick', 0:spacingXAxis:siz(2)-1,...
    'YTick', 0:spacingYAxis:siz(1)-1,...
    'XTicklabel', (0:spacingXAxis:siz(2)-1).*scal_fact,...
    'YTicklabel', (0:spacingYAxis:siz(1)-1).*interval);
xlabel(['Distance (',sprintf('%s', distUnit), ')']);
ylabel(['Time (', timeUnit, ')']);
w = waitbar(0, 'Making tracks..');
movegui(w, 'north');
%% Selecting 2 slices at a time and finding distances pairwise
for vv = 1: length(NEW)-1 % for every slice
    waitbar(vv/numel(length(NEW)-1));
    
    %% Making trajectories
    for cel= 1: length(trac) %for every Track 
        celSize= size(trac{cel},1);
        lastPoint= trac{cel}(celSize,:);
        %cell list algorithm
        ids=findbox2d(lastPoint(1),NEW{vv+1}(:,1),min_thresh,lastPoint(2),NEW{vv+1}(:,2),min_thresh, 'last');
        if ~isempty(ids)
            necessarypts=NEW{vv+1}(ids,:);
            disti= pdist2(necessarypts, lastPoint);
            %No. of rows in disti= no. of rows in necessarypts
            %No. of columns in disti= no. of rows in lastPoint=1
            mVal= min(disti);
            [ro,~] = find(disti(:,1)== mVal);
        else
            continue
            
        end
        
        if length(ro)==1 % only one minimally distant point
            trac{cel}= [trac{cel};necessarypts(ro,:)];
            exclu{vv+1}= [exclu{vv+1}; necessarypts(ro,:)];
        else
            %% In case of multiple minimally distant points
            ro1 = ro(1); %row1- the leftmost coords
            ro2 = ro(2); %row2
            if celSize>1
                ang1=findangle(trac{cel}(celSize-1,:),lastPoint,necessarypts(ro1,:));
                ang2=findangle(trac{cel}(celSize-1,:),lastPoint,necessarypts(ro2,:));
                if ang1>ang2
                    trac{cel}= [trac{cel}; necessarypts(ro1,:)];
                    exclu{vv+1}= [exclu{vv+1}; necessarypts(ro1,:)];
                elseif ang1<ang2
                    trac{cel}= [trac{cel}; necessarypts(ro2,:)];
                    exclu{vv+1}= [exclu{vv+1}; necessarypts(ro2,:)];
                elseif ang1==ang2
                    continue
                    %trac{cel}= [trac{cel}; cel,necessarypts(ro1,:)];
                    %exclu{vv+1}= [exclu{vv+1}; necessarypts(ro1,:)];
                end
                
            elseif celSize==1 && vv==1
                figure(figg),hold on, plot(lastPoint(1), lastPoint(2),...
                    'mo', 'MarkerSize',8,'MarkerFaceColor','m'), hold off
                selection=questdlg('Fork encountered (magenta). Please choose the track direction.',...
                    'Attention','Left', 'Right', 'Ignore', 'Left');
                switch selection,
                    case 'Left',
                        trac{cel}= [trac{cel};necessarypts(ro1,:)];
                        exclu{vv+1}= [exclu{vv+1}; necessarypts(ro1,:)];
                    case 'Right'
                        trac{cel}= [trac{cel}; necessarypts(ro2,:)];
                        exclu{vv+1}= [exclu{vv+1}; necessarypts(ro2,:)];
                    case 'Ignore'
                        continue
                end
                
            end
        end
    end
    %% Including sub-tracs
    if ~isempty(exclu{vv+1})
        uncommon= setxor(NEW{vv+1},exclu{vv+1}, 'rows' );
        if ~isempty(uncommon)
            for iuncom= 1: size(uncommon,1)
                trac{length(trac)+1}=uncommon(iuncom,:);
            end
        end
    else
        continue
    end
end
delete(w);
% modified ARC 29/5/2016
trac(cellfun('size',trac,1)<minpeak) = [];
% minimum no. of peaks in a track-- threshold applied
if isempty(trac)
   errordlg('No tracks found. Please change tracking parameters.', 'Error')
   return
end
%% Eliminate redundant tracks
if remove_extra==1 % if selected
    for remex= length(trac):-1:1
        edittrac1=trac;
        edittrac1{remex}=[];
        notsametrac1=cat(1,edittrac1{:});
        % WARNING:  matlab version check for syntax of 'intersect'
        trim= intersect(trac{remex}, notsametrac1, 'rows', 'legacy');
        
        if size(trim,1)>= size(trac{remex},1)/3
            % decides how many points in common
            % should a coinciding track have
            % in order to be eliminated
            trac{remex}=[];
        else
            continue
        end
    end
end

%modified ARC 29/5/2016
trac=trac(~cellfun('isempty',trac)); % remove empty cells
if isempty(trac)
   errordlg('No tracks found. Please change tracking parameters.', 'Error')
   return
end
%% Quantifying branchpoints
branchpoint=zeros(1,3);
cntbranch=0;
%% Linking tracks lying within threshold distance and time
if splitting==1 % if it's been selected in the gui
    for final=1:length(trac)
        
        tracStart= trac{final}(1,:);%start
        tracEnd= trac{final}(end,:);%end
        
        ystart= trac{final}(1,2);% start and end y coords
        yend = trac{final}(end,2);
        
        xstart=trac{final}(1,1); % start and end x coords
        xend=trac{final}(end,1);
        
        edittrac=trac;
        edittrac{final}=[];
        notsametrac=cat(1,edittrac{:});
        xvec=notsametrac(:,1);
        yvec=notsametrac(:,2);
        idstart=findbox2d(xstart,xvec,X_axis_thr,ystart,yvec,time_thresh,'first');
        idend=findbox2d(xend,xvec,X_axis_thr,yend,yvec,time_thresh,'last');
        
        if ~isempty(idstart)
            iS=[xvec(idstart), yvec(idstart)];
            start_dist= pdist2(iS, tracStart);
            min_start= min(start_dist);
            ir2= find(start_dist(:,1)==min_start);
            trac{final}= [iS(ir2(1),:); trac{final}];
            cntbranch=cntbranch+1;
            branchpoint(cntbranch,:)=[final,iS(ir2(1),:)];
        end
        
        if ~isempty(idend)
            iE=[xvec(idend), yvec(idend)];
            end_dist= pdist2(iE, tracEnd);
            min_end= min(end_dist);
            ir1= find(end_dist(:,1)==min_end);
            trac{final}= [trac{final}; iE(ir1(1),:)];
            cntbranch=cntbranch+1;
            branchpoint(cntbranch,:)=[final,iE(ir1(1),:)];
        end
  
        
    end
    
end
branchpoint=unique(branchpoint, 'rows');
branchpoint(:,2)=branchpoint(:,2).*scal_fact;
branchpoint(:,3)=branchpoint(:,3).*interval;
fid =fopen([outpath,'/Branchpoints.txt'], 'w');
fprintf(fid, ['Track    X-',sprintf('%s',distUnit),'    Time-',sprintf('%s',timeUnit), '\r\n']);
fclose(fid);
dlmwrite([outpath, '/Branchpoints.txt'], branchpoint,'-append',...
    'delimiter', '\t','newline', 'pc', 'precision', '%0.3f');
nsplits=size(branchpoint,1);

%% Plotting contours and mapping intensity
lentrac=length(trac);
colr= hsv(lentrac);% to plot coloured tracs
intenprof=cell(1,lentrac);
normtime=intenprof;
putitall=intenprof; % preallocating
for something= 1: lentrac
    linIndex=sub2ind(size(Image), trac{something}(:,2),trac{something}(:,1));
    linIndex=round(linIndex);
    intenprof{something}= Image(linIndex);
    normtime{something}= (trac{something}(:,2)-trac{something}(1,2)).*interval;
    
    figure(figg), hold on, plot(trac{something}(:,1),...
        trac{something}(:,2),'.-',...
        'Color', colr(something, :),...
        'LineWidth', 2)
    
    text(trac{something}(2,1), trac{something}(2,2),...
        sprintf('%i',something),...
        'Color', 'k', ...
        'EdgeColor', 'r',...
        'BackgroundColor', 'y',...
        'VerticalAlignment', 'Top',...
        'HorizontalAlignment', 'Left',...
        'FontSize',8)
   
putitall{something}= [something*ones(size(trac{something},1),1), trac{something}, intenprof{something}, normtime{something}];
end
 

print(fh, '-dtiffnocompression', [outpath, '/PlotContour.tif']);

%% Arranging all tracks 
if ~isempty(putitall) 
   PUTITALL=cat(1,putitall{:});
%    Track= PUTITALL(:,1);
%    X=PUTITALL(:,2);
%    Y=PUTITALL(:,3);
%    Intensity=PUTITALL(:,4);
%    NormalizedTimeFrame=PUTITALL(:,5);
end
%% Save tracks
fid =fopen([outpath,'/Tracklist.txt'], 'w');
fprintf(fid, 'Track    X    Y    Intensity    NormalizedTimeFrame\r\n');
fclose(fid);
dlmwrite([outpath, '/Tracklist.txt'], PUTITALL,...
    '-append', 'delimiter', '\t','newline', 'pc', 'precision', '%.3f');
% newtable=table(Track,X,Y,Intensity,NormalizedTimeFrame);
% writetable(newtable,[outpath, '/Tracklist.txt'],...
%     'Delimiter', '\t');
% clear Track X Y Intensity NormalizedTimeFrame newtable

end
