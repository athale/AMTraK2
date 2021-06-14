%% 1/8/2015 anushree, iiser pune
%% Finding coordinates of lines parallel to a given line 
% linewidth should be 1,3 or 5.
function   newmatInt=thickline(xs,ys,linwidth,img)

offsetPixels= (linwidth-1)/2;
L= sqrt((xs(2)-xs(1))^2 + (ys(2)-ys(1))^2);
switch offsetPixels
    
    case 0
        %newmat=[xs,ys];
        newmatInt=improfile(img,xs,ys);
        
    case 1
       
        xp = xs + offsetPixels * (ys(2)-ys(1)) / L;
       
        yp = ys + offsetPixels * (xs(1)-xs(2)) / L;
        
        
        xn = xs - offsetPixels * (ys(2)-ys(1)) / L;
       
        yn = ys - offsetPixels * (xs(1)-xs(2)) / L;
       
        %newmat=[xn,yn,xs,ys,xp,yp];
       
        Int=improfile(img,xs,ys);
        Intp=improfile(img,xp,yp);
        Intn=improfile(img,xn,yn);
        
                
       
               newmatInt=[Intn,Int, Intp];
newmatInt=max(newmatInt,[],2);
    case 2
        xp = xs + offsetPixels * (ys(2)-ys(1)) / L;
       
        yp = ys + offsetPixels * (xs(1)-xs(2)) / L;
        
        
        xn = xs - offsetPixels * (ys(2)-ys(1)) / L;
       
        yn = ys - offsetPixels * (xs(1)-xs(2)) / L;
        
       
        xpp = xs + offsetPixels * (ys(2)-ys(1)) / L;
       
        ypp = ys + offsetPixels * (xs(1)-xs(2)) / L;
        
        
        xnn = xs- offsetPixels * (ys(2)-ys(1)) / L;
        
        ynn = ys - offsetPixels * (xs(1)-xs(2)) / L;
        
      
        
        %newmat=[xnn,ynn,xn,yn,xs,ys,xp,yp,xpp,ypp];
        Int=improfile(img,xs,ys);
        Intp=improfile(img,xp,yp);
        Intn=improfile(img,xn,yn);
        Intnn=improfile(img,xnn,ynn);
        Intpp=improfile(img,xpp,ypp);
        

       newmatInt=[Intnn,Intn ,Int, Intp,Intpp];
       newmatInt=max(newmatInt,[],2);
        
end

end