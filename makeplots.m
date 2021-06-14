%% Anushree R. Chaphalkar
%% Created: June 2016
function makeplots(matr, xnam, xunit)
figure,hist(matr)
movegui(gcf, 'east');
set(gcf,'NumberTitle','off', 'Name', xnam);
set(gca,'fontname', 'Times New Roman', 'fontsize', 18);
switch xnam
    case 'Tortuosity'
        xlabel(xnam);
    otherwise
        xlabel([xnam, ' (',  xunit, ')']);
end
ylabel('Frequency');
end
