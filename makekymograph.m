%% Anushree R. Chaphalkar, IISER Pune
%% Created: June, 2013
%% Modified: October, 2016
% CAA: replaces buttonpress by dialogue box for multi-LOI selection
function howmanyloi=makekymograph(info,subfolderfrom, filename, framenos, scal_fact, interval, distUnit, timeUnit,linwidth,interactive)
% Make kymograph from fluorescence microscopy image-series
% X-axis: Displacement (Pixels)
% Y-axis: Time (frames)
%=========================INPUT============================================
% 1. Fluorescence microscopy image time-series
% 2. Variables:
% info                                          % image stack information
% subfolderfrom = 1                             % index no. of output subfolder
% filename = 'simmovie.tif'                     % name of the timeseries
% framenos = 1:20                               % chosen image frames
% distUnit = 'um'                               % units of length
% timeUnit = 'min'                              % units of time
% scal_fact = 1                                 % microscopy scaling factor (distUnit/pixel)
% interval = 1                                  % time interval between frames (timeUnit)
% linwidth = 5                                  % width of loi (pixels)
% interactive = 1                               % boolean for interactive
% LOI selection
%=======================OUTPUT=============================================
% 1. OutputKymo.tif
% 2. OutputKymo.txt
% 3. LOIselection.tif
% 4. LOIselection.txt
%==========================================================================
%% Reading image-stack
[folder,~,~]=fileparts(filename);
fmt=info.Format;
bitd=info.BitDepth;
numloi=subfolderfrom;
outputpath=cell(1,numloi); % preallocating
%wid=info.Width;
%hei=info.Height;
% if exist([folder,'/amtrak-', sprintf('%i',numloi)], 'dir')
%     button2=questdlg(['The subfolder amtrak-',sprintf('%i',numloi), ' already exists. Do you want to overwrite it?'],'Warning:Subfolder exists','Yes','No','Yes');
%     if strcmp(button2,'No')
%         return
%     end
% end

%reso=info.XResolution;
if ~strcmp(fmt,'tif')
    errordlg('Please select a .tif file.', 'Error');
end
fr=numel(framenos);
r=cell(1,fr);%zeros(hei,wid,fr); %framenos(end));
roi=cell(1,fr); %preallocating

for i= 1:fr
    %r(:,:,i)= imread(filename,framenos(i), 'Info',info);
    r{i}=imread(filename,framenos(i), 'Info',info);
    %When reading images from a multi-image TIFF file,
    %passing the output of imfinfo as the value of the 'Info'
    %argument helps imread locate the images in the file more quickly.
end
%% Maximum intensity projection
clubarray = cat(3, r{:});
Istack=max(clubarray,[],3);
f1=figure(1);
set(f1,'NumberTitle','off',...
    'Name', 'Maximum Intensity Projection');
imshow(imadjust(Istack), 'Border', 'tight');
%% Interactive segmented line selection
k=0;
% numloi=subfolderfrom;
% outputpath=cell(1,numloi); % preallocating
xy=outputpath;

while ~k
    % making a folder for storing output
    if ~exist([folder,'/amtrak-', sprintf('%i',numloi)], 'dir')
        mkdir(folder, ['amtrak-',sprintf('%i',numloi)]);
    else
        button2=questdlg(['The subfolder amtrak-',sprintf('%i',numloi), ' already exists. Do you want to replace it?'],'Warning: Subfolder exists','Yes','No','Yes');
        if strcmp(button2,'No')
            howmanyloi=0;
            close(f1);
            return
        end
    end
    outputpath{numloi}= [folder, '/amtrak-', sprintf('%i',numloi)];
    figure(1),hold on,
    
    switch interactive
        case 1
            title('Please select a Line of Interest');
            [x, y]= mygetline(f1);
            
        otherwise
            title('Applying LOI from file');
            [loif,loipath]=uigetfile('*.txt', 'Select an LOI coordinates file (.txt)', folder);
            loifile=[loipath,loif];
            loimatall=importdata(loifile, '\t',1);
            loimat=loimatall.data;
            x=loimat(:,1);
            y=loimat(:,2);
            figure(1),hold on,plot(x,y,'-r', 'Linewidth',2)
    end
    %     x=[1;1000]; % for simulated kymos
    %     y=[501;501]; % for simulated kymos
    hold on
    text(x(1),y(1),sprintf('%i',numloi),...
        'Color', 'y', ...
        'VerticalAlignment', 'Top',...
        'HorizontalAlignment', 'Left',...
        'FontSize',10);
    xy{numloi}=[x,y];
    
    % saving LOI on maxIntProj image
    fid =fopen([outputpath{numloi},'/LOIselection.txt'], 'w');
    fprintf(fid, 'X    Y\r\n');
    fclose(fid);
    dlmwrite([outputpath{numloi}, '/LOIselection.txt'],...
        xy{numloi},'-append',...
        'delimiter', '\t','newline', 'pc',...
        'precision', '%.3f');
    %print(figure(1), '-dtiffnocompression', [outputpath{numloi}, '/LOI-overview.tif']);
    %--- 16/3/2018
    ee=figure(10000);
    set(ee,'visible', 'off','NumberTitle','off');
    imshow(imadjust(Istack), 'Border', 'tight');
    hold on,
    plot(x,y,'-r', 'Linewidth',2),
    text(x(1),y(1),sprintf('%i',numloi),...
        'Color', 'y', ...
        'VerticalAlignment', 'Top',...
        'HorizontalAlignment', 'Left',...
        'FontSize',10); hold off
    print(ee, '-dtiffnocompression', [outputpath{numloi}, '/LOIselection.tif']);
        
    clear x y;
    %---
    
    %CAA:
    button1=questdlg('Do you want to select additional lines?','Multi-Line Selection','Yes','No','Yes');
    if strcmp(button1,'Yes')
        numloi=numloi+1;
        switch interactive
            case 1
                title('Please select a Line of Interest');
            otherwise
                title('Applying LOI from file');
        end
        
    else
        title('');
        
        break;
    end
    
end
howmanyloi= numloi-subfolderfrom+1;
movegui(ee, 'west');

%% Placing the roi on every image in the series
%% and taking intensity
for countloi=subfolderfrom:numloi
    fprintf('.')
    x=xy{countloi}(:,1);
    y=xy{countloi}(:,2);
    sz=size(x,1);
    for j= 1:fr%framenos
        nmatInt=cell(1,sz-1);%preallocating
        for i=1:sz-1
            xs=[x(i);x(i+1)];
            ys=[y(i);y(i+1)];
            nmatInt{i}=thickline(xs,ys,linwidth,r{j});
            
        end
        roi{j}= cat(1,nmatInt{:});
        
    end
    %% Concatenating all ROIs horizontally
    kymoIm= cat(2, roi{:});
    kymoIm= kymoIm'; % transpose matrix
    if bitd>16
        % improfile converts all >16bit (eg. 32, 64 etc) images into
        % doubles. so no additional normalization required.
        % see doc improfile - The input image can be uint8, uint16, int16,
        % single, double, or logical. All other inputs and outputs must be
        % double.
        kymoIm=kymoIm/1;
    else
        kymoIm=kymoIm./((2^bitd)-1);%normalizing intensity between 0 & 1
    end
    %% Plotting kymograph
    % padding with zeroes on left and right, to enable correct peak detection
    siz=size(kymoIm);
    zeropad=zeros(siz(1), siz(2)+2);
    zeropad(:,2:end-1)=kymoIm;
    kymoIm=zeropad;
    fidmakekymo=fopen([outputpath{countloi}, '/OutputKymo.txt'], 'w');
    dlmwrite([outputpath{countloi}, '/OutputKymo.txt'], kymoIm, 'newline', 'pc');
%     tabkym=table(kymoIm);
%     writetable(tabkym, [outputpath{countloi}, '/OutputKymo.txt'],...
%         'WriteVariableNames',0)
    spacingXAxis= round(siz(2)/4);
    spacingYAxis= round(siz(1)/4);
    
    fnew=figure(1+countloi);
    movegui(fnew, 'west');
    set(fnew,'NumberTitle','off', 'Name', ['Kymograph-', sprintf('%i', countloi)]);
    imshow(imadjust(kymoIm), 'InitialMagnification', 'fit');
    colorbar;
    colormap(gray);
    axis ij on normal;
    %axis([0 siz(2) 0 (siz(1))])
    set(gca,'fontname', 'Times New Roman',...
        'fontsize', 18,...
        'XTick', 0:spacingXAxis:siz(2),...
        'YTick', 0:spacingYAxis:siz(1)-1,...
        'XTicklabel', (0:spacingXAxis:siz(2)).*scal_fact,...
        'YTicklabel', (0:spacingYAxis:siz(1)-1).*interval);
    xlabel(['Distance (',distUnit, ')']);
    ylabel(['Time (', timeUnit, ')']);
%     frr=getframe(gcf);
%     imwrite(frr.cdata, [outputpath{countloi}, '/OutputKymo.tif'],'tif',...
%     'Compression', 'none')%,  'Resolution', 1/scal_fact);
%     clear frr
    print(fnew, '-dtiffnocompression', [outputpath{countloi}, '/OutputKymo.tif']);
    
end
fprintf('\n')
end