function varargout = ea_atlasselect(varargin)
% EA_ATLASSELECT MATLAB code for ea_atlasselect.fig
%      EA_ATLASSELECT, by itself, creates a new EA_ATLASSELECT or raises the existing
%      singleton*.
%
%      H = EA_ATLASSELECT returns the handle to a new EA_ATLASSELECT or the handle to
%      the existing singleton*.
%
%      EA_ATLASSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EA_ATLASSELECT.M with the given input arguments.
%
%      EA_ATLASSELECT('Property','Value',...) creates a new EA_ATLASSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ea_atlasselect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ea_atlasselect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ea_atlasselect

% Last Modified by GUIDE v2.5 27-Apr-2017 21:06:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ea_atlasselect_OpeningFcn, ...
                   'gui_OutputFcn',  @ea_atlasselect_OutputFcn, ...
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


% --- Executes just before ea_atlasselect is made visible.
function ea_atlasselect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ea_atlasselect (see VARARGIN)

% Choose default command line output for ea_atlasselect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ea_atlasselect wait for user response (see UIRESUME)
% uiwait(handles.atlasselect);

atlases=varargin{3};
setappdata(handles.atlasselect,'atlases',atlases);
options=varargin{4};
setappdata(handles.atlasselect,'options',options);
movegui(hObject,'northeast');

axis off
setuptree([{handles},varargin])
ea_createpcmenu(handles);


function setuptree(varargin)


handles=varargin{1}{1};
ea_busyaction('on',handles.atlasselect,'atlcontrol');

togglebuttons=varargin{1}{2};
atlassurfs=varargin{1}{3};
atlases=varargin{1}{4};
if ~isfield(atlases,'subgroups')
   atlases.subgroups(1).label='Structures';
   atlases.subgroups(1).entries=1:length(atlases.names);
end
atlchecks=cell(length(atlases.names),1);
import com.mathworks.mwswing.checkboxtree.*
for subgroup=1:length(atlases.subgroups)
   h.sg{subgroup} = DefaultCheckBoxNode(atlases.subgroups(subgroup).label);
   for node=1:length(atlases.subgroups(subgroup).entries)
       [~,thisatlname]=fileparts(atlases.names{atlases.subgroups(subgroup).entries(node)});
       
       try % gzip support
           if strcmp(thisatlname(end-3:end),'.nii')
               [~,thisatlname]=fileparts(thisatlname);
           end
       end
       h.sgsub{subgroup}{node}=DefaultCheckBoxNode(thisatlname,true);
       

       h.sg{subgroup}.add(h.sgsub{subgroup}{node});
       
       if (atlases.types(atlases.subgroups(subgroup).entries(node))==3) || (atlases.types(atlases.subgroups(subgroup).entries(node))==4) % need lh and rh entries
           h.sgsubside{subgroup}{node}{1}=DefaultCheckBoxNode('RH',true);
           h.sgsub{subgroup}{node}.add(h.sgsubside{subgroup}{node}{1});
           h.sgsubside{subgroup}{node}{2}=DefaultCheckBoxNode('LH',true);
           h.sgsub{subgroup}{node}.add(h.sgsubside{subgroup}{node}{2});
       elseif (atlases.types(atlases.subgroups(subgroup).entries(node))==1) % RH only
           h.sgsubside{subgroup}{node}{1}=DefaultCheckBoxNode('RH',true);
           h.sgsub{subgroup}{node}.add(h.sgsubside{subgroup}{node}{1});
       elseif (atlases.types(atlases.subgroups(subgroup).entries(node))==2) % LH only
           h.sgsubside{subgroup}{node}{1}=DefaultCheckBoxNode('LH',true);
           h.sgsub{subgroup}{node}.add(h.sgsubside{subgroup}{node}{1});   
       elseif (atlases.types(atlases.subgroups(subgroup).entries(node))==5) % Midline
           h.sgsubside{subgroup}{node}{1}=DefaultCheckBoxNode('Midline',true);
           h.sgsub{subgroup}{node}.add(h.sgsubside{subgroup}{node}{1});    
       end
           atlchecks{atlases.subgroups(subgroup).entries(node)}=...
       [atlchecks{atlases.subgroups(subgroup).entries(node)},h.sgsub{subgroup}{node}];
       
   end
end

% Create a standard MJTree:
jTree = com.mathworks.mwswing.MJTree(h.sg{1});
 
% Now present the CheckBoxTree:
jCheckBoxTree = CheckBoxTree(jTree.getModel);


% Attempt to set icons to colors:
%       jTreeCR = jCheckBoxTree.getCellRenderer;
%       icon = javax.swing.ImageIcon([ea_getearoot,'icons',filesep,'text.png']);
%
%        %icon = ea_get_icn('atlas',[0.2,0.5,0.6]);
%keyboard
%jTreeCR.setLeafIcon(icon);

jScrollPane = com.mathworks.mwswing.MJScrollPane(jCheckBoxTree);
[jComp,hc] = javacomponent(jScrollPane,[10,10,320,370],handles.atlasselect);


h.togglebuttons=togglebuttons;
h.atlassurfs=atlassurfs;
h.atlases=atlases;
h.atlchecks=atlchecks;
set(jCheckBoxTree, 'MouseReleasedCallback', {@mouseReleasedCallback,h})
setappdata(handles.atlasselect,'h',h);
setappdata(handles.atlasselect,'jtree',jCheckBoxTree);
sels=storeupdatemodel(jCheckBoxTree,h);

ea_busyaction('off',handles.atlasselect,'atlcontrol');


function sels=storeupdatemodel(jtree,h)


for branch=1:length(h.sg)
    sels.branches{branch}=h.sg{branch}.getSelectionState;
        for leaf=1:length(h.sgsub{branch})
            sels.leaves{branch}{leaf}=h.sgsub{branch}{leaf}.getSelectionState;
            for side=1:length(h.sgsubside{branch}{leaf})
                sels.sides{branch}{leaf}{side}=h.sgsubside{branch}{leaf}{side}.getSelectionState;
            end
        end
end

setappdata(jtree,'selectionstate',sels);

function ea_showhideatlases(jtree,h)

sels=storeupdatemodel(jtree,h);
for branch=1:length(sels.branches)
    for leaf=1:length(sels.leaves{branch})
        if ~isempty(sels.sides{branch}{leaf}) % has side children
            for side=1:length(sels.sides{branch}{leaf})
                
                sidec=getsidec(length(sels.sides{branch}{leaf}),side);
                
                [ixs,ixt]=getsubindex(h.sgsub{branch}{leaf},sidec,h.atlassurfs,h.togglebuttons);
                if strcmp(sels.sides{branch}{leaf}{side},'selected') 
                    if ~strcmp(h.atlassurfs(ixs).Visible,'on')
                        h.atlassurfs(ixs).Visible='on';
                        h.togglebuttons(ixt).State='on';
                    end
                elseif strcmp(sels.sides{branch}{leaf}{side},'not selected')
                    if ~strcmp(h.atlassurfs(ixs).Visible,'off')
                        h.atlassurfs(ixs).Visible='off';
                        h.togglebuttons(ixt).State='off';
                    end
                end
            end
        else
            keyboard
        end
    end
end

function sidec=getsidec(sel,side)

if sel==2
    switch side
        case 1
            sidec='_right';
        case 2
            sidec='_left';
    end
elseif sel==1
    sidec='_midline';
end

function [ixs,ixt]=getsubindex(sel,sidec,surfs,togglebuttons)

for p=1:length(surfs)
    if strcmp(surfs(p).Tag,[char(sel),sidec])
        ixs=p;
        break
    end
end

for p=1:length(surfs)
    if strcmp(togglebuttons(p).Tag,[char(sel),sidec])
        ixt=p;
        break
    end
end




  % Set the mouse-press callback
function mouseReleasedCallback(jtree, eventData,h)

clickX = eventData.getX;
clickY = eventData.getY;
treePath = jtree.getPathForLocation(clickX, clickY);

oldselstate=getappdata(jtree,'selectionstate');
newselstate=storeupdatemodel(jtree,h);
if ~isequal(oldselstate,newselstate)
    ea_showhideatlases(jtree,h);
end




    
% --- Outputs from this function are returned to the command line.
function varargout = ea_atlasselect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in presets.
function presets_Callback(hObject, eventdata, handles)
% hObject    handle to presets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns presets contents as cell array
%        contents{get(hObject,'Value')} returns selected item from presets

pcmenu=getappdata(handles.presets,'uimenu');

showcontextmenu(hObject,pcmenu);

function ea_createpcmenu(handles)
atlases=getappdata(handles.atlasselect,'atlases');
pcmenu = uicontextmenu;

def.presets(1).label='Show all structures';
def.presets(1).show=1:length(atlases.names);
def.presets(1).hide=[];
def.presets(1).default='absolute';
def.presets(2).label='Hide all structures';
def.presets(2).show=[];
def.presets(2).hide=1:length(atlases.names);
def.presets(2).default='absolute';
% add defaults:
for ps=1:length(def.presets)
uimenu(pcmenu, 'Label',def.presets(ps).label,'Callback',{@ea_makeselection,handles,def.presets(ps)});
end

% add from atlas index:
if isfield(atlases,'presets')
    for ps=1:length(atlases.presets)
        uimenu(pcmenu, 'Label',atlases.presets(ps).label,'Callback',{@ea_makeselection,handles,atlases.presets(ps)});
    end
end
% add from prefs:
prefs=ea_prefs;
options=getappdata(handles.atlasselect,'options');
if isfield(prefs.machine.atlaspresets,getridofspaces(options.atlasset));
    for ps=1:length(prefs.machine.atlaspresets.(getridofspaces(options.atlasset)))
        try
        uimenu(pcmenu, 'Label',prefs.machine.atlaspresets.(getridofspaces(options.atlasset)).presets(ps).label,'Callback',{@ea_makeselection,handles,prefs.machine.atlaspresets.(getridofspaces(options.atlasset)).presets(ps)});
        catch
            keyboard
        end
    end
end

% add save prefs:
uimenu(pcmenu,'Label','Save current selection as preset...','Callback',{@ea_saveselection,handles,options});

setappdata(handles.presets,'uimenu',pcmenu);

function ea_saveselection(~,~,handles,options)
ea_busyaction('on',handles.atlasselect,'atlcontrol');

jtree=getappdata(handles.atlasselect,'jtree');
h=getappdata(handles.atlasselect,'h');
sels=storeupdatemodel(jtree,h);
atlases=getappdata(handles.atlasselect,'atlases');
pres.default='absolute';
pres.show=[];
pres.hide=[];
[~,atlases.names]=cellfun(@fileparts,atlases.names,'Uniformoutput',0);
[~,atlases.names]=cellfun(@fileparts,atlases.names,'Uniformoutput',0);

for branch=1:length(sels.branches)
    for leaf=1:length(sels.leaves{branch})
            for side=1:length(sels.sides{branch}{leaf})
                
                sidec=getsidec(length(sels.sides{branch}{leaf}),side);
                
                %[ixs,ixt]=getsubindex(h.sgsub{branch}{leaf},sidec,h.atlassurfs,h.togglebuttons);
                
                [~,ix]=ismember(char(h.sgsub{branch}{leaf}),atlases.names);
                if strcmp(sels.sides{branch}{leaf}{side},'selected') 
                                    pres.show=[pres.show,ix];


                elseif strcmp(sels.sides{branch}{leaf}{side},'not selected')
                                    pres.hide=[pres.hide,ix];
                end
            end

    end
end

tag=inputdlg('Please enter a name for the preset:','Preset name');
pres.label=tag{1};


prefs=ea_prefs;
machine=prefs.machine;
if ~isfield(machine.atlaspresets,getridofspaces(options.atlasset))
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets(1).default=pres.default;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets(1).show=pres.show;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets(1).hide=pres.hide;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets(1).label=pres.label;

else
    
    clen=length(machine.atlaspresets.(getridofspaces(options.atlasset)).presets);
    
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets(clen+1).default=pres.default;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets(clen+1).show=pres.show;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets(clen+1).hide=pres.hide;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets(clen+1).label=pres.label;
end

save([ea_gethome,'.ea_prefs.mat'],'machine');

% refresh content menu.
ea_createpcmenu(handles)
ea_busyaction('off',handles.atlasselect,'atlcontrol');


function str=getridofspaces(str)
str=strrep(str,'(','');
str=strrep(str,')','');
str=strrep(str,' ','');
str=strrep(str,'-','');


function ea_makeselection(~,~,handles,preset)

ea_busyaction('on',handles.atlasselect,'atlcontrol');

h=getappdata(handles.atlasselect,'h');
jtree=getappdata(handles.atlasselect,'jtree');
atlases=getappdata(handles.atlasselect,'atlases');
onatlasnames=atlases.names(preset.show);
offatlasnames=atlases.names(preset.hide);
% get rid of file extensions:
[~,onatlasnames]=cellfun(@fileparts,onatlasnames,'Uniformoutput',0);
[~,onatlasnames]=cellfun(@fileparts,onatlasnames,'Uniformoutput',0);
[~,offatlasnames]=cellfun(@fileparts,offatlasnames,'Uniformoutput',0);
[~,offatlasnames]=cellfun(@fileparts,offatlasnames,'Uniformoutput',0);

% iterate through jTree to set selection according to preset:
sels=storeupdatemodel(jtree,h);
for branch=1:length(sels.branches)
    for leaf=1:length(sels.leaves{branch})
        for side=1:length(sels.sides{branch}{leaf})
            sidec=getsidec(length(sels.sides{branch}{leaf}),side);
            [ixs,ixt]=getsubindex(h.sgsub{branch}{leaf},sidec,h.atlassurfs,h.togglebuttons);

            if ismember(char(h.sgsub{branch}{leaf}),onatlasnames)
                h.atlassurfs(ixs).Visible='on';
                h.togglebuttons(ixt).State='on';
            elseif ismember(char(h.sgsub{branch}{leaf}),offatlasnames)
                h.atlassurfs(ixs).Visible='off';
                h.togglebuttons(ixt).State='off';
            else % not explicitly mentioned
                switch preset.default
                    case 'absolute'
                        h.atlassurfs(ixs).Visible='off';
                        h.togglebuttons(ixt).State='off';
                    case 'relative'
                        % leave state as is.
                end
            end
        end
        
    end
end
ea_busyaction('off',handles.atlasselect,'atlcontrol');

ea_synctree(handles)

function ea_synctree(handles)
ea_busyaction('on',handles.atlasselect,'atlcontrol');

import com.mathworks.mwswing.checkboxtree.* 

h=getappdata(handles.atlasselect,'h');
jtree=getappdata(handles.atlasselect,'jtree');
% will sync tree and surfaces based on toggle buttons
sels=storeupdatemodel(jtree,h);
for branch=1:length(sels.branches)
    for leaf=1:length(sels.leaves{branch})
        for side=1:length(sels.sides{branch}{leaf})
            sidec=getsidec(length(sels.sides{branch}{leaf}),side);
            [ixs,ixt]=getsubindex(h.sgsub{branch}{leaf},sidec,h.atlassurfs,h.togglebuttons);
            switch h.togglebuttons(ixt).State
                
                case 'on'
                    
                    set(h.sgsubside{branch}{leaf}{side},'SelectionState',SelectionState.SELECTED)
                    set(h.sgsub{branch}{leaf},'SelectionState',SelectionState.SELECTED)
                    
                    if ~strcmp(h.atlassurfs(ixs).Visible,'on'); % also make sure surface is right
                        h.atlassurfs(ixs).Visible='on';
                    end
                    
                case 'off'
                    set(h.sgsubside{branch}{leaf}{side},'SelectionState',SelectionState.NOT_SELECTED)
                    set(h.sgsub{branch}{leaf},'SelectionState',SelectionState.NOT_SELECTED)

                    if ~strcmp(h.atlassurfs(ixs).Visible,'off'); % also make sure surface is right
                        h.atlassurfs(ixs).Visible='off';
                    end
            end
            
        end
        
    end
end
jtree.updateUI
ea_busyaction('off',handles.atlasselect,'atlcontrol');






% --- Executes during object creation, after setting all properties.
function presets_CreateFcn(hObject, eventdata, handles)
% hObject    handle to presets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end