%% Anushree R. Chaphalkar, IISER Pune
%% Created: June, 2013
%% Modified: June, 2016
function findbright(outpath, auto, manualcutoff,scal_fact, interval, distUnit, timeUnit,figg)
% Detecting coordinates(x,y) of bright points in an image
%=========================INPUT============================================
% 1. OutputKymo.txt
% 2. Variables:
% outpath= 'd:/amtrak-1'    % input-output path
% distUnit = 'um'           % units of length
% timeUnit = 'min'          % units of time
% scal_fact = 1             % microscopy scaling factor (distUnit/pixel)
% interval = 1              % time interval between frames (timeUnit)
%=========================OUTPUT==========================================
% 1. Peaks.tif
% 2. Brightcoords.txt
%==========================================================================
%% Read the kymograph
IMatrix= dlmread([outpath, '/OutputKymo.txt']);
siz=size(IMatrix);
combin=cell(1,siz(1)); % to store all peak coords
%% NOTE:
% findpeaks_arc function doesnot detect a bright point if it is in the
% rightmost/leftmost column of the kymograph. May be because it has no right
% neighbour that way.
% Therefore the makekymo function includes a step for padding the kymo image matrix
% with a column of zeroes on the right and left.

%% Slicing the matrix horizontally
for ii= 1: siz(1)
    fprintf('.') % to know if the program is running
    slic= IMatrix(ii,:);
    switch auto
        case 1
        convertedImg= imbinarize(slic, graythresh(slic));
        case 0
        convertedImg= imbinarize(slic, manualcutoff); 
    end
    % using 'findpeaks_arc' function, maxtab = list of peaks in every slice
    [maxtab, ~]= findpeaks(convertedImg); % maxtab is a column vector
        
    % adding y coords
    combin{ii}=[maxtab, ones(size(maxtab,1),1)*ii];
end
fprintf('\n') % program didn't crash
combin=combin(~cellfun('isempty',combin));%removing empty rows
COMBIN=cat(1,combin{:});
if ~isempty(COMBIN)
%% Save
fid =fopen([outpath,'/Brightcoords.txt'], 'w');
fprintf(fid, 'X    Y(Timeframe)\r\n');
fclose(fid);
dlmwrite([outpath, '/Brightcoords.txt'], COMBIN,'-append',...
    'delimiter', '\t', 'newline', 'pc', 'precision', '%.3f');
% X=COMBIN(:,1);
% Y=COMBIN(:,2);
% clear COMBIN
% newtable=table(X,Y);
% writetable(newtable,[outpath, '/Brightcoords.txt'],'Delimiter','\t');
% clear newtable
%% Plotting
spacingXAxis= round(siz(2)/4);%tick label spacing x
spacingYAxis= round(siz(1)/4);%and y
figgh=figure(figg);
movegui(figgh, 'west');

set(figgh,'NumberTitle','off', 'Name', 'Peak Detection: Findpeaks');
imshow(imadjust(IMatrix), 'InitialMagnification', 'fit');
hold on
plot(COMBIN(:,1),COMBIN(:,2),'.r', 'MarkerSize',10), hold off
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
xlabel(['Distance (', distUnit, ')']);
ylabel(['Time (',timeUnit, ')']);
% frr=getframe(gcf);
% imwrite(frr.cdata, [ outpath, '/Peaks.tif'],'tif',...
%     'Compression', 'none',  'Resolution', 1/scal_fact);
print(figgh, '-dtiffnocompression', [ outpath, '/Peaks.tif']);
%clear frr
else
    errordlg('No peaks detected', 'Error')
end
end