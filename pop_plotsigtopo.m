% com = pop_plotsigtopo() - Collect input variables for plotting ERP
% confidence intervals calculated from std_srgconfif and std_mapstat.
%
% Usage: 
%   >>  com = pop_plotsigtopo(ALLEEG,STUDY);
%
% Inputs:
%   STUDY    - 
%
% Outputs:
%   com      -
%
% Description:
%
% See also:
%   std_srgconfif, std_mapstat, 

% Copyright (C) <2008>  <James Desjardins> Brock University
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: pop_ploterpci.m edit history...
%

function com = pop_plotsigtopo(ALLEEG,STUDY,fieldname,chanlocs,varargin)


% the command output is a hidden output that does not have to
% be described in the header
com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            
          % display help if not enough arguments
% ------------------------------------

if nargin < 1
	help pop_ploterpci;
	return;
end;	

% Handle varargin, create g structure...
g=struct(varargin{:});

try g.subjind;   catch, g.subjind=[];  end
try g.time;      catch, g.time=[];     end
try g.limits;    catch, g.limits=[];   end
try g.plottimes;  catch, g.plottimes=[];end

%if ischar(chanlocs);
%    eval(['chanlocs=', chanlocs, ';']);
%end

options='';
if ~isempty(g.subjind)
    options=[options,', ''subjind'', ', num2str(g.subjind)];
end
if ~isempty(g.time)
    options=[options,', ''time'', [', num2str(g.time), ']'];
end
if ~isempty(g.limits)
    options=[options,', ''limits'', [', num2str(g.limits), ']'];
end
if ~isempty(g.plottimes)
    options=[options,', ''plottimes'', [', num2str(g.plottimes), ']'];
end

% pop up window
% -------------
if nargin < 4

    results=inputgui( ...
    {[1] [3 2] [3 2] [3 2] [3 2] [3 2] [1]}, ...
    {...
        ... %1
        {'Style', 'text', 'string', 'Channel significance overlays with topomaps.', 'FontWeight', 'bold'}, ...
        ... %2
        {'Style', 'text', 'string', 'STUDY field name:'}, ...
        {'Style', 'edit', 'string', 'srgout', 'tag', 'edt_fieldname'}, ...
        ... %3
        {'Style', 'text', 'string', 'Subject index ([] = grand average):'}, ...
        {'Style', 'edit', 'tag', 'edt_subjind'}, ...
        ... %4
        {'Style', 'text', 'string', 'channel location file:'}, ...
        {'Style', 'edit', 'tag', 'edt_chanlocs'}, ...
        ... %5
        {'Style', 'text', 'string', 'Times [start time, sampling rate]:'}, ...
        {'Style', 'edit', 'tag', 'edt_time'}, ...
        ... %6
        {'Style', 'text', 'string', 'pop_ploterpci options (see help pop_ploterpci):'}, ...
        {'Style', 'edit', 'tag', 'edt_options'}, ...
        ... %7
        {}, ...
     }, ...
     'pophelp(''pop_ploterpci'');', 'Select ERP category overlay parameters -- pop_ploterpci()' ...
     );
 
     if isempty(results);return;end
     
     fieldname=    results{1};
     subjind=      results{2};
     chanlocs=     results{3};
     time=         results{4};
     options=      results{5};
     
     if ~isempty(options);
         options=[', ', options];
     end
     
     if ~isempty(subjind);     options=[options, ', ''subjind'', ', num2str(subjind)]; end;
     if ~isempty(time);        options=[options, ', ''time'', ', num2str(time)]; end;

end



% return command
% -------------------------
com=sprintf('com = pop_plotsigtopo(%s, %s, ''%s'', ''%s'' %s);', ...
                inputname(1), inputname(2),fieldname, chanlocs, options)

% execute command
% ------------
exec=sprintf('std_plotsigtopo(%s, %s, ''%s'', ''%s'' %s);', ...
                inputname(1), inputname(2), fieldname, chanlocs, options);
eval(exec);
