% eegplugin_ConfI() - EEGLAB plugin for calculating and visualizing effect confidence intevals.
%
% Usage:
%   >> eegplugin_ConfI(fig, try_strings, catch_stringss);
%
% Inputs:
%   fig            - [integer]  EEGLAB figure
%   try_strings    - [struct] "try" strings for menu callbacks.
%   catch_strings  - [struct] "catch" strings for menu callbacks.
%
% Creates Edit menu option "Visually edit events and identify bad channels"
% and calls pop_VisEd(EEG). 
%
%
% Copyright (C) <2008> <James Desjardins> Brock University
%
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

% $Log: eegplugin_confi.m edit history...
%

function eegplugin_ConfI(fig,try_strings,catch_strings)


% find EEGLAB tools menu.
% ---------------------
studymenu=findobj(fig,'label','Study');

% Create "pop_Confi" callback cmd.
%---------------------------------------
srgf_cmd='LASTCOM = pop_srgconfif(ALLEEG,STUDY);';
stat_cmd='[STUDY, LASTCOM] = pop_mapstat(STUDY);';
derpci_cmd='LASTCOM = pop_ploterpci(STUDY);';
dsigtopo_cmd='LASTCOM = pop_plotsigtopo(ALLEEG,STUDY);';
dsigsurf_cmd='LASTCOM = pop_plottfsigsurf(STUDY);';

% add "Visual edit" submenu to the "Edit" menu.
%--------------------------------------------------------------------
uimenu(studymenu, 'label', 'Surrogate sample current design', 'callback', srgf_cmd, 'separator', 'on','userdata','study:on');
uimenu(studymenu, 'label', 'Calculate confidence intervals', 'callback', stat_cmd,'userdata','study:on');
dcimenu=uimenu(studymenu, 'label', 'Display surrogate results','userdata','study:on');
    uimenu(dcimenu, 'label', 'ERP condition ovelay', 'callback', derpci_cmd,'userdata','study:on');
    uimenu(dcimenu, 'label', 'Channel significance overlays with topomaps', 'callback', dsigtopo_cmd,'userdata','study:on');
    uimenu(dcimenu,'label', 'TF significance surface','callback', dsigsurf_cmd,'userdata','study:on');