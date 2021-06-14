%% Anushree R. Chaphalkar, IISER Pune
%% Created: June, 2013
%% Modified: June, 2016
function [infra,ultra,neutra]=tracorient(inoutpath, scal_fact, interval, timeUnit,distUnit,figg)
%% Storing intensity profiles of kymography tracks
%====================INPUT=================================================
% 1. Tracklist.txt
% 2. Variables:
%  inoutpath= 'd:/test'     % input-output path
%  timeUnit = 'min'         % units of time
%====================OUTPUT================================================
% 1. Track_Orientation.txt
% 2. Track_Orientation.pdf
%==========================================================================
%--read coords of contours
INT=importdata([inoutpath, '/Tracklist.txt'],'\t', 1);
cont=INT.data;
%(Track number, xcoord, ycoord)
mn=min(cont(:,1));
mx=max(cont(:,1));
%--read kymograph matrix
kym=dlmread([inoutpath, '/OutputKymo.txt']);
siz=size(kym);
spacingXAxis= round(siz(2)/4);
spacingYAxis= round(siz(1)/4);
Track=zeros(mx-mn,1);
Orientn=cell(mx-mn,1);
infra=0;
ultra=0;
neutra=0;
figure(figg),
movegui(gcf, 'east');
set(gcf,'NumberTitle','off', 'Name', 'Track Direction');
imshow(imadjust(kym), 'InitialMagnification', 'fit')
axis ij, axis on;
axis normal;
set(gca,'fontname', 'Times New Roman',...
    'fontsize', 18,...
    'XTick', 0:spacingXAxis:siz(2),...
    'YTick', 0:spacingYAxis:siz(1)-1,...
    'XTicklabel', (0:spacingXAxis:siz(2)).*scal_fact,...
    'YTicklabel', (0:spacingYAxis:siz(1)-1).*interval);
xlabel(['Distance (',distUnit,')'  ]);
ylabel(['Time (',  timeUnit, ')']);
for g= mn: mx %grouping coords trackwise
    [row]= find(cont(:,1)== g);
    dirdisp=cont(row(end),2)-cont(row(1),2);
    dirctn=dirdisp/abs(dirdisp);
    Track(g)=g;%sign will indicate direction
    if dirctn>0 % (+) =right
        figure(figg),hold on, plot(cont(row,2),cont(row,3), '--r', 'Linewidth',2)
        infra=infra+1;
        Orientn{g}='Right  ';
    elseif dirctn<0 % (-) =left
        figure(figg),hold on, plot(cont(row,2),cont(row,3), '--b', 'Linewidth',2)
        ultra=ultra+1;
        Orientn{g}='Left   ';
    else % neutral
        figure(figg),hold on, plot(cont(row,2),cont(row,3), '--g', 'Linewidth',2)
        neutra=neutra+1;
        Orientn{g}='Neutral';
    end
    figure(figg),hold on,
    text(cont(row(2),2), cont(row(2),3),...
        sprintf('%i',g),...
        'Color', 'k', ...
        'EdgeColor', 'r',...
        'BackgroundColor', 'y',...
        'VerticalAlignment', 'Top',...
        'HorizontalAlignment', 'Left',...
        'FontSize',8)
end
Orientation=cat(1,Orientn{:});
newtable=table(Track,Orientation);
writetable(newtable,[inoutpath, '/Track_Orientation.txt'],...
    'Delimiter', '\t');
% fid =fopen([inoutpath, '/Track_Orientation.txt'], 'w');
% fprintf(fid, 'Track    Orientation\r\n');
% fclose(fid);
% dlmwrite([inoutpath, '/Track_Orientation.txt'], dirtxt,...
%     '-append', 'delimiter', '\t','newline', 'pc');
print(figure(figg), '-dtiffnocompression', [inoutpath, '/Track_Orientation.tif']);
% Track=dirtxt(:,1);
% Orientation=dirtxt(:,2);
% newtable=table(Track,Orientation);
% writetable(newtable,[inoutpath, '/Track_Orientation.txt'], 'Delimiter', '\t' );
% clear dirtxt newtable Track Orientation
end