%% 30/5/2016, Anushree R. Chaphalkar
% Finding the angle between two line-segments in degrees
% Inputs:
% p1=[x1,y1]
% p2=[x2,y2]
% pcent =[xcent,ycent] (central point)
function angdegree=findangle(p1,pcent,p2)
ang = atan2(abs(det([p2-pcent;p1-pcent])),dot(p2-pcent,p1-pcent));
angdegree=ang*180/pi;
end