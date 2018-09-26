function varargout = densVisGui(varargin)
% DENSVISGUI MATLAB code for densVisGui.fig
%      DENSVISGUI, by itself, creates a new DENSVISGUI or raises the existing
%      singleton*.
%
%      H = DENSVISGUI returns the handle to a new DENSVISGUI or the handle to
%      the existing singleton*.
%
%      DENSVISGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DENSVISGUI.M with the given input arguments.
%
%      DENSVISGUI('Property','Value',...) creates a new DENSVISGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before densVisGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to densVisGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help densVisGui

% Last Modified by GUIDE v2.5 26-Sep-2018 10:35:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @densVisGui_OpeningFcn, ...
                   'gui_OutputFcn',  @densVisGui_OutputFcn, ...
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


% --- Executes just before densVisGui is made visible.
function densVisGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to densVisGui (see VARARGIN)

%Create tab group
handles.tgroup = uitabgroup('Parent', handles.tabPanel,'TabLocation', 'left');
handles.tab1 = uitab('Parent', handles.tgroup, 'Title', '2D Projection');
handles.tab2 = uitab('Parent', handles.tgroup, 'Title', '3D Projection');
%Place panels into each tab
set(handles.pan2d,'Parent',handles.tab1)
set(handles.pan3d,'Parent',handles.tab2)
%Reposition each panel to same location as panel 1
set(handles.pan3d,'position',get(handles.pan2d,'position'));

% Choose default command line output for densVisGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes densVisGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = densVisGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile;
set(handles.dispFilename, 'string', file);
set(handles.beginSim, 'enable', 'on');


% --- Executes on button press in beginSim.
function beginSim_Callback(hObject, eventdata, handles)
% hObject    handle to beginSim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

file = get(handles.dispFilename, 'string');
densPlot(file, handles);


% --- Executes on button press in showCoast.
function showCoast_Callback(hObject, eventdata, handles)
% hObject    handle to showCoast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showCoast


% --- Executes on button press in showTrack.
function showTrack_Callback(hObject, eventdata, handles)
% hObject    handle to showTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showTrack


% --- Executes on button press in densVaryOn.
function densVaryOn_Callback(hObject, eventdata, handles)
% hObject    handle to densVaryOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of densVaryOn


% --- Executes on selection change in chooseView.
function chooseView_Callback(hObject, eventdata, handles)
% hObject    handle to chooseView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chooseView contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseView


% --- Executes during object creation, after setting all properties.
function chooseView_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
