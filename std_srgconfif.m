% std_srgconfif() - Confidence interval calculation.
%
% Usage: 
%   >>  std_srgconfif(ALLEEG,STUDY,varagin);
%
% Inputs:
%   ALLEEG   -
%   STUDY    - 
%   options  -
%
% Outputs:
%   files containing surrogate sample data.
%
% Description:
%   eg.
%   std_srgfiler(ALLEEG,STUDY,'intermext','tst','ptrim',.2,'chanlabs','{ALLEEG(1).chanlocs.labels}','nsrgsamps',1000)
%
% See also:
%   pop_srgconfif, 

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

% $Log: std_srgconfif.m edit history...
%

function std_srgconfif(ALLEEG,STUDY,varargin)

%COLLECT AND SET g STRUDCTURE FROM VARARGIN KEY/VAL PAIRS...
g = struct(varargin{:});

% Bootstrapping key/val pairs...
try g.nepmax;       catch, g.nepmax      = [];           end; 
try g.nsrgsamps;    catch, g.nsrgsamps   = 1000;         end;
try g.nmcexps;      catch, g.nmcexps     = 1;            end;
try g.ptrim;        catch, g.ptrim       = [];           end;
try g.pnts;         catch, g.pnts        = [];           end;
try g.blpnts;       catch, g.blpnts      = [];           end;

% Signal/meaure key/val pairs...
%try g.gfa;          catch, g.gfa         = 'off';        end;
try g.gfaerp;       catch, g.gfaerp      = 'off';        end;

%try g.ss;           catch, g.ss          = 'off';        end;
try g.sserp;        catch, g.sserp       = 'off';        end;
try g.ssersp;       catch, g.ssersp      = 'off';        end;
try g.ssitc;        catch, g.ssitc       = 'off';        end;
try g.chlabs;       catch, g.chlabs      = '';           end;

%try g.iss;          catch, g.iss         = 'off';        end;
try g.isserp;       catch, g.isserp      = 'off';        end;
try g.issersp;      catch, g.issersp     = 'off';        end;
try g.issitc;       catch, g.issitc      = 'off';        end;
try g.montfile;     catch, g.montfile    = '';           end;
try g.nisschans;    catch, g.nisschans   = [];            end;
try g.nfids;        catch, g.nfids       = 3;            end;
try g.coreglndmrks; catch, g.coreglndmrks= [];           end;
try g.manual;       catch, g.manual      = 'off';        end;

%try g.ic;           catch, g.ic          = 'off';        end;
try g.icerp;        catch, g.icerp       = 'off';        end;
try g.icersp;       catch, g.icersp      = 'off';        end;
try g.icitc;        catch, g.icitc       = 'off';        end;
try g.icinds;       catch, g.icinds      = [];           end;

try g.ntfcycs;      catch, g.ntfcycs     = [3 .5];       end;
try g.tfopts;       catch, g.tfopts      = '';           end;
%try g.tffreqs;      catch, g.tffreqs     = [3 30];       end;

% Administrative preferences...
try g.parproc;      catch, g.parproc     = 'off';        end;
try g.nlabs;        catch, g.nlabs       = [];           end;
try g.subrmtclst;   catch, g.subrmtclst  = 0;            end;
try g.srgwint;      catch, g.srgwint     = g.nsrgsamps;  end;
try g.intermext;    catch, g.intermext   = '';           end;

if g.subrmtclst
    g.parproc = 'rmtclst';
    
    global option_remoteclust
    
    if isempty(option_remoteclust)
        'no remote cluter configuration loaded... quitting.';
        return
    end
    g.localStudyPath = option_remoteclust.localDataPath;
    g.clustStudyPath = option_remoteclust.remoteDataPath;
end

%try g.localStudyPath;   catch, g.localStudyPath  = [];           end;
%try g.clustStudyPath;   catch, g.clustStudyPath  = [];           end;
%try g.clusterHost;      catch, g.clusterHost      = '';         end; 
%try g.remoteLocation;   catch, g.remoteLocation   = '';         end;
%try g.DataLocation;     catch, g.remoteLocation   = '';         end;
%try g.RootLocalPath;    catch, g.RootLocalPath    = '/home/bucanl/Documents/MATLAB_path/';         end;
%try g.RootRemotePath;   catch, g.RootLocalPath    = '/home/jdesjard/dev/';         end;

cdesign=STUDY.currentdesign;
nsets=length(STUDY.design(cdesign).cell);


% PERFORM SURROGATE SAMPLING PROCEDURE ON DATASETS INDEXED BY STUDY.design(cdesign).cell STRUCTURE...

%Distinguish serial or parallel processing...
switch(g.parproc);
    case 'off';
        tic;
        for cind=1:nsets;
            srgexec(ALLEEG,STUDY,g,cdesign,cind);            
        end
        disp(toc)
    case 'on'
        %Declare parallel processing...
        if matlabpool('size') == 0 % checking to see if my pool is already open
            eval(['matlabpool open ', num2str(g.nlabs)])
        end
        tic;
        parfor cind=1:nsets;
            srgexec(ALLEEG,STUDY,g,cdesign,cind);
        end
        disp(toc)
        matlabpool close
    case 'rmtclst';
        %build taskInCell
        for i=1:nsets;
            taskInCell{i}={ALLEEG,STUDY,g,cdesign,i};
        end
        
        %submit job
        remoteClustSubmit('srgexec',taskInCell)
end
