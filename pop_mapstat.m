% com = pop_mapstat() - Collect input variables for the calculation of confidence
% intervals based on surrogate files created by std_confif.
%
% Usage: 
%   >>  com = pop_mapstat(STUDY,options);
%
% Inputs:
%   STUDY    - 
%   options  -
%
% Outputs:
%   com      -
%
% Description:
%
% See also:
%   std_mapstat, 

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

% $Log: pop_mapstat.m edit history...
%

function [STUDY,com] = pop_mapstat(STUDY,fnameout,zcrit,trgext,ssstat)


% the command output is a hidden output that does not have to
% be described in the header
com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            
          % display help if not enough arguments
% ------------------------------------

if nargin < 1
	help pop_mapstat;
	return;
end;	

% pop up window
% -------------
if nargin < 3

    results=inputgui( ...
    {[1] [3 2] [3 2] [3 2] [1] [1] [1]}, ...
    {...
        ... %1
        {'Style', 'text', 'string', 'Confidence interval parameters.', 'FontWeight', 'bold'}, ...
        ... %2
        {'Style', 'text', 'string', 'Root file name for output:'}, ...
        {'Style', 'edit', 'string', 'srgout', 'tag', 'edt_fieldname'}, ...
        ... %3
        {'Style', 'text', 'string', 'Critical z value (default = 2.326):'}, ...
        {'Style', 'edit', 'string', num2str(2.326), 'tag', 'edt_zcrit'}, ...
        ... %4
        {'Style', 'text', 'string', 'Target surrogate file extension:'}, ...
        {'Style', 'edit', 'tag', 'edt_trgext'}, ...
        ... %5
        {'Style', 'checkbox', 'tag', 'chkssstat', 'string', 'Calculate single subject confidence intervals:', 'value', 0}, ...
        ... %6
        {'Style', 'checkbox', 'string', 'Submit to remote cluster', 'value', 0}, ...
        {},...
     }, ...
     'pophelp(''pop_mapstat'');', 'Select confidence interval parameters -- pop_mapstat()' ...
     );
 
     if isempty(results);return;end
     
     fnameout=     results{1};
     zcrit=        results{2};
     trgext=       results{3};
     ssstat=       results{4};
     subrmtclst=   results{5};
     
end

if subrmtclst

    global option_remoteclust
    if ~isfield(option_remoteclust,'clustHost')
        disp('no remote cluter configuration loaded... quitting.');
        return
    end

    %build taskInCell
    taskInCell={STUDY,fnameout,str2num(zcrit),trgext,ssstat,subrmtclst, ...
                        'localDataPath',option_remoteclust.localDataPath, ...
                        'remoteDataPath',option_remoteclust.remoteDataPath, ...
                        };
    
    %submit job
    remoteClustSubmit('std_mapstat',taskInCell)

else
    
    % return command
    % -------------------------
    com=sprintf('com = pop_mapstat( %s, ''%s'', %s, ''%s'', %s, %s);', inputname(1), fnameout, zcrit, trgext, num2str(ssstat),num2str(subrmtclst))
    
    % execute command
    % ------------
    exec=sprintf('STUDY=std_mapstat(%s, ''%s'', %s, ''%s'', %s, %s);', inputname(1), fnameout, zcrit, trgext, num2str(ssstat),num2str(subrmtclst));
    eval(exec);

end
