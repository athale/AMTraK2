   function my_closefcn(src,event)
   % User-defined close request function 
   % to display a question dialog box 
      selection = questdlg('Options',...    
         'Quit',...
         'Quit', 'Close Tabs','Close Tabs'); 
      switch selection, 
          case 'Quit',
             delete(gcf)    ;
         case 'Close Tabs'      
                 return
      end
   end