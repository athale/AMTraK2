% Neha Khetan,  22 Jan 2015: for the MSD fit.
%% ARC Modified 24/2/2018
% Example to show basic fit funtion

function [d_eff,alpha,predy]= msd_fit_ARCmod(tim,msd)

  % tim: for delta time values
  % msd: for the msd values obtained from the fit

% fit function options   -- You can specify al the fit options else the default is read: Method, Algorithm , lower n upper bounds , startpoints ,
s= fitoptions('Method','NonlinearLeastSquares',...
     'Startpoint',[ 0 0 ],...
    'Algorithm' , 'Levenberg-Marquardt' ); %ARC changed

% for 2D MSD function: <r^2> =  4Dt^alpha, here tim = x;
ft3     = fittype( '2.*d.*power(x,a)',...
    'coefficients',{'a','d'},'options',s ); %ARC changed
[ cf,~,~ ] = fit( tim , msd, ft3 ); %ARC changed s1,t to ~, ~

% returns alpha and effective D values
alpha = cf.a;
d_eff = cf.d;
predy=cf(tim);%ARC
%    figure(gcf),hold on, plot(cf,'-r', 'Linewidth',2),
%    legend('off')

% if u dont want to plot any here and plot in the main code
% then also return "cf" for which modify
% function [d_eff,alpha]= msd_fit(tim,msd) as 
%--------- function [ d_eff , alpha , cf ]= msd_fit(tim,msd)
%--------- and in comment out Line # 22 - 25 and in the main function
%--------- plot(cf, 'k-')



% u can return r2 values - for R2
% to plot , return cf -> plot( cf )
end
