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
function std_ploterpci(STUDY,fname,varargin)

% Handle varargin, create g structure...
g=struct(varargin{:});

try g.subjind;   catch, g.subjind=[];  end
try g.sigind;    catch, g.sigind=[];   end
try g.time;      catch, g.time=[];     end
try g.limits;    catch, g.limits=[];   end
try g.diffconst; catch, g.diffconst=0; end

load(fname);

% Define srgdat structure...
if ~isempty(g.subjind);
    %eval(['srgdat=STUDY.', fieldname, '.ss;']);
    ind=strmatch(num2str(g.subjind),STUDY.design(STUDY.currentdesign).cases.value,'exact');
    num2str(g.subjind)
    STUDY.design(STUDY.currentdesign).cases.value
    %ind
    
    srgdat.erp=         confidat.ss.erp(:,:,:,:,1,ind);
    %srgdat.ddat=        confidat.ss.ddat(:,:,:,:,:,ind);
    srgdat.mddat=       confidat.ss.mddat(:,:,:,:,1,ind);
    srgdat.sddat=       confidat.ss.sddat(:,:,:,:,1,ind);
    srgdat.ci=          confidat.ss.ci(:,:,:,:,1,ind);
    srgdat.critdat=     confidat.ss.critdat(:,:,:,:,1,ind);
    srgdat.critampdat=  confidat.ss.critampdat(:,:,:,:,1,ind);
    srgdat.critzdat=    confidat.ss.critzdat(:,:,:,:,1,ind);
    srgdat.zdat=        confidat.ss.zdat(:,:,:,:,1,ind);

    
%    srgdat.erp=srgdat.erp(:,ind,:,:,:,:);
%    srgdat.ddat=srgdat.ddat(:,ind,:,:,:,:);
    
%    size(srgdat.ddat)
%    srgdat.mddat=srgdat.mddat(:,ind,:,:,:,:);
%    srgdat.sddat=srgdat.sddat(:,ind,:,:,:,:);
%    srgdat.ci=srgdat.ci(:,ind,:,:,:,:);
%    srgdat.critdat=srgdat.critdat(:,:,ind);
%    srgdat.critampdat=srgdat.critampdat(:,:,ind);
%    srgdat.critzdat=srgdat.critzdat(:,:,ind);
%    srgdat.zdat=srgdat.zdat(:,ind,:,:,:,:);
    
    % To do: select the specific subject indexed by subjind...
else
    %eval(['srgdat=STUDY.', fieldname, '.ga;']);
    srgdat.erp=         confidat.ga.erp(:,:,:,:,1,1,:);
    %srgdat.ddat=        confidat.ss.ddat(:,:,:,:,:,ind);
    srgdat.mddat=       confidat.ga.mddat(:,:,:,:,1,1,:);
    srgdat.sddat=       confidat.ga.sddat(:,:,:,:,1,1,:);
    srgdat.ci=          confidat.ga.ci(:,:,:,:,1,1,:);
    srgdat.critdat=     confidat.ga.critdat(:,:,:,:,1,1,:);
    srgdat.critampdat=  confidat.ga.critampdat(:,:,:,:,1,1,:);
    srgdat.critzdat=    confidat.ga.critzdat(:,:,:,:,1,1,:);
    srgdat.zdat=        confidat.ga.zdat(:,:,:,:,1,1,:);
end

t=0:size(srgdat.erp,3)-1;
if ~isempty(g.time);
    t=(t.*(1000/g.time(2)))+(g.time(1));
end

if isempty(g.sigind);
    g.sigind=1:size(srgdat.erp,1);
end
for csig=1:length(g.sigind);
    % plot all difference waves...
    figure;%plot(t,squeeze(srgdat.ddat(g.sigind(csig),:,:)),'Color',[.9,.9,.9]);%tmp
    set(gca,'XGrid','on','YGrid','on');
    jbfill(t, ...
        squeeze(srgdat.ci(g.sigind(csig),:,:,:,:,:,1))', ...
        squeeze(srgdat.ci(g.sigind(csig),:,:,:,:,:,2))', ...
        [.5 .5 .5], ...
        [.5 .5 .5]);
    
    % plot null, confidence intervals, and significant periods...
    hold on;plot(t,zeros(1,size(srgdat.ci,3))+g.diffconst,'Color',[1 1 1],'Linewidth',3);
    sigpnts=find(srgdat.critdat(g.sigind(csig),1,:,:,:));
    plot(t(sigpnts),zeros(size(sigpnts))+g.diffconst,'r.','MarkerSize',5);
    %plot(t,squeeze(srgdat.ci(g.sigind(csig),:,:,:,:,:))+g.diffconst,'Color',[.5,.5,.5]);
    plot(t,squeeze(srgdat.erp(g.sigind(csig),:,:,:,:,:,1)),'Color',[0,0,0],'LineWidth',2);
    plot(t,squeeze(srgdat.erp(g.sigind(csig),:,:,:,:,:,2)),'Color',[0,0,0],'LineWidth',1);

    if ~isempty(g.limits);
        axis(g.limits);
    else
        axis tight        
    end

end

