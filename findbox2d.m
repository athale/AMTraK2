function ids=findbox2d(focusx,xvec,xcutoff,focusy,yvec,ycutoff,loc)
focusx=floor(focusx);
focusy=floor(focusy);

xcutoff=ceil(xcutoff);
ycutoff=ceil(ycutoff);

switch loc
    case 'last'
ids=find(xvec<=(focusx+xcutoff) & xvec>=(focusx-xcutoff) & yvec<=(focusy+ycutoff)& yvec>focusy);
    case 'first'
  ids=find(xvec<=(focusx+xcutoff) & xvec>=(focusx-xcutoff) & yvec>=(focusy-ycutoff)& yvec<focusy);
end     
end

