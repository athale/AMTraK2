%% Anushree R. Chaphalkar, IISER Pune
%% Created: June, 2013
%% Modified: 23rd of October, 2016
function varargout = AMTraK(varargin)
% AMTRAK M-file for AMTraK.fig
%      AMTRAK, by itself, creates a new AMTRAK or raises the existing
%      singleton*.
%
%      H = AMTRAK returns the handle to a new AMTRAK or the handle to
%      the existing singleton*.
%
%      AMTRAK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AMTRAK.M with the given input arguments.
%
%      AMTRAK('Property','Value',...) creates a new AMTRAK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AMTraK_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AMTraK_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AMTraK

% Last Modified by GUIDE v2.5 13-Nov-2019 11:41:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @AMTraK_OpeningFcn, ...
    'gui_OutputFcn',  @AMTraK_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before AMTraK is made visible.
function AMTraK_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to AMTraK (see VARARGIN)
fprintf('Please wait AMTraK is loading..\n');
% Choose default command line output for AMTraK
handles.output = hObject;
fprintf('Ready\n');

% Update handles structure
guidata(hObject, handles);
%make kymo default values
handles.fullfilename='';
handles.framenos= '';
handles.scal_fact = 0;
handles.interval= 0;
handles.subfolderfrom= 1;
handles.distUnit='µm';
handles.timeUnit='s';
handles.linwidth=1;
%peak detection default values
handles.peakmet='Findpeaks';
handles.folder='';
%track detection default values
handles.trajLenThr  = 0;
handles.minpeak    =   2;
set(handles.texmintracklen, 'String', '2');
set(handles.texsubfolderfrom, 'String', '1');
handles.removeRedundant   =  1;
set(handles.checkremred,'value',1) 
handles.splitting   =  0;
handles.time_thresh     =  0;
handles.x_thresh= 0;
set(handles.texomega1,'Enable', 'off');
set(handles.texomega2,'Enable', 'off');
handles.stepp=1;
handles.interactive=1;
handles.loi='Interactive';
handles.all=1;
handles.chosentrack=1;
handles.trackwise=1;
handles.auto=1;
handles.particles=1;
handles.array10=[handles.staticmeantortu,...
                handles.staticsdtortu,...
                handles.plotT,...
                handles.text73,...
                handles.staticmeantortu,...
                handles.staticsdtortu];
set(handles.popchoose,'String', 'All');
handles.wanttofit=0;
set(hObject, 'HandleVisibility', 'Off');
% saving all handles
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = AMTraK_OutputFcn(hObject, ~, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
%movegui(handles.output,'center');
%set(handles.output,'CloseRequestFcn',@my_closefcn);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% User-defined close request function 
   % to display a question dialog box 
      selection = questdlg('Do you want to quit?',...    
         'Options',...
         'Yes','No', 'Yes'); 
      switch selection, 
          case 'Yes',
              set(hObject, 'HandleVisibility', 'On');
             delete(hObject);
         case 'No'      
              set(hObject, 'HandleVisibility', 'Off') 
             return
      end
 
%% =========================== INPUT PARAMETERS ===========================

% Open File
function pushfilename_Callback(hObject, ~, handles)
[filename,pathname]=uigetfile('*.tif', 'Select an image time-series (.tif)');
switch filename
    case 0
    ed=errordlg('User cancelled action.', 'Error');
    pause(0.4)
    delete(ed);
    otherwise
handles.fullfilename=[pathname,filename];
handles.folder=pathname;
info=imfinfo(handles.fullfilename);
handles.info=info;
guidata(hObject, handles);
Xres=info.XResolution;
if isempty(Xres)==0
    Xres=1/Xres;
end
handles.scal_fact=Xres;
guidata(hObject, handles);
Xres=num2str(Xres);
noframes=num2str(numel(info));
noframes1=['1:1:', noframes];

    set(handles.texfilename, 'string', handles.fullfilename,'TooltipString', handles.fullfilename);
    set(handles.texframenos, 'string', noframes1)
    set(handles.texscalfact, 'string', Xres)
handles.framenos=noframes1;
guidata(hObject, handles);

end

% Choose Frame numbers
function texframenos_Callback(hObject, ~, handles)
handles.framenos= get(hObject, 'String');
guidata(hObject, handles);

newframenos= str2num(handles.framenos);
stepp=newframenos(2)-newframenos(1);
handles.stepp=stepp;
guidata(hObject, handles);
if handles.stepp>1
    handles.interval= handles.interval*handles.stepp;
    guidata(hObject, handles);
    if handles.interval~=0
        set(handles.texinterval, 'String', sprintf('%0.2g',handles.interval));
        msgbox('Interval adjusted according to frame number (step) input.');
    end
end

if isempty(newframenos)==1 || isempty(find(handles.framenos==':',1))
    errordlg('Input must be a range of numbers (Eg. 1:10).', 'Error: Frame nos. input');
    
end


% --- Executes on selection change in poploi.
function poploi_Callback(hObject, eventdata, handles)
loistr    =  get(hObject, 'String');
handles.loi= loistr{get(hObject, 'Value')};
guidata(hObject, handles);
switch handles.loi
    case 'Interactive'
        handles.interactive=1;
        
        guidata(hObject, handles);
        
    otherwise
        handles.interactive=0;
        
        guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.



% Provide Subfolder number to store Output
function texsubfolderfrom_Callback(hObject, ~, handles)
handles.subfolderfrom= str2double(get(hObject, 'String'));
guidata(hObject, handles);


if isempty(handles.subfolderfrom)==1
    errordlg('Input must be a number.', 'Error: Subfolder no. input');
end




% Select Distance Unit
function popdistunit_Callback(hObject, ~, handles)
distUnitstr    =  cellstr(get(hObject, 'String'));
handles.distUnit= distUnitstr{get(hObject, 'Value')};
guidata(hObject, handles);


set(handles.staticunitscalfact, 'String', handles.distUnit);
set(handles.texunitID, 'String', handles.distUnit);
set(handles.texunitAV, 'String', [handles.distUnit, '/', handles.timeUnit]);
set(handles.texunittime, 'String', handles.timeUnit);
guidata(hObject, handles);



% Select Time Unit
function poptimeunit_Callback(hObject, ~, handles)
timeUnitstr    =  get(hObject, 'String');
handles.timeUnit= timeUnitstr{get(hObject, 'Value')};

guidata(hObject, handles);
set(handles.staticunitinterval, 'String', [handles.timeUnit,'/frame'] );
set(handles.texunitAV, 'String', [handles.distUnit, '/', handles.timeUnit]);
set(handles.texunittime, 'String', handles.timeUnit);
guidata(hObject, handles);





% Input Microscopy Scaling Factor
function texscalfact_Callback(hObject, ~, handles)
handles.scal_fact = str2double(get(handles.texscalfact, 'String'));

guidata(hObject, handles);

if isempty(handles.scal_fact)==1
    errordlg('Input must be a number.', 'Error: Scaling factor input');
end





% Input Time Interval of the image-series
function texinterval_Callback(hObject, ~, handles)
handles.interval= str2double(get(hObject, 'String'));
guidata(hObject, handles);
if handles.stepp>1
    handles.interval= handles.interval*handles.stepp;
    guidata(hObject, handles);
    set(handles.texinterval, 'String', sprintf('%0.2g',handles.interval));
    msgbox('Interval adjusted according to frame number (step) input.');
    guidata(hObject, handles);
end


if isempty(handles.interval)==1
    errordlg('Input must be a number.', 'Error: Time interval input');
end






% --- Executes on button press in pushmultifolder.
function pushmultifolder_Callback(hObject, ~, handles)
multi=uipickfiles('FilterSpec', handles.folder,'REFilter', '.\amtrak-$');
handles.multi=multi;
handles.numpick=length(multi);
guidata(hObject, handles);
if iscell(handles.multi)
    [~,fon]=cellfun(@fileparts, handles.multi,'UniformOutput', 0);
    fon=cellfun(@(c) [c(8:end), ', '],fon, 'UniformOutput', 0);
    handles.fon=cat(2,fon{:});
    handles.fon(end-1:end)=[];
    guidata(hObject, handles);
    set(handles.texsubfolder, 'String', handles.fon, 'TooltipString', handles.fon);
else
    errordlg('Please select subfolder to process.', 'Error');
    
end
if handles.numpick>1
    mm=msgbox('You have chosen multiple subfolders for processing. Common parameters will be applied.');
    pause(0.5);
    delete(mm);
    set(handles.radioall, 'Value', 1);
    set(handles.popchoose, 'String', 'All');
    set(handles.radioindividual, 'Value', 0, 'Enable', 'off');
    handles.all =1;
else
    set(handles.radioindividual, 'Value', 0, 'Enable', 'on');
end
guidata(hObject, handles);
figg=100;
switch handles.peakmet;
    case 'Findpeaks' % default findpeaks.
        set(handles.checksplitting,'Enable', 'on');
        for cnt=1:handles.numpick
            figg=figg+1;
            findbright(handles.multi{cnt},...
                handles.auto,...
                handles.manualint,...
                handles.scal_fact,...
                handles.interval,...
                handles.distUnit,...
                handles.timeUnit,...
                figg);
        end
    case 'Watershed' % User selects watershed.
        set(handles.checksplitting,'Enable', 'on');
        for cnt=1:handles.numpick
            figg=figg+1;
            findbright_watershed(handles.multi{cnt},...
                handles.auto,...
                handles.manualint,...
                handles.scal_fact,...
                handles.interval,...
                handles.distUnit,...
                handles.timeUnit,...
                figg);
        end
        
    case 'Edge' % User selects Canny edge detection.
        set(handles.checksplitting,'value', 0);
        handles.splitting=0;
        handles.x_thresh=0;
        handles.time_thresh=0;
        guidata(hObject, handles);
        
        
        set(handles.checksplitting,'Enable', 'off');
        for cnt=1:handles.numpick
            figg=figg+1;
            findbright_edge(handles.multi{cnt},...
                handles.auto,...
                handles.manualint,...
                handles.scal_fact,...
                handles.interval,...
                handles.distUnit,...
                handles.timeUnit,...
                figg);
        end
end

function texsubfolder_Callback(hObject, ~, handles)




% Method to detect peaks
function poppeakmethod_Callback(hObject, ~, handles)
peakstr= cellstr(get(hObject, 'String'));
handles.peakmet=peakstr{get(hObject,'Value')};
guidata(hObject, handles);

figg=100;
switch handles.peakmet;
    case 'Findpeaks' % User selects findpeaks.
        set(handles.checksplitting,'Enable', 'on');
        for cnt=1:handles.numpick
            figg=figg+1;
            findbright(handles.multi{cnt},...
                handles.auto,...
                handles.manualint,...
                handles.scal_fact,...
                handles.interval,...
                handles.distUnit,...
                handles.timeUnit,...
                figg);
        end
        
    case 'Watershed' % User selects watershed.
        set(handles.checksplitting,'Enable', 'on');
        for cnt=1:handles.numpick
            figg=figg+1;
            findbright_watershed(handles.multi{cnt},...
                handles.auto,...
                handles.manualint,...
                handles.scal_fact,...
                handles.interval,...
                handles.distUnit,...
                handles.timeUnit,...
                figg);
        end
        
    case 'Edge' % User selects Canny edge detection.
        set(handles.checksplitting,'value', 0);
        handles.splitting=0;
        handles.x_thresh=0;
        handles.time_thresh=0;
        guidata(hObject, handles);
        
        
        set(handles.checksplitting,'Enable', 'off');
        for cnt=1:handles.numpick
            figg=figg+1;
            findbright_edge(handles.multi{cnt},...
                handles.auto,...
                handles.manualint,...
                handles.scal_fact,...
                handles.interval,...
                handles.distUnit,...
                handles.timeUnit,...
                figg);
        end
end

figure(handles.output); % return the handle to amtrak window


% Peak search radius
function texlambda1_Callback(hObject, ~, handles)
handles.trajLenThr=str2double(get(hObject, 'String'));
guidata(hObject, handles);

if  isempty(handles.trajLenThr)==1
    errordlg('Input must be a number.', 'Error: Peak search radius');
    
end




% Minimum track length
function texmintracklen_Callback(hObject, ~, handles)
handles.minpeak=str2double(get(hObject, 'String'));
guidata(hObject, handles);
if isempty(handles.minpeak)==1
    errordlg('Input must be a number. ', 'Error: Minimum track length');
end
if handles.minpeak<2
    errordlg('Minimum track length should be greater than or equal to 2. ', 'Error: Minimum track length');
end




% Boolean to remove redundant tracks
function checkremred_Callback(hObject, ~, handles)
handles.removeRedundant=get(hObject, 'Value');
guidata(hObject, handles);

% Boolean to link tracks
function checksplitting_Callback(hObject, ~, handles)
handles.splitting=get(hObject, 'Value');
guidata(hObject, handles);
switch handles.splitting
    case 1
        set(handles.texomega1,'Enable', 'on');
        set(handles.texomega2,'Enable', 'on');
        
    case 0
        set(handles.texomega1,'String', '');
        set(handles.texomega2,'String', '');
        set(handles.texomega1,'Enable', 'off');
        set(handles.texomega2,'Enable', 'off')
        handles.x_thresh=0;
        handles.time_thresh=0;
        guidata(hObject, handles);
        
end

% Time threshold to link tracks
function texomega1_Callback(hObject, ~, handles)
handles.time_thresh     =  str2double(get(hObject, 'String'));
guidata(hObject, handles);
if handles.splitting==1 & isempty(handles.time_thresh)==1
    errordlg('Input must be a number.', 'Error: Omega2 input');
end


% Distance threshold to link tracks
function texomega2_Callback(hObject, ~, handles)
handles.x_thresh= str2double(get(hObject, 'String'));
guidata(hObject, handles);
if handles.splitting==1 & isempty(handles.x_thresh)==1
    errordlg('Input must be a number.', 'Error: Omega1 input');
end


function editmanualint_Callback(hObject, eventdata, handles)
handles.manualint= str2double(get(hObject,'String'));
guidata(hObject, handles);
if handles.auto==0
    figg=100;
    switch handles.peakmet;
        case 'Findpeaks' % default option.
            set(handles.checksplitting,'Enable', 'on');
            for cnt=1:handles.numpick
                figg=figg+1;
                findbright(handles.multi{cnt},...
                    handles.auto,...
                    handles.manualint,...
                    handles.scal_fact,...
                    handles.interval,...
                    handles.distUnit,...
                    handles.timeUnit,...
                    figg);
            end
        case 'Watershed' % User selects watershed.
            set(handles.checksplitting,'Enable', 'on');
            for cnt=1:handles.numpick
                figg=figg+1;
                findbright_watershed(handles.multi{cnt},...
                    handles.auto,...
                    handles.manualint,...
                    handles.scal_fact,...
                    handles.interval,...
                    handles.distUnit,...
                    handles.timeUnit,...
                    figg);
            end
            
        case 'Edge' % User selects Canny edge detection.
            set(handles.checksplitting,'value', 0);
            handles.splitting=0;
            handles.x_thresh=0;
            handles.time_thresh=0;
            guidata(hObject, handles);
            
            
            set(handles.checksplitting,'Enable', 'off');
            for cnt=1:handles.numpick
                figg=figg+1;
                findbright_edge(handles.multi{cnt},...
                    handles.auto,...
                    handles.manualint,...
                    handles.scal_fact,...
                    handles.interval,...
                    handles.distUnit,...
                    handles.timeUnit,...
                    figg);
            end
    end
    
end


% --- Executes on button press in radioauto.
function radioauto_Callback(hObject, eventdata, handles)
handles.auto=get(hObject,'Value');
guidata(hObject, handles);
switch handles.auto
    case 1
        set(handles.editmanualint, 'Enable', 'off', 'String', '');
        handles.manualint=0;
        guidata(hObject, handles);
        
    case 0
        set(handles.editmanualint, 'Enable', 'on');
        handles.manualint=0;
        guidata(hObject, handles);
end


% --- Executes on button press in radiomanual.
function radiomanual_Callback(hObject, eventdata, handles)

switch get(hObject,'Value')
    case 0
        set(handles.editmanualint, 'Enable', 'off', 'String', '');
        handles.manualint=0;
        handles.auto=1;
        guidata(hObject, handles);
        
    case 1
        set(handles.editmanualint, 'Enable', 'on');
        handles.auto=0;
        guidata(hObject, handles);
end

%% ====================== MAIN FUNCTIONS ==================================
% --- Executes on button press in pushmakekymo.
function pushmakekymo_Callback(hObject, ~, handles)

switch get(get(handles.panelwidth,'SelectedObject'),'Tag') % Get Tag of selected object.
    case 'radio1'
        handles.linwidth=1;
    case 'radio3'
        handles.linwidth=3;
    case 'radio5'
        handles.linwidth=5;
end

guidata(hObject, handles);

howmanyloi= makekymograph(handles.info,...
    handles.subfolderfrom,...
    handles.fullfilename,...
    str2num(handles.framenos),...
    handles.scal_fact,...
    handles.interval,...
    handles.distUnit,...
    handles.timeUnit,...
    handles.linwidth,...
    handles.interactive);


figure(handles.output); % return the handle to amtrak window
%handles.subfolderfrom=subfoldernew;
set(handles.texsubfolderfrom, 'String', sprintf('%i',handles.subfolderfrom));
guidata(hObject, handles);

% --- Executes on button press in pushmakecontours.
function pushmakecontours_Callback(hObject, ~, handles)
if handles.trajLenThr==0
    errordlg('Please change tracking parameters.', 'Error')
else
    switch handles.peakmet;
        case 'Findpeaks' % User selects findpeaks.
            usedcanny=0;
        case 'Watershed' % User selects watershed.
            usedcanny=0;
        case 'Edge' % User selects Canny edge detection.
            usedcanny=1;
    end
    figg=1000;
    for cnt=1:handles.numpick
        figg=figg+1;
        nsplits=maketracks(handles.multi{cnt},...
            handles.trajLenThr,...
            handles.splitting,...
            handles.x_thresh,...
            handles.time_thresh,...
            handles.removeRedundant,...
            handles.minpeak,...
            handles.scal_fact,...
            handles.interval,...
            handles.distUnit,...
            handles.timeUnit,...
            usedcanny, figg);
%         nsplits=maketracks_alt(handles.multi{cnt},...
%             handles.trajLenThr,...
%             handles.splitting,...
%             handles.x_thresh,...
%             handles.time_thresh,...
%             handles.removeRedundant,...
%             handles.minpeak,...
%             handles.scal_fact,...
%             handles.interval,...
%             handles.distUnit,...
%             handles.timeUnit,...
%             usedcanny, figg);
    end
end
%figure(handles.output); % return the handle to amtrak window

% --- Executes on button press in pushquantify.
function pushquantify_Callback(hObject, ~, handles)

for cnt=1:handles.numpick
    [stats_per_track, inst_stats,nooftracks]=quantify(handles.multi{cnt},...
        handles.scal_fact,...
        handles.interval,...
        handles.distUnit,...
        handles.timeUnit);
end
if handles.numpick>1
    % make pooled files for histograms
    [catInst,catTracs,nooftracksall]= makedistribution(handles.multi,...
        handles.fon,...
        handles.folder,...
        handles.distUnit,...
        handles.timeUnit);
    handles.catInst=catInst;
    set(handles.radioindividual, 'Value', 0);
    set(handles.radioall, 'Value', 1);
    set(handles.popchoose, 'String', 'All');
    handles.catTracs=catTracs;
    handles.nooftracksall=nooftracksall;
    guidata(hObject, handles);
    set(handles.staticnooftracks, 'String', num2str(nooftracksall));
elseif handles.numpick==1
    handles.trackstats=stats_per_track;
    handles.inststats=inst_stats;
    handles.particles=unique(handles.trackstats(:,1));
    set(handles.popchoose, 'String', num2str(handles.particles));
    set(handles.staticnooftracks, 'String', num2str(nooftracks));
    set(handles.radioindividual, 'Enable', 'on');
    guidata(hObject, handles);
end


            
if handles.numpick>1 && handles.all==1
        set(handles.popchoose, 'String', 'All');

    switch handles.trackwise
        case 0
            [meandist,sddist]=findmeansd(handles.catInst(:,3));
            [meansp,sdsp]=findmeansd(handles.catInst(:,5));
            [meantm,sdtm]=findmeansd(handles.catInst(:,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            [meandist,sddist]=findmeansd(handles.catTracs(:,3));
            [meansp,sdsp]=findmeansd(handles.catTracs(:,4));
            [meant,sdt]=findmeansd(handles.catTracs(:,6));
            [meantm,sdtm]=findmeansd(handles.catTracs(:,2));
            set(handles.array10, 'Enable', 'On');
    end
    
    
elseif  handles.numpick==1 && handles.all==1
    set(handles.popchoose, 'String', 'All');
    switch handles.trackwise
        case 0
            [meandist,sddist]=findmeansd(handles.inststats(:,3));
            [meansp,sdsp]=findmeansd(handles.inststats(:,5));
            [meantm,sdtm]=findmeansd(handles.inststats(:,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            [meandist,sddist]=findmeansd(handles.trackstats(:,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(:,4));
            [meant,sdt]=findmeansd(handles.trackstats(:,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(:,2));
            set(handles.array10, 'Enable', 'On');
    end
    
elseif  handles.numpick==1 && handles.all==0
    set(handles.popchoose, 'String', num2str(handles.particles));
    switch handles.trackwise
        case 0
            vm= find(handles.inststats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.inststats(vm,3));
            [meansp,sdsp]=findmeansd(handles.inststats(vm,5));
            [meantm,sdtm]=findmeansd(handles.inststats(vm,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            vm= find(handles.trackstats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.trackstats(vm,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(vm,4));
            [meant,sdt]=findmeansd(handles.trackstats(vm,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(vm,2));
            set(handles.array10, 'Enable', 'On');
    end
    
end
set(handles.staticmeanid, 'String', sprintf('%0.2g',meandist));
set(handles.staticsdid, 'String', sprintf('%0.1g',sddist));
set(handles.staticmeanav, 'String', sprintf('%0.2g',meansp));
set(handles.staticsdav, 'String', sprintf('%0.1g',sdsp));
set(handles.staticmeantime, 'String', sprintf('%0.2g',meantm));
set(handles.staticsdtime, 'String', sprintf('%0.1g',sdtm));
switch get(handles.staticmeantortu, 'Enable')
    case 'on'
set(handles.staticmeantortu, 'String', sprintf('%0.2g',meant));
set(handles.staticsdtortu, 'String', sprintf('%0.1g',sdt));
    case 'off'
    set(handles.staticmeantortu, 'String', '');
set(handles.staticsdtortu, 'String', '');
end



% --- Executes on button press in pushhelp.
function pushhelp_Callback(hObject, ~, handles)
if isunix && ~ismac
    system('evince AmtraK_User_Guide.pdf');
else
    open('AmtraK_User_Guide.pdf');
end

% --- Executes on button press in pushsaveparam.
function pushsaveparam_Callback(hObject, ~, handles)
for cnt=1:handles.numpick
% Parameters={'Image='
%     'Start-frame:End-Frame='
%     'Distance-unit='
%     'Time-unit='
%     'Pixel-size='
%     'Time-interval='
%     'LOI-width='
%     'LOI-selection-mode='
%     'Auto-intensity-threshold='
%     'Manual-intensity-threshold='
%     'Peak-detection-method='
%     'Peak-search-radius='
%     'Minimum-track-length='
%     'Remove-redundant-tracks='
%     'Splitting='
%     'Omega1='
%     'Omega2='};
% Values={('')
%     (handles.framenos)
%     ('')
%     ('')
%     (handles.scal_fact)
%     (handles.interval)
%     (handles.linwidth)
%     ('')
%     ('')
%     (handles.manualint)
%     ('')
%    (handles.trajLenThr)
%     (handles.minpeak)
%     (handles.removeRedundant)
%     (handles.splitting)
%     (handles.x_thresh)
%     (handles.time_thresh)};
%     
% Units={handles.fullfilename
%     ''
%     handles.distUnit
%     handles.timeUnit
%     handles.distUnit
%     handles.timeUnit
%     'pixel(s)'
%     handles.loi
%     handles.auto
%     ''
%     handles.peakmet
%     'pixel(s)'
%     'peaks'
%     ''
%     ''
%     'frames'
%     'pixels'};
% newparam=table(Values,Units,...
%     'RowNames', Parameters);
% 
% writetable(newparam, [handles.multi{cnt},'/All_Parameters.txt'],...
%     'Delimiter', ' ',...
%     'WriteRowNames',true,...
%     'QuoteStrings',false,...
%     'WriteVariableNames',true);

param=cell(1,17);
    param{1}= ['Image = ', handles.fullfilename];
    param{2}= ['Start frame : End frame = ', handles.framenos];
    param{3}=['Distance unit = ', handles.distUnit];
    param{4}=['Time unit = ', handles.timeUnit];
    param{5}= ['Pixel size = ',sprintf('%0.3g',handles.scal_fact), ' ', handles.distUnit];
    param{6}= ['Time interval between two frames = ', sprintf('%0.3g',handles.interval), ' ', handles.timeUnit];
    param{7}= ['LOI selection mode = ',sprintf('%s',handles.loi) ];
    param{8}=['LOI width = ', sprintf('%i',handles.linwidth), ' pixel(s)'];
    switch handles.auto
        case 1
            param{9}='Intensity setting = Auto';
            param{10}= 'Intensity threshold = Auto';
        case 0
            param{9}='Intensity setting = Manual';
            param{10}= ['Intensity threshold = ',sprintf('%i',handles.manualint)];
    end
    param{11}= ['Peak detection method = ', handles.peakmet];
    param{12}= ['Peak search radius = ', sprintf('%0.3g',handles.trajLenThr)];
    param{13}= ['Minimum track length  = ',sprintf('%i',handles.minpeak), ' peaks'];
    param{14}= ['Boolean to remove redundant tracks = ', sprintf('%i',handles.removeRedundant)];
    param{15}= ['Splitting boolean = ', sprintf('%i',handles.splitting)];
    param{16}= ['Omega1 = ',sprintf('%i',handles.x_thresh), ' Frames'];
    param{17}= ['Omega2 = ',sprintf('%i',handles.time_thresh), ' Pixels'];
    
    %% Save parameters for record
    all_parameters= char(param);
    ARRparam= cellstr(all_parameters);
    %--- to save stuff in a txt file
    fid =fopen([handles.multi{cnt},'/All_Parameters.txt'], 'w');
    fmtString = [repmat('%s\t',1,size(ARRparam,2)-1),'%s\r\n'];
    fprintf(fid,fmtString,ARRparam{:});
    fclose(fid);
end
ms=msgbox('Saved parameters.', '' );
pause(1);
delete(ms);
% --- Executes on button press in pushreset.
function pushreset_Callback(hObject, ~, handles)
selection = questdlg('Do you want to reset to default?',...
    'Reset Alert',...
    'Yes', 'No','Yes');
switch selection
    case 'Yes'
        handle_array1=[handles.texfilename, handles.texframenos,...
            handles.texsubfolderfrom,handles.texscalfact,handles.texinterval,...
            handles.texsubfolder,handles.texlambda1,...
            handles.staticnooftracks,...
            handles.staticmeanid,handles.staticsdid,...
            handles.staticmeantime,handles.staticsdtime,...
            handles.staticmeanav,handles.staticsdav,...
            handles.staticmeantortu,handles.staticsdtortu,...
            handles.texomega1,handles.texomega2,...
            handles.texleft,handles.texright,handles.texneutral];
        
        
        
        set(handle_array1, 'String','');
        set(handles.texmintracklen,'String','2');
        set([handles.texomega1,handles.texomega2], 'Enable', 'off');
        handle_array2=[handles.checksplitting];
        set(handle_array2, 'value',0)
        handles.trajLenThr=0;
        handles.time_thresh     =  0;
        handles.x_thresh= 0;
        
        guidata(hObject, handles);
        set(handles.texsubfolderfrom, 'String', '1');
        
    case 'No'
        return
end

% --- Executes on button press in pushclose.
function pushclose_Callback(hObject, eventdata, handles)
close all

%% ================ STATISTICS ============================================
% --- Executes on button press in pushmsd.
function pushmsd_Callback(hObject, eventdata, handles)
for cnt=1:handles.numpick
%if isempty(handles.ALLtracks)
    imp=importdata([handles.multi{cnt},...
        '/Tracklist.txt'], '\t', 1);
    handles.ALLtracks=imp.data;
    un=unique(imp.data(:,1));
    handles.numobj=numel(un);
%end
guidata(hObject, handles);

figure(100000),hold on,
set(gcf,'NumberTitle','off', 'Name', 'MSD Profiles');
set(gca,'fontname', 'Times New Roman', 'fontsize', 18);
xlabel(['Time (', handles.timeUnit, ')']);
ylabel(['MSD (', handles.distUnit, '^2)']);
hues=hsv(handles.numobj);

            for msd=1:handles.numobj
            loc=find(handles.ALLtracks(:,1)==un(msd));
            [dt{msd}, rr{msd}]=msdisplacement_ARCmod(handles.ALLtracks(loc,5)*handles.interval,...
                handles.ALLtracks(loc,2)*handles.scal_fact,...
                hues(msd,:));
            id{msd}=ones(size(dt{msd},1),1)*msd;
        end
        print(gcf, '-dtiffnocompression',...
            [handles.multi{cnt}, '/MSD_vs_Time.tif']);
        % text file stored
        catiddtrr=[cat(1, id{:}),cat(1, dt{:}),cat(1, rr{:}) ];
        fid =fopen([handles.multi{cnt}, '/ID_Time_MSD.txt'], 'w');
        fprintf(fid, ['ObjectID    Timestep (', handles.timeUnit, ')    MSD (', handles.distUnit, '^2/', handles.timeUnit, ')\r\n']);
        fclose(fid);
        dlmwrite([handles.multi{cnt}, '/ID_Time_MSD.txt'],...
            catiddtrr,'-append', 'delimiter',...
            '\t','newline', 'pc',...
            'precision', '%.3f');
        % average msd curve with fit
        t_avg_sd=[];
        for yen=handles.interval:handles.interval:max(catiddtrr(:,2))
            locating=find(catiddtrr(:,2)==yen);
            t_avg_sd= [t_avg_sd;...
                yen,mean(catiddtrr(locating,3)),std(catiddtrr(locating,3))];
        end
f100001=figure(100001);
set(f100001,'NumberTitle','off', 'Name', 'Average MSD Profile');
set(gca,'fontname', 'Times New Roman', 'fontsize', 18);
xlabel(['Time (', handles.timeUnit, ')']);
ylabel(['MSD (', handles.distUnit, '^2)']);
shadedErrorBar([0;t_avg_sd(:,1)],...
    [0;t_avg_sd(:,2)],[0;t_avg_sd(:,3)],...
   'lineprops',{'-k', 'Linewidth',2},'transparent',1,...
   'patchSaturation',0.033);
xl = xlim(gca);
xlim(gca, [0 xl(2)]);
yl = ylim(gca);
ylim(gca, [0 yl(2)]);
 
%----- if you want to fit msd curve----------------------------------
switch handles.wanttofit
    case 1
        intex=newid('Enter the fraction of length of the curve to be used for fitting:',...
            'Input for fit',...
            [1,40], {'0.25'});
        intex=str2double(intex{1});
 numtimesteps=round((numel(t_avg_sd(:,1)))*intex);
[deff,alpha,predy]= msd_fit_ARCmod([0;t_avg_sd(1:numtimesteps,1)],...
    [0;t_avg_sd(1:numtimesteps,2)]);

hold on, plot([0;t_avg_sd(1:numtimesteps,1)], predy(1:numtimesteps+1),...
    '--r', 'Linewidth',2),legend('off')
xlabel(['Time (', handles.timeUnit, ')']);
ylabel(['MSD (', handles.distUnit, '^2)']);

str1=['  D_{eff} = ',sprintf('%.3g', deff),' ',handles.distUnit, '^2/', handles.timeUnit];
str2= [',  \alpha = ',sprintf('%.3g', alpha)];
yla = ylim(gca);
xla = xlim(gca);
xlim(gca, [0 xla(2)]);
ylim(gca, [0 yla(2)]);
text(xla(1), yla(2), [str1,str2], ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'FontSize', 16, 'FontName', 'Times New Roman');
print(gcf, '-dtiffnocompression',...
            [handles.multi{cnt}, '/AvgMSD_vs_Time.tif']);
clear xla yla str1 str2
    case 0
       print(gcf, '-dtiffnocompression',...
            [handles.multi{cnt}, '/AvgMSD_vs_Time.tif']);

end
end
%---------------------------------------------------------------------
clear loc catiddtrr dt rr id loc yen time_avgmsd_sdmsd


% --- Executes on button press in plotTO.
function plotTO_Callback(hObject, ~, handles)
infra=zeros(1,handles.numpick);
ultra=infra;
neutra=infra;
figg=300;
for cnt=1:handles.numpick
    figg=figg+1;
    [infra(cnt),ultra(cnt),neutra(cnt)]=tracorient(handles.multi{cnt},...
        handles.scal_fact,...
        handles.interval,...
        handles.timeUnit,...
        handles.distUnit,...
        figg);
end

set(handles.texright, 'String', num2str(sum(infra)));
set(handles.texneutral, 'String', num2str(sum(neutra)));
set(handles.texleft, 'String', num2str(sum(ultra)));
%figure(handles.output); % return the handle to amtrak window


% % --- Executes on button press in plotTIold.
% function plotTIold_Callback(hObject, ~, handles)

% --- Executes on button press in plotTI.
function plotTI_Callback(hObject, eventdata, handles)
figg=200;
if handles.numpick>1 
    handles.all==1;
    set(handles.popchoose, 'String', 'All');
    for cnt=1:handles.numpick
    figg=figg+1;
    intProf(handles.multi{cnt},...
        handles.timeUnit,...
        figg,...
        handles.all,...
        handles.chosentrack);
end
else
    switch handles.all
        case 1
    intProf(handles.multi{1},...
        handles.timeUnit,...
        figg,...
        handles.all,...
        handles.chosentrack);

    case 0
        intProf(handles.multi{1},...
        handles.timeUnit,...
        figg,...
        handles.all,...
        handles.chosentrack);
    end
end
%figure(handles.output); % return the handle to amtrak window

% --- Executes on button press in radiotrackwise.
function radiotrackwise_Callback(hObject, eventdata, handles)

handles.trackwise= get(hObject,'Value');
guidata(hObject, handles);
if handles.numpick>1 && handles.all==1
    set(handles.popchoose, 'String', 'All');
    switch handles.trackwise
        case 0
            [meandist,sddist]=findmeansd(handles.catInst(:,3));
            [meansp,sdsp]=findmeansd(handles.catInst(:,5));
            [meantm,sdtm]=findmeansd(handles.catInst(:,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            [meandist,sddist]=findmeansd(handles.catTracs(:,3));
            [meansp,sdsp]=findmeansd(handles.catTracs(:,4));
            [meant,sdt]=findmeansd(handles.catTracs(:,6));
            [meantm,sdtm]=findmeansd(handles.catTracs(:,2));
            set(handles.array10, 'Enable', 'On');
    end
    
    
elseif  handles.numpick==1 && handles.all==1
        set(handles.popchoose, 'String', 'All');

    switch handles.trackwise
        case 0
            [meandist,sddist]=findmeansd(handles.inststats(:,3));
            [meansp,sdsp]=findmeansd(handles.inststats(:,5));
            [meantm,sdtm]=findmeansd(handles.inststats(:,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            [meandist,sddist]=findmeansd(handles.trackstats(:,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(:,4));
            [meant,sdt]=findmeansd(handles.trackstats(:,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(:,2));
            set(handles.array10, 'Enable', 'On');
    end
    
elseif  handles.numpick==1 && handles.all==0
        set(handles.popchoose, 'String', num2str(handles.particles));

    switch handles.trackwise
        case 0
            vm= find(handles.inststats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.inststats(vm,3));
            [meansp,sdsp]=findmeansd(handles.inststats(vm,5));
            [meantm,sdtm]=findmeansd(handles.inststats(vm,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            vm= find(handles.trackstats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.trackstats(vm,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(vm,4));
            [meant,sdt]=findmeansd(handles.trackstats(vm,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(vm,2));
            set(handles.array10, 'Enable', 'On');
    end
    
end
set(handles.staticmeanid, 'String', sprintf('%0.2g',meandist));
set(handles.staticsdid, 'String', sprintf('%0.1g',sddist));
set(handles.staticmeanav, 'String', sprintf('%0.2g',meansp));
set(handles.staticsdav, 'String', sprintf('%0.1g',sdsp));
set(handles.staticmeantime, 'String', sprintf('%0.2g',meantm));
set(handles.staticsdtime, 'String', sprintf('%0.1g',sdtm));
switch get(handles.staticmeantortu, 'Enable')
    case 'on'
set(handles.staticmeantortu, 'String', sprintf('%0.2g',meant));
set(handles.staticsdtortu, 'String', sprintf('%0.1g',sdt));
    case 'off'
    set(handles.staticmeantortu, 'String', '');
set(handles.staticsdtortu, 'String', '');
end


% --- Executes on button press in radiostepwise.
function radiostepwise_Callback(hObject, eventdata, handles)

switch get(hObject,'Value')
    case 1
        handles.trackwise=0;
        guidata(hObject, handles);
        
    case 0
        handles.trackwise=1;
        guidata(hObject, handles);
end
if handles.numpick>1 && handles.all==1
    switch handles.trackwise
        case 0
            [meandist,sddist]=findmeansd(handles.catInst(:,3));
            [meansp,sdsp]=findmeansd(handles.catInst(:,5));
            [meantm,sdtm]=findmeansd(handles.catInst(:,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            [meandist,sddist]=findmeansd(handles.catTracs(:,3));
            [meansp,sdsp]=findmeansd(handles.catTracs(:,4));
            [meant,sdt]=findmeansd(handles.catTracs(:,6));
            [meantm,sdtm]=findmeansd(handles.catTracs(:,2));
            set(handles.array10, 'Enable', 'On');
    end
    
    
elseif  handles.numpick==1 && handles.all==1
    switch handles.trackwise
        case 0
            [meandist,sddist]=findmeansd(handles.inststats(:,3));
            [meansp,sdsp]=findmeansd(handles.inststats(:,5));
            [meantm,sdtm]=findmeansd(handles.inststats(:,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            [meandist,sddist]=findmeansd(handles.trackstats(:,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(:,4));
            [meant,sdt]=findmeansd(handles.trackstats(:,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(:,2));
            set(handles.array10, 'Enable', 'On');
    end
    
elseif  handles.numpick==1 && handles.all==0
    
    switch handles.trackwise
        case 0
            vm= find(handles.inststats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.inststats(vm,3));
            [meansp,sdsp]=findmeansd(handles.inststats(vm,5));
            [meantm,sdtm]=findmeansd(handles.inststats(vm,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            vm= find(handles.trackstats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.trackstats(vm,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(vm,4));
            [meant,sdt]=findmeansd(handles.trackstats(vm,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(vm,2));
            set(handles.array10, 'Enable', 'On');
    end
    
end
set(handles.staticmeanid, 'String', sprintf('%0.2g',meandist));
set(handles.staticsdid, 'String', sprintf('%0.1g',sddist));
set(handles.staticmeanav, 'String', sprintf('%0.2g',meansp));
set(handles.staticsdav, 'String', sprintf('%0.1g',sdsp));
set(handles.staticmeantime, 'String', sprintf('%0.2g',meantm));
set(handles.staticsdtime, 'String', sprintf('%0.1g',sdtm));

switch get(handles.staticmeantortu, 'Enable')
    case 'on'
set(handles.staticmeantortu, 'String', sprintf('%0.2g',meant));
set(handles.staticsdtortu, 'String', sprintf('%0.1g',sdt));
    case 'off'
    set(handles.staticmeantortu, 'String', '');
set(handles.staticsdtortu, 'String', '');
end

% --- Executes on button press in plotID.
function plotID_Callback(hObject, eventdata, handles)
if handles.numpick>1
    switch handles.trackwise
        case 0
            matr=handles.catInst(:,3);
        case 1
            matr=handles.catTracs(:,3);
    end
else
    switch handles.trackwise
        case 0
            matr=handles.inststats(:,3);
        case 1
            matr=handles.trackstats(:,3);
    end
end
makeplots(matr, 'Distance', get(handles.texunitID, 'String'))
figure(handles.output); % return the handle to amtrak window

% --- Executes on button press in plotTime.
function plotTime_Callback(hObject, eventdata, handles)
if handles.numpick>1
    switch handles.trackwise
        case 0
            matr=handles.catInst(:,2);
        case 1
            matr=handles.catTracs(:,2);
    end
else
    switch handles.trackwise
        case 0
            matr=handles.inststats(:,2);
        case 1
            matr=handles.trackstats(:,2);
    end
end

makeplots(matr, 'Time', get(handles.texunittime, 'String'));
figure(handles.output); % return the handle to amtrak window

% --- Executes on button press in plotAV.
function plotAV_Callback(hObject, eventdata, handles)
if handles.numpick>1
    switch handles.trackwise
        case 0
            matr=handles.catInst(:,5);
        case 1
            matr=handles.catTracs(:,4);
    end
else
    switch handles.trackwise
        case 0
            matr=handles.inststats(:,5);
        case 1
            matr=handles.trackstats(:,4);
    end
end

makeplots(matr, 'Speed', get(handles.texunitAV, 'String'));
figure(handles.output); % return the handle to amtrak window

% --- Executes on button press in plotT.
function plotT_Callback(hObject, eventdata, handles)
if handles.numpick>1
    matr=handles.catTracs(:,6);
else
    matr=handles.trackstats(:,6);
end

makeplots(matr, 'Tortuosity', '')
figure(handles.output); % return the handle to amtrak window


% --- Executes on selection change in popchoose.
function popchoose_Callback(hObject, eventdata, handles)

choosestr= cellstr(get(hObject, 'String'));
handles.chosentrack=str2double(choosestr{get(hObject,'Value')});
guidata(hObject, handles);

if  handles.numpick==1 && handles.all==1
    switch handles.trackwise
        case 0
            [meandist,sddist]=findmeansd(handles.inststats(:,3));
            [meansp,sdsp]=findmeansd(handles.inststats(:,5));
            [meantm,sdtm]=findmeansd(handles.inststats(:,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            [meandist,sddist]=findmeansd(handles.trackstats(:,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(:,4));
            [meant,sdt]=findmeansd(handles.trackstats(:,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(:,2));
            set(handles.array10, 'Enable', 'On');
    end
    
elseif  handles.numpick==1 && handles.all==0
    
    switch handles.trackwise
        case 0
            vm= find(handles.inststats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.inststats(vm,3));
            [meansp,sdsp]=findmeansd(handles.inststats(vm,5));
            [meantm,sdtm]=findmeansd(handles.inststats(vm,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            vm= find(handles.trackstats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.trackstats(vm,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(vm,4));
            [meant,sdt]=findmeansd(handles.trackstats(vm,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(vm,2));
            set(handles.array10, 'Enable', 'On');
    end
    
end
set(handles.staticmeanid, 'String', sprintf('%0.2g',meandist));
set(handles.staticsdid, 'String', sprintf('%0.1g',sddist));
set(handles.staticmeanav, 'String', sprintf('%0.2g',meansp));
set(handles.staticsdav, 'String', sprintf('%0.1g',sdsp));
set(handles.staticmeantime, 'String', sprintf('%0.2g',meantm));
set(handles.staticsdtime, 'String', sprintf('%0.1g',sdtm));
switch get(handles.staticmeantortu, 'Enable')
    case 'on'
set(handles.staticmeantortu, 'String', sprintf('%0.2g',meant));
set(handles.staticsdtortu, 'String', sprintf('%0.1g',sdt));
    case 'off'
    set(handles.staticmeantortu, 'String', '');
set(handles.staticsdtortu, 'String', '');
end





% --- Executes on button press in radioall.
function radioall_Callback(hObject, eventdata, handles)
handles.all= get(hObject,'Value');
guidata(hObject, handles);
if handles.numpick>1 && handles.all==1
    set(handles.popchoose, 'String', 'All');
    switch handles.trackwise
        case 0
            [meandist,sddist]=findmeansd(handles.catInst(:,3));
            [meansp,sdsp]=findmeansd(handles.catInst(:,5));
            [meantm,sdtm]=findmeansd(handles.catInst(:,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            [meandist,sddist]=findmeansd(handles.catTracs(:,3));
            [meansp,sdsp]=findmeansd(handles.catTracs(:,4));
            [meant,sdt]=findmeansd(handles.catTracs(:,6));
            [meantm,sdtm]=findmeansd(handles.catTracs(:,2));
            set(handles.array10, 'Enable', 'On');
    end
    
    
elseif  handles.numpick==1 && handles.all==1
    set(handles.popchoose, 'String', 'All');
    switch handles.trackwise
        case 0
            [meandist,sddist]=findmeansd(handles.inststats(:,3));
            [meansp,sdsp]=findmeansd(handles.inststats(:,5));
            [meantm,sdtm]=findmeansd(handles.inststats(:,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            [meandist,sddist]=findmeansd(handles.trackstats(:,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(:,4));
            [meant,sdt]=findmeansd(handles.trackstats(:,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(:,2));
            set(handles.array10, 'Enable', 'On');
    end
    
elseif  handles.numpick==1 && handles.all==0
    set(handles.popchoose, 'String', num2str(handles.particles));
    switch handles.trackwise
        case 0
            vm= find(handles.inststats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.inststats(vm,3));
            [meansp,sdsp]=findmeansd(handles.inststats(vm,5));
            [meantm,sdtm]=findmeansd(handles.inststats(vm,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            vm= find(handles.trackstats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.trackstats(vm,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(vm,4));
            [meant,sdt]=findmeansd(handles.trackstats(vm,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(vm,2));
            set(handles.array10, 'Enable', 'On');
    end
    
end
set(handles.staticmeanid, 'String', sprintf('%0.2g',meandist));
set(handles.staticsdid, 'String', sprintf('%0.1g',sddist));
set(handles.staticmeanav, 'String', sprintf('%0.2g',meansp));
set(handles.staticsdav, 'String', sprintf('%0.1g',sdsp));
set(handles.staticmeantime, 'String', sprintf('%0.2g',meantm));
set(handles.staticsdtime, 'String', sprintf('%0.1g',sdtm));
switch get(handles.staticmeantortu, 'Enable')
    case 'on'
set(handles.staticmeantortu, 'String', sprintf('%0.2g',meant));
set(handles.staticsdtortu, 'String', sprintf('%0.1g',sdt));
    case 'off'
    set(handles.staticmeantortu, 'String', '');
set(handles.staticsdtortu, 'String', '');
end


% --- Executes on button press in radioindividual.
function radioindividual_Callback(hObject, eventdata, handles)
handles.particles=unique(handles.trackstats(:,1));
guidata(hObject, handles);
switch get(hObject,'Value')
    case 0
        handles.all=1;
        set(handles.popchoose, 'String', 'All');
        guidata(hObject, handles);
    case 1
        handles.all=0;
        guidata(hObject, handles);
        set(handles.popchoose, 'String', num2str(handles.particles));
end
if handles.numpick>1 && handles.all==1
    
    switch handles.trackwise
        case 0
            [meandist,sddist]=findmeansd(handles.catInst(:,3));
            [meansp,sdsp]=findmeansd(handles.catInst(:,5));
            [meantm,sdtm]=findmeansd(handles.catInst(:,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            [meandist,sddist]=findmeansd(handles.catTracs(:,3));
            [meansp,sdsp]=findmeansd(handles.catTracs(:,4));
            [meant,sdt]=findmeansd(handles.catTracs(:,6));
            [meantm,sdtm]=findmeansd(handles.catTracs(:,2));
            set(handles.array10, 'Enable', 'On');
    end
    
    
elseif  handles.numpick==1 && handles.all==1
    switch handles.trackwise
        case 0
            [meandist,sddist]=findmeansd(handles.inststats(:,3));
            [meansp,sdsp]=findmeansd(handles.inststats(:,5));
            [meantm,sdtm]=findmeansd(handles.inststats(:,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            [meandist,sddist]=findmeansd(handles.trackstats(:,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(:,4));
            [meant,sdt]=findmeansd(handles.trackstats(:,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(:,2));
            set(handles.array10, 'Enable', 'On');
    end
    
elseif  handles.numpick==1 && handles.all==0
    
    switch handles.trackwise
        case 0
            vm= find(handles.inststats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.inststats(vm,3));
            [meansp,sdsp]=findmeansd(handles.inststats(vm,5));
            [meantm,sdtm]=findmeansd(handles.inststats(vm,2));
            set(handles.array10, 'Enable', 'Off');
        case 1
            vm= find(handles.trackstats(:,1)==handles.chosentrack);
            [meandist,sddist]=findmeansd(handles.trackstats(vm,3));
            [meansp,sdsp]=findmeansd(handles.trackstats(vm,4));
            [meant,sdt]=findmeansd(handles.trackstats(vm,6));
            [meantm,sdtm]=findmeansd(handles.trackstats(vm,2));
            set(handles.array10, 'Enable', 'On');
    end
    
end
set(handles.staticmeanid, 'String', sprintf('%0.2g',meandist));
set(handles.staticsdid, 'String', sprintf('%0.1g',sddist));
set(handles.staticmeanav, 'String', sprintf('%0.2g',meansp));
set(handles.staticsdav, 'String', sprintf('%0.1g',sdsp));
set(handles.staticmeantime, 'String', sprintf('%0.2g',meantm));
set(handles.staticsdtime, 'String', sprintf('%0.1g',sdtm));
switch get(handles.staticmeantortu, 'Enable')
    case 'on'
set(handles.staticmeantortu, 'String', sprintf('%0.2g',meant));
set(handles.staticsdtortu, 'String', sprintf('%0.1g',sdt));
    case 'off'
    set(handles.staticmeantortu, 'String', '');
set(handles.staticsdtortu, 'String', '');
end







%% ====== CREATE FUNCTIONS ================================================

% --- Executes during object creation, after setting all properties.
function editmanualint_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popchoose_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pushmakekymo_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.8,0.8,0.8],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');




% --- Executes during object creation, after setting all properties.
function pushmakecontours_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.8,0.8,0.8],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');


% --- Executes during object creation, after setting all properties.
function pushquantify_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.8,0.8,0.8],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');


% --- Executes during object creation, after setting all properties.
function plotTIold_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.8,0.8,0.8],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');


% --- Executes during object creation, after setting all properties.
function plotTOold_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.8,0.8,0.8],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal')
    


% --- Executes during object creation, after setting all properties.
function plotIV_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.8,0.8,0.8],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');





% --- Executes during object creation, after setting all properties.
function plotT_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.8,0.8,0.8],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function Processing_CreateFcn(hObject, eventdata, handles)
set(hObject,'ForegroundColor',[0.08,0.17,0.55],...%blue
    'BackgroundColor', [0.94,0.94,0.94],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal',...
    'BorderType', 'none');

% --- Executes during object creation, after setting all properties.
function uipanel5_CreateFcn(hObject, eventdata, handles)
set(hObject,'ForegroundColor',[0.08,0.17,0.55],...%blue
    'BackgroundColor', [0.94,0.94,0.94],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal',...
    'BorderType', 'none');


% Subfolder to process
% --- Executes during object creation, after setting all properties.
function pushmultifolder_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.8,0.8,0.8],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function uipanel3_CreateFcn(hObject, eventdata, handles)

set(hObject,'ForegroundColor',[0.08,0.17,0.55],...%blue
    'BackgroundColor', [0.94,0.94,0.94],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal',...
    'BorderType', 'none');

% --- Executes during object creation, after setting all properties.
function pushsaveparam_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.08,0.17,0.55],...%blue
    'ForegroundColor', 'white',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function pushhelp_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.08,0.17,0.55],...%blue
    'ForegroundColor', 'white',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');


% --- Executes during object creation, after setting all properties.
function pushreset_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.6,0.2,0],...%maroon
    'ForegroundColor', 'white',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal')
    


% --- Executes during object creation, after setting all properties.
function pushclose_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.6,0.2,0],...%maroon
    'ForegroundColor', 'white',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
set(hObject,'Color',[0.5,0.5,0.5],...% dark grey
    'Resize', 'on');


% --- Executes during object creation, after setting all properties.
function texfilename_CreateFcn(hObject, eventdata, handles)

set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

function texsubfolderfrom_CreateFcn(hObject, ~, handles)

set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');



function texinterval_CreateFcn(hObject, ~, handles)

set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

function pushfilename_CreateFcn(hObject, eventdata, handles)

set(hObject,'BackgroundColor',[0.8,0.8,0.8],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal')  

function texframenos_CreateFcn(hObject, ~, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

function poploi_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');


% --- Executes during object creation, after setting all properties.
function radio5_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');


% --- Executes during object creation, after setting all properties.
function radio3_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function radio1_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function panelwidth_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

function popdistunit_CreateFcn(hObject, ~, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

function poptimeunit_CreateFcn(hObject, ~, handles)

set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

function texscalfact_CreateFcn(hObject, ~, handles)

set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
function texsubfolder_CreateFcn(hObject, ~, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
function poppeakmethod_CreateFcn(hObject, ~, handles)

set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
function texlambda1_CreateFcn(hObject, ~, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
function texmintracklen_CreateFcn(hObject, ~, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
% --- Executes during object creation, after setting all properties.
function checkremred_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function checksplitting_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
function texomega1_CreateFcn(hObject, ~, handles)

set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
function texomega2_CreateFcn(hObject, ~, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
% --- Executes during object creation, after setting all properties.
function kk_CreateFcn(hObject, eventdata, handles)
set(hObject,'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function texleft_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function staticmeanid_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function staticmeandisp_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
% --- Executes during object creation, after setting all properties.
function staticmeaniv_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
% --- Executes during object creation, after setting all properties.
function staticmeanav_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function staticmeantortu_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function texneutral_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function staticsdid_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function staticsddisp_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function staticsdiv_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function staticsdav_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function staticsdtortu_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white',...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function texright_CreateFcn(hObject, eventdata, handles)






% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text10_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text63_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text64_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text9_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text6_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function staticunitscalfact_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function staticunitinterval_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text11_CreateFcn(hObject, eventdata, handles)
set(hObject,'ForegroundColor','black',...
    'BackgroundColor', [0.94,0.94,0.94],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text24_CreateFcn(hObject, eventdata, handles)
set(hObject,'ForegroundColor',[0.08,0.17,0.55],...
    'BackgroundColor', [0.94,0.94,0.94],...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
% --- Executes during object creation, after setting all properties.
function text23_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text22_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text16_CreateFcn(hObject, eventdata, handles)

set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text21_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text13_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'Symbol',...
    'FontWeight', 'normal');
% --- Executes during object creation, after setting all properties.
function text14_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'Symbol',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text20_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text19_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text18_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text17_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text55_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text25_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text32_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
% --- Executes during object creation, after setting all properties.
function text33_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text34_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text35_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text36_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text26_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text38_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text39_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');
% --- Executes during object creation, after setting all properties.
function text40_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text41_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text42_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function text65_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function texunitID_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function texunitTD_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');

% --- Executes during object creation, after setting all properties.
function texunitIV_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0.94,0.94,0.94],...
    'ForegroundColor', 'black',...
    'FontName', 'MS Sans Serif',...
    'FontWeight', 'normal');


% --- Executes on button press in checkfit.
function checkfit_Callback(hObject, eventdata, handles)
handles.wanttofit=get(hObject,'Value');
guidata(hObject, handles);



