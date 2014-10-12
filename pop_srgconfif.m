% pop_srgconfif() - Collect input variables for confidence interval calculation (std_srgconfif).
%
% Usage: 
%   >>  com = pop_srgconfif(ALLEEG,STUDY,varargin);
%
% Inputs:
%   ALLEEG   -
%   STUDY    - 
%   varargin -
%
% Outputs:
%   com      -
%
% Description:
%
% See also:
%   std_srgconfif, 

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

% $Log: pop_srgconfif.m edit history...
%

function com = pop_srgconfif(ALLEEG,STUDY,varargin)


% the command output is a hidden output that does not have to
% be described in the header
com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            
          % display help if not enough arguments
% ------------------------------------

if nargin < 2
	help pop_srgconfif;
	return;
end;	

% pop up window
% -------------
if nargin < 3

    results=inputgui( ...
    {1 [3 2] [3 2] [3 2] [3 2] [3 2] [3 2] 1 1 [3 1 1 1 6] [3 1 1 1 6] [3 1 1 1 3 3] [3 1 1 1 2 4] [3 1 1 1 3 3] [3 2 4] [3 1 5] [3 2 4] [3 2 4] 1 1 1 [1 1 2] 1 1 1 1 1}, ...
    {...
        ... %1
        {'Style', 'text', 'string', 'Bootstrapping parameters.', 'FontWeight', 'bold'}, ...
        ... %2
        {'Style', 'text', 'string', 'Maximum number of epochs to use per surrogate set (empty = all):'}, ...
        {'Style', 'edit', 'tag', 'edt_nepmax'}, ...
        ... %3
        {'Style', 'text', 'string', 'Number of surrogate sets to use in confidence interval estimation:'}, ...
        {'Style', 'edit', 'string', num2str(1000), 'tag', 'edt_nsrgsamps'}, ...
        ... %4
        {'Style', 'text', 'string', 'Number of Monte Carlo experiments to run (empty = none):'}, ...
        {'Style', 'edit', 'tag', 'edt_nmexps'}, ...
        ... %5
        {'Style', 'text', 'string', 'Percentage of trials to trim in mean calculation:'}, ...
        {'Style', 'edit', 'string', num2str(.2), 'tag', 'edt_ptrim'}, ...
        ... %6
        {'Style', 'text', 'string', 'Data point to use in resampling (empty = all):'}, ...
        {'Style', 'edit', 'tag', 'edt_pnts'}, ...
        ... %7
        {'Style', 'text', 'string', 'Point to use for baseline subtraction (empty = none):'}, ...
        {'Style', 'edit', 'tag', 'edt_blpnts'}, ...
        ... %8
        {}, ...
        ... %9
        {'Style', 'text', 'string', 'Signals/measures on which to perform bootstrapping:','FontWeight','bold'}, ...
        ... %10
        {'Style', 'text', 'string', 'Signals:'}, ...
        {'Style', 'text', 'string', 'ERP:'}, ...
        {'Style', 'text', 'string', 'ERSP:'}, ...
        {'Style', 'text', 'string', 'ITC:'}, ...
        {}, ...
        ... %11
        {'Style', 'text', 'string', 'Gloabal Field Average:'}, ...
        {'Style', 'checkbox', 'tag', 'chkgfaerp', 'value', 0}, ...
        {}, ...
        {}, ...
        {}, ...
        ... %12
        {'Style', 'text', 'string', 'Scalp sites:'}, ...
        {'Style', 'checkbox', 'tag', 'chksserp', 'value', 0}, ...
        {'Style', 'checkbox', 'tag', 'chkssersp', 'value', 0}, ...
        {'Style', 'checkbox', 'tag', 'chkssitc', 'value', 0}, ...
        {'Style', 'text', 'string', 'Cell array of channels labels:'}, ...
        {'Style', 'edit', 'tag', 'edtchlab'}, ...
        ... %13
        {'Style', 'text', 'string', 'Interpolated scalp sites:'}, ...
        {'Style', 'checkbox', 'tag', 'chkisserp', 'value', 0}, ...
        {'Style', 'checkbox', 'tag', 'chkissersp', 'value', 0}, ...
        {'Style', 'checkbox', 'tag', 'chkissitc', 'value', 0}, ...
        {'Style', 'pushbutton', 'string', '*.sfp file', ...
                    'callback',['[fname,fpath]=uigetfile(''*.sfp'',''Select coordinate file'');' ...
                                'set(findobj(gcbf, ''tag'', ''edtsfpf''), ''string'', [fpath,fname])']}, ...
        {'Style', 'edit', 'tag', 'edtsfpf'}, ...
        ... %14
        {'Style', 'text', 'string', 'Independent components:'}, ...
        {'Style', 'checkbox', 'tag', 'chkicerp', 'value', 0}, ...
        {'Style', 'checkbox', 'tag', 'chkicersp', 'value', 0}, ...
        {'Style', 'checkbox', 'tag', 'chkicitc', 'value', 0}, ...
        {'Style', 'text', 'string', 'IC indeces ([ ] = STUDY.cluster):'}, ...
        {'Style', 'edit', 'tag', 'edticind'}, ...
        ... %15
        {}, ...
        {'Style', 'text', 'string', 'newtimef cycles:'}, ...
        {}, ...
        ... %16
        {}, ...
        {'Style', 'edit', 'string','[3 .5]','tag', 'ntf_cycles'}, ...
        {}, ...
        ... %17
        {}, ...
        {'Style', 'text', 'string', 'newtimef options:'}, ...
        {}, ...
        ... %18
        {}, ...
        {'Style', 'edit', 'tag', 'ntf_options'}, ...
        {}, ...
        ... %19
        {}, ...
        ... %20
        {'Style', 'text', 'string', 'Administrative preferences:', 'FontWeight', 'bold'}, ...
        ... %21
        {'Style', 'checkbox', 'tag', 'chkparproc', 'string', 'Enable parallel processing'}, ...
        ... %22
        {'Style', 'text', 'string', 'Add suffix to output files:'}, ...
        {'Style', 'edit', 'tag', 'edtfsuf'}, ...
        {}, ...
        {}, ...
        ... %23
        {'Style', 'text', 'string', 'Optional inputs:', 'FontWeight', 'bold'}, ...
        ... %24
        {'Style', 'text', 'string', 'String of key/val pairs for varargin:'}, ...
        ... %25
        {'Style', 'edit', 'tag', 'edtopts'}, ...
        ... %26
        {'Style', 'checkbox', 'string', 'Submit to remote cluster', 'value', 0} ...
        
     }, ...
     'pophelp(''pop_srgconfif'');', 'Select bootstrapping parameters -- pop_srgconfif()' ...
     );
 
     if isempty(results);return;end
     
     nepmax=       results{1};
     nsrgsamps=    results{2};
     nmcexps=      results{3};
     ptrim=        results{4};
     pnts=         results{5};
     blpnts=       results{6};
     %chkgfa=       results{7};
     chkgfaerp=    results{7};
     %chkss=        results{9};
     chksserp=     results{8};
     chkssersp=    results{9};
     chkssitc=     results{10};
     chlabs=       results{11};
     %chkiss=       results{14};
     chkisserp=    results{12};
     chkissersp=   results{13};
     chkissitc=    results{14};
     montfile=     results{15};
     %chkic=        results{19};
     chkicerp=     results{16};
     chkicersp=    results{17};
     chkicitc=     results{18};
     icinds=       results{19};
     ntfcycs=      results{20};
     ntfopts=      results{21};
     chkparproc=   results{22};
     intermext=    results{23};
     opts=         results{24};
     subrmtclst=   results{25};
end

options=[];

% Bootstrapping key/val pairs...
if ~isempty(nepmax);     options=[options, ', ''nepmax'', ', num2str(nepmax)]; end;
if ~isempty(nsrgsamps);  options=[options, ', ''nsrgsamps'', ', num2str(nsrgsamps)]; end;
if ~isempty(nmcexps);    options=[options, ', ''nmcexps'', ', num2str(nmcexps)]; end;
if ~isempty(ptrim);      options=[options, ', ''ptrim'', ', num2str(ptrim)]; end;
if ~isempty(pnts);       options=[options, ', ''pnts'', ', num2str(pnts)]; end;
if ~isempty(blpnts);     options=[options, ', ''blpnts'', ', num2str(blpnts)]; end;

% Signal/measure key/val pairs...
%if chkgfa;               options=[options, ', ''gfa'', ''on''']; end;
if chkgfaerp;            options=[options, ', ''gfaerp'', ''on''']; end;
%if chkss;                options=[options, ', ''ass'', ''on''']; end;
if ~isempty(chlabs);     options=[options, ', ''chlabs'',', chlabs]; end;
if chksserp;             options=[options, ', ''sserp'', ''on''']; end;
if chkssersp;            options=[options, ', ''ssersp'', ''on''']; end;
if chkssitc;             options=[options, ', ''ssitc'', ''on''']; end;
%if chkiss;               options=[options, ', ''iss'', ''on''']; end;
if chkisserp;            options=[options, ', ''isserp'', ''on''']; end;
if chkissersp;           options=[options, ', ''issersp'', ''on''']; end;
if chkissitc;            options=[options, ', ''issitc'', ''on''']; end;
if ~isempty(montfile);   options=[options, ', ''montfile'', ''', montfile, '''']; end;
%if chkic;                options=[options, ', ''ic'', ''on''']; end;
if chkicerp;             options=[options, ', ''icerp'', ''on''']; end;
if chkicersp;            options=[options, ', ''icersp'', ''on''']; end;
if chkicitc;             options=[options, ', ''icitc'', ''on''']; end;
if ~isempty(icinds);     options=[options, ', ''icinds'', ''', icinds, '''']; end;
if ~isempty(ntfcycs);    options=[options, ', ''ntfcycs'', ', num2str(ntfcycs)]; end;
if ~isempty(ntfopts);    options=[options, ', ''ntfopts'', ', ntfopts]; end;

% Administrative preferences...
if chkparproc;           options=[options, ', ''parproc'', ''on''']; end;
if ~isempty(intermext);  options=[options, ', ''intermext'', ''', intermext, '''']; end;
if subrmtclst;           options=[options, ', ''subrmtclst'', 1']; end;

% Optional inputs...
if ~isempty(opts);       options=[options, ', ', opts];end;
options
% return command
% -------------------------
com=sprintf('com = pop_srgconfif( %s, %s %s);', inputname(1), inputname(2), options)

% execute command
% ------------
exec=sprintf('std_srgconfif(%s, %s %s);', inputname(1), inputname(2), options);
eval(exec);


%return;
