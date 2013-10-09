function varargout = symmetry_GUI_1(varargin)
% SYMMETRY_GUI_1 M-file for symmetry_GUI_1.fig
%      SYMMETRY_GUI_1, by itself, creates a new SYMMETRY_GUI_1 or raises the existing
%      singleton*.
%
%      H = SYMMETRY_GUI_1 returns the handle to a new SYMMETRY_GUI_1 or the handle to
%      the existing singleton*.
%
%      SYMMETRY_GUI_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SYMMETRY_GUI_1.M with the given input arguments.
%
%      SYMMETRY_GUI_1('Property','Value',...) creates a new SYMMETRY_GUI_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before symmetry_GUI_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to symmetry_GUI_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help symmetry_GUI_1

% Last Modified by GUIDE v2.5 21-Apr-2011 09:30:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @symmetry_GUI_1_OpeningFcn, ...
                   'gui_OutputFcn',  @symmetry_GUI_1_OutputFcn, ...
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


% --- Executes just before symmetry_GUI_1 is made visible.
function symmetry_GUI_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to symmetry_GUI_1 (see VARARGIN)

% Choose default command line output for symmetry_GUI_1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes symmetry_GUI_1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = symmetry_GUI_1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Subject_D_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Subject_D_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Subject_D_edit as text
%        str2double(get(hObject,'String')) returns contents of Subject_D_edit as a double


% --- Executes during object creation, after setting all properties.
function Subject_D_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Subject_D_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumberOfTasks_edit_Callback(hObject, eventdata, handles)
% hObject    handle to NumberOfTasks_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberOfTasks_edit as text
%        str2double(get(hObject,'String')) returns contents of NumberOfTasks_edit as a double


% --- Executes during object creation, after setting all properties.
function NumberOfTasks_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberOfTasks_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function UseTrigger_edit_Callback(hObject, eventdata, handles)
% hObject    handle to UseTrigger_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UseTrigger_edit as text
%        str2double(get(hObject,'String')) returns contents of UseTrigger_edit as a double


% --- Executes during object creation, after setting all properties.
function UseTrigger_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UseTrigger_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Quit_pushbutton.
function Quit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Quit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Run_pushbutton.
function Run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
