% std_ploterpci() - Collect input variables for plotting ERP
% confidence intervals calculated from std_srgconfif and std_mapstat.
%
% Usage:
%   >>  std_ploterpci(STUDY,fieldname,varargin);
%
% Inputs:
%   STUDY      - 
%   fieldname  -
%   varargin   -
%
% Outputs:
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

% $Log: srg_ploterpci.m edit history...
%
function std_plotsigtopo(ALLEEG,STUDY,fieldname,chanlocs,varargin)

% Handle varargin, create g structure...
g=struct(varargin{:});

try g.subjind;   catch, g.subjind=[];  end
try g.time;      catch, g.time=[];     end
try g.limits;    catch, g.limits=[];   end
try g.plottimes;  catch, g.plottimes=[];end

%chanlocs
if ischar(chanlocs);
    eval(['locs=load(''', chanlocs, ''');']);
end

options='';
if ~isempty(g.limits)
    options=[options,', ''limits'', [', num2str(g.limits), ']'];
end
if ~isempty(g.plottimes)
    options=[options,', ''plottimes'', [', num2str(g.plottimes), ']'];
end

% Define srgdat structure...
if ~isempty(g.subjind);
    eval(['srgdat=STUDY.', fieldname, '.ss;']);
    ind=strmatch(num2str(g.subjind),STUDY.design(STUDY.currentdesign).cases.value,'exact');
    srgdat.erp=srgdat.erp(:,:,:,:,ind,:);
    srgdat.ddat=srgdat.ddat(:,:,:,:,ind,:);
    srgdat.mddat=srgdat.mddat(:,:,:,:,ind,:);
    srgdat.sddat=srgdat.sddat(:,:,:,:,ind,:);
    srgdat.ci=srgdat.ci(:,:,:,:,ind,:);
    srgdat.critdat=srgdat.critdat(:,:,ind);
    srgdat.critampdat=srgdat.critampdat(:,:,ind);
    srgdat.critzdat=srgdat.critzdat(:,:,ind);
    srgdat.zdat=srgdat.zdat(:,:,:,:,ind,:);
else
    eval(['srgdat=STUDY.', fieldname, '.ga;']);
end

%srgdat
t=0:size(srgdat.critzdat,2)-1;
if ~isempty(g.time);
    t=(t.*(1000/g.time(2)))+(g.time(1));
    limits=[t(1),t(length(t))];
end

if isempty(options)
    figure;timtopo(squeeze(srgdat.critzdat),locs.chanlocs,'limits',limits);
else
    figcmd=['figure;timtopo(squeeze(srgdat.critzdat),locs.chanlocs,''limits'', [', num2str(limits), ']',options, ');']
    eval(figcmd);
end
    
