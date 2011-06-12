function [] = killable_window( sh )
S.fh = sh;

% figure('units','pixels',...
%              'position',[500 200 200 100],...
%              'menubar','none',...
%              'name','gui',...
%              'numbertitle','off',...
%              'resize','off');

S.pb = uicontrol('style','push',...
                 'units','pix',...
                 'position',[10 30 80 20],...
                 'fontsize',12,...
                 'string','Quit');          

% S.tx = uicontrol('style','text',...
%                  'units','pix',...
%                  'position',[10 55 180 40],...
%                  'string','goodbye',...
%                  'fontsize',23);

set(S.pb,'callback'   ,{@pb_call,S})
% Check if 'p' is pressed when focus on button and exec callback
set(S.pb,'KeyPressFcn',{@pb_kpf ,S});

% Check if 'p' is pressed when focus on figure and exec callback
set(S.fh,'KeyPressFcn',{@pb_kpf ,S});

% Callback for pushbutton, prints Hi! in cmd window
function pb_call(varargin)
  S = varargin{3};  % Get the structure.
  
  fprintf('force quitting due to button press...\n');
 
  % ghetto: clear everything to force a crash later
  % and prevent anyone from successfully catching an exception
  clear all;
  
  % set(S.tx,'String', get(S.pb,'String'))
  
end

% Do same action as button when pressed 'p'
function pb_kpf(varargin)
  if varargin{1,2}.Character == 'p'
      pb_call(varargin{:})
  end
end

end
