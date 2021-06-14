%% Anushree R. Chaphalkar, IISER Pune
%% Created: June, 2013
%% Modified: June, 2016
function findbright_edge(outpath, auto, manualcutoff,scal_fact, interval, distUnit, timeUnit,figg)
% Detecting coordinates(x,y) of bright points in an image
%=========================INPUT============================================
% 1. OutputKymo.txt
% 2. Variables:
% outpath= 'd:/amtrak-1'    % input-output path 
% distUnit = 'um'           % units of length
% timeUnit = 'min'          % units of time
% scal_fact = 1             % microscopy scaling factor (distUnit/pixel)
% interval = 1              % time interval between frames (timeUnit)
%=========================OUTPUT===========================================
% 1. Peaks.tif
% 2. Brightcoords.txt
%==========================================================================
%% Read the image file
IMatrix= dlmread([outpath, '/OutputKymo.txt']);
% taking off the padded zeros
IMatrix(:,1)=[];
IMatrix(:,end)=[];

siz=size(IMatrix);
combin=cell(1,siz(1)); % to store all peak coords

%% Slicing the matrix horizontally
zeropad=zeros(1,siz(2)); %padding each slice with zeroes to enable edge detection
for ii= 1: siz(1)
    fprintf('.')
    slic=[zeropad;IMatrix(ii,:);zeropad];
    switch auto
        case 1
        slic=edge(slic, 'canny', graythresh(IMatrix(ii,:))); % edge detection
        case 0
        slic=edge(slic, 'canny', manualcutoff); % edge detection
    end
    
    maxtab = find(slic(2,:)==1) ;  % maxtab is a row vector
    if ~isempty(maxtab)
    combin{ii} = [maxtab', ones(size(maxtab,2),1)*ii];
    else 
        continue
    end
end
fprintf('\n')
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
%% Plot
spacingXAxis= round(siz(2)/4);
spacingYAxis= round(siz(1)/4);
figure(figg),
movegui(gcf, 'west');

set(gcf,'NumberTitle','off', 'Name', 'Peak Detection: Edge');
imshow(imadjust(IMatrix), 'InitialMagnification', 'fit');
hold on
plot(COMBIN(:,1), COMBIN(:,2),'.r', 'MarkerSize',10), hold off;
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
xlabel(['Distance (',distUnit, ')']);
ylabel(['Time (', timeUnit, ')']);
% frr=getframe(gcf);
% imwrite(frr.cdata, [ outpath, '/Peaks.tif'],'tif',...
%     'Compression', 'none',  'Resolution', 1/scal_fact);
print(gcf, '-dtiffnocompression', [outpath, '/Peaks.tif']);
% clear frr
else
    errordlg('No peaks detected', 'Error')
end
end
