%% Anushree R. Chaphalkar, IISER Pune
%% Created: June, 2013
%% Modified: June, 2016
function intProf(inoutpath, timeUnit,figg,all, chosentrack)
%% AIM: Storing intensity profiles of kymography contours
%====================INPUT=================================================
% 1. Tracklist.txt
% 2. Variables:
%  inoutpath= 'd:/amtrak-1' % input-output path 
%  timeUnit = 'min'         % units of time
%====================OUTPUT================================================
% 1. Track_Intensity.pdf
%==========================================================================
%--read coords of contours
INT=importdata([inoutpath, '/Tracklist.txt'],'\t', 1);
cont=INT.data;
%(Track number, xcoord, ycoord, intensity, normtime)
if all==1
mn=min(cont(:,1));
mx=max(cont(:,1));

else
    mn=chosentrack;
    mx=chosentrack;
end
legendinfo=cell(1,mx-mn+1);

figure(figg),
movegui(gcf, 'east');
set(gcf,'NumberTitle','off', 'Name', 'Track Intensity Profiles');
rang=hsv(mx);
for g=mn:mx % grouping coords trackwise
    [row]= find(cont(:,1)== g);
    newmatrix=[cont(row,5),cont(row,4)];
    figure(figg),hold on,
        plot(newmatrix(:,1), newmatrix(:,2), 'Color', rang(g,:), 'Linestyle', '-', 'Linewidth',1);
        legendinfo{g}= ['Track ', sprintf('%04i', g)] ;

end

%axis([0 max(cont(:,5))+2 0 1.2]);
switch all
    case 1
        lh=legend(cat(1,legendinfo{:}),'Location', 'NorthEastOutside');
    case 0
        lh=legend(legendinfo{g},'Location', 'NorthEastOutside'); 
end
set(gca,'fontname', 'Times New Roman', 'fontsize', 18);
lh.FontSize=9;
lh.Box='off';
xlabel(['Time (', sprintf('%s', timeUnit), ')']);
ylabel('Intensity');
print(figure(figg), '-dtiffnocompression', [inoutpath, '/Track_Intensity.tif']);


end